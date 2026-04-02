import Foundation
import AppKit
import Combine

public final class NowPlayingService: ObservableObject {
    @Published public var title: String = ""
    @Published public var artist: String = ""
    @Published public var artwork: NSImage? = nil
    @Published public var duration: Double = 0
    @Published public var elapsed: Double = 0
    @Published public var playbackRate: Double = 0
    @Published public var updateAvailable: Bool = false
    @Published public var trackChangeDirection: Int = 0  // -1 prev, 0 initial, +1 next

    // For smooth progress interpolation
    private var lastFetchedElapsed: Double = 0
    private var lastFetchTimestamp: Date = .distantPast
    private var positionTimer: AnyCancellable?
    private var notificationTokens: [NSObjectProtocol] = []

    // The PersistentID of the current track (for artwork lookup via Music scripting bridge)
    private var currentPersistentID: Int64? = nil

    public var playbackState: PlaybackState {
        if title.isEmpty { return .standby }
        return playbackRate > 0 ? .playing : .paused
    }

    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, elapsed / duration)
    }

    public var elapsedFormatted: String { formatTime(elapsed) }

    public init() {
        observeDistributedNotifications()
        startPositionTimer()
        Task { await checkForUpdate() }
        // Fetch current state immediately via scripting bridge (async, best-effort)
        Task { await fetchViaScriptingBridge() }
    }

    public func refresh() {
        Task { await fetchViaScriptingBridge() }
    }

    public func sendCommand(_ command: MRCommand) {
        if command == .nextTrack     { trackChangeDirection = 1 }
        if command == .previousTrack { trackChangeDirection = -1 }
        Task { await sendCommandViaAppleScript(command) }
    }

    @MainActor
    private func sendCommandViaAppleScript(_ command: MRCommand) async {
        let action: String
        switch command {
        case .play:             action = "play"
        case .pause:            action = "pause"
        case .togglePlayPause:  action = "playpause"
        case .nextTrack:        action = "next track"
        case .previousTrack:    action = "previous track"
        }
        let script = """
        tell application "Music"
            if it is running then
                \(action)
            end if
        end tell
        """
        _ = runAppleScript(script)
    }

    public func seek(to fraction: Double) {
        let position = fraction * duration
        elapsed = position
        lastFetchedElapsed = position
        lastFetchTimestamp = Date()
        Task {
            let script = """
            tell application "Music"
                if it is running then
                    set player position to \(position)
                end if
            end tell
            """
            _ = runAppleScript(script)
        }
    }

    public func openPlayer() {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Distributed Notifications (Music app fires these reliably)

    private func observeDistributedNotifications() {
        let dnc = DistributedNotificationCenter.default()
        let token = dnc.addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil, queue: .main
        ) { [weak self] notif in
            self?.handleMusicPlayerInfo(notif.userInfo)
        }
        notificationTokens.append(token)
    }

    private func handleMusicPlayerInfo(_ info: [AnyHashable: Any]?) {
        guard let info else { return }

        let newTitle  = info["Name"]         as? String ?? ""
        let newArtist = info["Artist"]       as? String ?? ""
        let stateStr  = info["Player State"] as? String ?? ""
        let totalMs   = info["Total Time"]   as? Double ?? 0
        let pid       = info["PersistentID"] as? Int64

        let isNewTrack = pid != currentPersistentID
        let isResume   = stateStr == "Playing" && playbackRate == 0 && !isNewTrack

        title    = newTitle
        artist   = newArtist
        duration = totalMs / 1000.0
        playbackRate = (stateStr == "Playing") ? 1.0 : 0.0
        // Don't touch artwork on pause/resume — only clear it on a genuine track change
        if isNewTrack {
            currentPersistentID = pid
            elapsed = 0
            lastFetchedElapsed = 0
            lastFetchTimestamp = Date()
            Task { await fetchArtworkViaScriptingBridge() }
        } else if isResume {
            // Anchor interpolation from current elapsed at resume time
            lastFetchedElapsed = elapsed
            lastFetchTimestamp = Date()
        }
    }

    // MARK: - AppleScript / Scripting Bridge (initial fetch + elapsed sync)

    /// Fetch current track info via osascript — only works for Music app.
    @MainActor
    private func fetchViaScriptingBridge() async {
        let script = """
        tell application "Music"
            if it is running then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                set trackDuration to duration of current track
                set trackPosition to player position
                set trackState to (player state as string)
                set trackID to database ID of current track
                return trackName & "|||" & trackArtist & "|||" & trackAlbum & "|||" & (trackDuration as string) & "|||" & (trackPosition as string) & "|||" & trackState & "|||" & (trackID as string)
            else
                return "NOT_RUNNING"
            end if
        end tell
        """
        guard let result = runAppleScript(script), result != "NOT_RUNNING" else { return }
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 7 else { return }

        title    = parts[0]
        artist   = parts[1]
        duration = Double(parts[3]) ?? 0
        let pos  = Double(parts[4]) ?? 0
        let stateStr = parts[5]
        let pid  = Int64(parts[6])
        playbackRate = (stateStr == "playing") ? 1.0 : 0.0

        lastFetchedElapsed = pos
        lastFetchTimestamp = Date()
        elapsed = pos

        if pid != currentPersistentID {
            currentPersistentID = pid
            await fetchArtworkViaScriptingBridge()
        }
    }

    @MainActor
    private func syncElapsedViaScriptingBridge() async {
        let script = """
        tell application "Music"
            if it is running then
                return (player position as string)
            else
                return "0"
            end if
        end tell
        """
        guard let result = runAppleScript(script), let pos = Double(result) else { return }
        lastFetchedElapsed = pos
        lastFetchTimestamp = Date()
        elapsed = pos
    }

    @MainActor
    private func fetchArtworkViaScriptingBridge() async {
        let tmpPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("noro_artwork.jpg")
        let script = """
        tell application "Music"
            if it is running then
                try
                    set artData to data of artwork 1 of current track
                    set f to open for access POSIX file "\(tmpPath)" with write permission
                    set eof f to 0
                    write artData to f
                    close access f
                    return "ok"
                on error
                    return "no_art"
                end try
            else
                return "no_art"
            end if
        end tell
        """
        guard let result = runAppleScript(script), result == "ok" else { return }
        if let image = NSImage(contentsOfFile: tmpPath) {
            artwork = image
        }
    }

    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&error)
        if let error { print("[AppleScript] Error: \(error)") }
        return result?.stringValue
    }

    // MARK: - Position interpolation

    private func interpolatedElapsed() -> Double {
        guard playbackRate > 0 else { return lastFetchedElapsed }
        let delta = Date().timeIntervalSince(lastFetchTimestamp)
        return min(duration, lastFetchedElapsed + delta * playbackRate)
    }

    private func startPositionTimer() {
        positionTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.playbackRate > 0 else { return }
                self.elapsed = self.interpolatedElapsed()
            }
    }

    // MARK: - Update check

    private func checkForUpdate() async {
        guard let url = URL(string: Theme.updateManifestURL) else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let text = String(data: data, encoding: .utf8) else { return }
        let lines = text.components(separatedBy: .newlines)
        let latestCode: Int = lines.compactMap { line -> Int? in
            guard line.hasPrefix("VersionCode=") else { return nil }
            return Int(line.dropFirst("VersionCode=".count))
        }.first ?? 0
        let available = latestCode > 10301
        await MainActor.run { self.updateAvailable = available }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    deinit {
        notificationTokens.forEach { DistributedNotificationCenter.default().removeObserver($0) }
    }
}
