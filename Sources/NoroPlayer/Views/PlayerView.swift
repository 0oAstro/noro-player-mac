import SwiftUI
import AppKit

public struct PlayerView: View {
    public init() {}
    @StateObject private var nowPlaying = NowPlayingService()

    @State private var playingDotAlpha: Double = 0.8
    @State private var clockText: String = ""
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public var body: some View {
        ZStack {
            // Shell background
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .fill(Theme.shellColor)
            // Inner highlight ring
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .strokeBorder(Theme.shellHighlight, lineWidth: 1)
                .padding(1)
            // Outer stroke
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .strokeBorder(Theme.shellStroke, lineWidth: 1)

            VStack(spacing: 0) {
                // Screen area
                ScreenView(
                    artwork: nowPlaying.artwork,
                    title: nowPlaying.title,
                    elapsed: nowPlaying.elapsedFormatted,
                    clock: clockText,
                    state: nowPlaying.playbackState,
                    progress: nowPlaying.progress,
                    playingDotAlpha: $playingDotAlpha,
                    showUpdateBadge: nowPlaying.updateAvailable,
                    onOpenPlayer: { nowPlaying.openPlayer() },
                    onUpdateTap: { openURL(Theme.latestDownloadURL) },
                    onSeek: { nowPlaying.seek(to: $0) },
                    trackChangeDirection: nowPlaying.trackChangeDirection
                )
                .padding(.top, Theme.screenY)
                .padding(.horizontal, Theme.screenX)

                // Grille
                GrilleView()
                    .padding(.top, Theme.grilleY - (Theme.screenY + Theme.screenHeight))
                    .padding(.horizontal, Theme.grilleX)

                // Controls
                ControlsRow(
                    isPlaying: nowPlaying.playbackState == .playing,
                    onPrev:      { nowPlaying.sendCommand(.previousTrack) },
                    onPlayPause: { nowPlaying.sendCommand(.togglePlayPause) },
                    onNext:      { nowPlaying.sendCommand(.nextTrack) }
                )
                .padding(.top, Theme.buttonY - (Theme.grilleY + Theme.grilleHeight))
                .padding(.horizontal, Theme.button1X)

                Spacer()
            }

            // Grain overlay (full shell)
            if let grain = NSImage(named: "GrainTile") {
                TiledImageView(image: grain, tint: Color.clear)
                    .opacity(Theme.grainAlpha)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.shellRadius))
                    .allowsHitTesting(false)
            }
        }
        .frame(width: Theme.shellWidth, height: Theme.shellHeight)
        .onReceive(clockTimer) { _ in
            clockText = formattedClock()
        }
        .onAppear {
            clockText = formattedClock()
            startPulse()
            nowPlaying.refresh()
        }
    }

    private func formattedClock() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: Date())
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            playingDotAlpha = 0.27
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
