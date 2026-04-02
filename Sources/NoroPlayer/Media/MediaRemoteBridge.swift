import Foundation
import AppKit

// Keys from MediaRemote's NowPlayingInfo dictionary
public enum MRInfoKey {
    static let title    = "kMRMediaRemoteNowPlayingInfoTitle"
    static let artist   = "kMRMediaRemoteNowPlayingInfoArtist"
    static let duration = "kMRMediaRemoteNowPlayingInfoDuration"
    static let elapsed  = "kMRMediaRemoteNowPlayingInfoElapsedTime"
    static let artwork  = "kMRMediaRemoteNowPlayingInfoArtworkData"
    static let playbackRate = "kMRMediaRemoteNowPlayingInfoPlaybackRate"
    static let timestamp = "kMRMediaRemoteNowPlayingInfoTimestamp"
}

// Commands sent via MRMediaRemoteSendCommand
public enum MRCommand: Int {
    case play          = 0
    case pause         = 1
    case togglePlayPause = 2
    case nextTrack     = 4
    case previousTrack = 5
}

// Notification names — resolved from the framework's exported CFString symbols at runtime.
// The symbol value equals the name string, but resolving via dlsym is the correct approach.
public let kMRMediaRemoteNowPlayingInfoDidChangeNotification            = "kMRMediaRemoteNowPlayingInfoDidChangeNotification"
public let kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification   = "kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification"
public let kMRMediaRemoteNowPlayingApplicationDidChangeNotification     = "kMRMediaRemoteNowPlayingApplicationDidChangeNotification"
public let kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification = "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"

public final class MediaRemoteBridge {
    public static let shared = MediaRemoteBridge()

    // Function pointer types
    private typealias GetNowPlayingInfoFn = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private typealias SendCommandFn = @convention(c) (Int, AnyObject?) -> Bool
    private typealias RegisterForNotificationsFn = @convention(c) (DispatchQueue) -> Void

    private var getNowPlayingInfo: GetNowPlayingInfoFn?
    private var sendCommandFn: SendCommandFn?
    private var registerForNotifications: RegisterForNotificationsFn?

    public private(set) var isLoaded = false

    private init() {
        load()
    }

    private func load() {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY) else {
            print("[MediaRemote] Failed to dlopen: \(String(cString: dlerror()))")
            return
        }

        if let sym = dlsym(handle, "MRMediaRemoteGetNowPlayingInfo") {
            getNowPlayingInfo = unsafeBitCast(sym, to: GetNowPlayingInfoFn.self)
        }
        if let sym = dlsym(handle, "MRMediaRemoteSendCommand") {
            sendCommandFn = unsafeBitCast(sym, to: SendCommandFn.self)
        }
        if let sym = dlsym(handle, "MRMediaRemoteRegisterForNowPlayingNotifications") {
            registerForNotifications = unsafeBitCast(sym, to: RegisterForNotificationsFn.self)
        }

        isLoaded = getNowPlayingInfo != nil
        if isLoaded {
            print("[MediaRemote] Loaded successfully")
        } else {
            print("[MediaRemote] Symbol resolution failed")
        }
    }

    public func fetchNowPlayingInfo(completion: @escaping ([String: Any]) -> Void) {
        guard let fn = getNowPlayingInfo else {
            completion([:])
            return
        }
        fn(.main, completion)
    }

    public func sendCommand(_ command: MRCommand) {
        _ = sendCommandFn?(command.rawValue, nil)
    }

    public func registerForNotifications(queue: DispatchQueue = .main) {
        registerForNotifications?(queue)
    }
}
