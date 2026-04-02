import SwiftUI
import AppKit

public enum PlaybackState {
    case standby, playing, paused
}

public struct ScreenView: View {
    public var artwork: NSImage?
    public var title: String
    public var elapsed: String
    public var clock: String
    public var state: PlaybackState
    public var progress: Double
    @Binding public var playingDotAlpha: Double
    public var showUpdateBadge: Bool
    public var onOpenPlayer: () -> Void
    public var onUpdateTap: () -> Void
    public var onSeek: (Double) -> Void
    public var trackChangeDirection: Int  // -1 prev, 0 initial, +1 next

    @State private var displayedArtwork: NSImage? = nil
    @State private var previousArtwork: NSImage? = nil
    @State private var crossfadeOpacity: Double = 0

    public init(artwork: NSImage?, title: String, elapsed: String, clock: String, state: PlaybackState, progress: Double, playingDotAlpha: Binding<Double>, showUpdateBadge: Bool, onOpenPlayer: @escaping () -> Void, onUpdateTap: @escaping () -> Void, onSeek: @escaping (Double) -> Void, trackChangeDirection: Int) {
        self.artwork = artwork
        self.title = title
        self.elapsed = elapsed
        self.clock = clock
        self.state = state
        self.progress = progress
        self._playingDotAlpha = playingDotAlpha
        self.showUpdateBadge = showUpdateBadge
        self.onOpenPlayer = onOpenPlayer
        self.onUpdateTap = onUpdateTap
        self.onSeek = onSeek
        self.trackChangeDirection = trackChangeDirection
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Fallback background
            ScreenClipShape()
                .fill(Theme.screenFallback)

            // Artwork crossfade container — clipped once so nothing leaks during animation
            ZStack {
                if let prev = previousArtwork {
                    artworkImage(prev)
                        .opacity((1 - crossfadeOpacity) * 230.0 / 255.0)
                }
                if let cur = displayedArtwork {
                    artworkImage(cur)
                        .opacity(crossfadeOpacity * 230.0 / 255.0)
                        .saturation(state == .paused ? 0 : 1)
                        .animation(.easeInOut(duration: 0.4), value: state == .paused)
                }
            }
            .clipShape(ScreenClipShape())

            // Dark gradient tint (bottom-heavy)
            ScreenClipShape()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.black.opacity(179.0/255), location: 0.0),
                            .init(color: Color.black.opacity(51.0/255),  location: 0.5),
                            .init(color: Color.clear,                    location: 1.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )

            // Grid overlay
            Canvas { ctx, size in
                let gridColor = Theme.gridColor
                let step: CGFloat = 12
                var x: CGFloat = step
                while x < size.width {
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: 0))
                    line.addLine(to: CGPoint(x: x, y: size.height))
                    ctx.stroke(line, with: .color(gridColor), lineWidth: 1)
                    x += step
                }
                var y: CGFloat = step
                while y < size.height {
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: size.width, y: y))
                    ctx.stroke(line, with: .color(gridColor), lineWidth: 1)
                    y += step
                }
            }
            .clipShape(ScreenClipShape())

            // Status text (PAUSED / STANDBY) — top-right
            VStack {
                HStack {
                    Spacer()
                    if state == .paused {
                        Text("PAUSED")
                            .font(.custom(Theme.displayFont, size: 9).weight(.semibold))
                            .foregroundColor(Theme.textColor)
                            .tracking(0.5)
                    } else if state == .standby {
                        Text("STANDBY")
                            .font(.custom(Theme.displayFont, size: 9).weight(.semibold))
                            .foregroundColor(Theme.textColor)
                            .tracking(0.5)
                    }
                }
                .frame(height: 20)
                .padding(.top, Theme.statusTopY - 14)
                .padding(.horizontal, Theme.screenWidth - Theme.clockX + Theme.screenX)
                Spacer()
            }

            // Playing red dot — top-right
            if state == .playing {
                Circle()
                    .fill(Color(red: 1, green: 59/255, blue: 48/255, opacity: playingDotAlpha))
                    .frame(width: Theme.recordDotSize, height: Theme.recordDotSize)
                    .position(
                        x: Theme.screenWidth - Theme.recordDotInsetX,
                        y: Theme.recordDotInsetY
                    )
            }

            // Update badge — top-left inside screen
            if showUpdateBadge {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.updateBadgeRadius)
                        .fill(Theme.updateBadgeFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.updateBadgeRadius)
                                .strokeBorder(Theme.updateBadgeStroke, lineWidth: 1)
                        )
                    Text("UPDATE")
                        .font(.custom(Theme.displayFont, size: 8).weight(.semibold))
                        .foregroundColor(Theme.updateBadgeTextColor)
                        .tracking(0.6)
                }
                .frame(width: Theme.updateBadgeWidth, height: Theme.updateBadgeHeight)
                .position(
                    x: Theme.updateBadgeX + Theme.updateBadgeWidth / 2,
                    y: Theme.updateBadgeY + Theme.updateBadgeHeight / 2
                )
                .onTapGesture { onUpdateTap() }
            }

            // Bottom info row: elapsed | title | clock
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .center, spacing: 0) {
                    Text(elapsed)
                        .font(.custom(Theme.displayFont, size: 12))
                        .foregroundColor(Theme.textColor)
                        .frame(width: Theme.elapsedMeterW, alignment: .leading)
                        .padding(.leading, Theme.elapsedX - Theme.screenX)

                    Spacer()

                    if state == .standby {
                        Text("OPEN PLAYER")
                            .font(.custom(Theme.displayFont, size: 11).weight(.medium))
                            .foregroundColor(Theme.textColor)
                            .tracking(0.8)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .onTapGesture { onOpenPlayer() }
                    } else {
                        Text(title)
                            .font(.custom(Theme.displayFont, size: 11).weight(.medium))
                            .foregroundColor(Theme.textColor)
                            .tracking(0.8)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .textCase(.uppercase)
                            .onTapGesture { onOpenPlayer() }
                            .id(title)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.25), value: title)
                    }

                    Spacer()

                    Text(clock)
                        .font(.custom(Theme.displayFont, size: 12))
                        .foregroundColor(Theme.textColor)
                        .frame(width: Theme.clockMeterW, alignment: .trailing)
                        .padding(.trailing, (Theme.screenX + Theme.screenWidth) - Theme.clockX)
                }
                .frame(height: Theme.titleAreaHeight)
                .padding(.bottom, Theme.screenHeight - Theme.infoY)

                ProgressBarView(progress: progress, onSeek: onSeek)
            }
        }
        .frame(width: Theme.screenWidth, height: Theme.screenHeight)
        .onAppear {
            displayedArtwork = artwork
            crossfadeOpacity = 1
        }
        .onChange(of: artwork.map { ObjectIdentifier($0) }) { _, _ in
            guard let newImg = artwork else { return }
            if let cur = displayedArtwork, ObjectIdentifier(cur) == ObjectIdentifier(newImg) { return }
            previousArtwork = displayedArtwork
            crossfadeOpacity = 0
            displayedArtwork = newImg
            withAnimation(.easeInOut(duration: 0.4)) {
                crossfadeOpacity = 1
            }
        }
        .onTapGesture(count: 2) { onOpenPlayer() }
    }

    @ViewBuilder
    private func artworkImage(_ img: NSImage) -> some View {
        Image(nsImage: img)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: Theme.screenWidth, height: Theme.screenHeight)
    }
}
