import SwiftUI

public struct ControlsRow: View {
    public var isPlaying: Bool
    public var onPrev: () -> Void
    public var onPlayPause: () -> Void
    public var onNext: () -> Void

    public init(isPlaying: Bool, onPrev: @escaping () -> Void, onPlayPause: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.onPrev = onPrev
        self.onPlayPause = onPlayPause
        self.onNext = onNext
    }

    public var body: some View {
        HStack(spacing: Theme.buttonGap) {
            MediaButton(shape: PrevButtonShape(), icon: prevIcon, action: onPrev,
                        highlightLines: ButtonHighlightLines.prev,
                        leftSideEndY: 61.46, rightSideEndY: 90.63)
            MediaButton(shape: PlayButtonShape(), icon: playPauseIcon, action: onPlayPause,
                        highlightLines: ButtonHighlightLines.play,
                        leftSideEndY: 90.63, rightSideEndY: 90.63)
            MediaButton(shape: NextButtonShape(), icon: nextIcon, action: onNext,
                        highlightLines: ButtonHighlightLines.next,
                        leftSideEndY: 90.63, rightSideEndY: 61.46)
        }
    }

    private var prevIcon: Path {
        // Matches Rainmeter PrevIcon: rect bar + left-pointing triangle (24-unit viewBox scaled to iconSize)
        let s = Theme.iconSize / 24
        var p = Path()
        p.addRect(CGRect(x: 7 * s, y: 7 * s, width: 2.333 * s, height: 14 * s))
        p.move(to: CGPoint(x: 11.083 * s, y: 14 * s))
        p.addLine(to: CGPoint(x: 21 * s, y: 21 * s))
        p.addLine(to: CGPoint(x: 21 * s, y: 7 * s))
        p.closeSubpath()
        return p
    }

    private var playPauseIcon: Path {
        let s = Theme.iconSize / 24
        var p = Path()
        if isPlaying {
            // Pause: two vertical bars
            p.addRect(CGRect(x: 7 * s, y: 5.833 * s, width: 4.667 * s, height: 16.333 * s))
            p.addRect(CGRect(x: 16.333 * s, y: 5.833 * s, width: 4.667 * s, height: 16.333 * s))
        } else {
            // Play: right-pointing triangle
            p.move(to: CGPoint(x: 9.333 * s, y: 5.833 * s))
            p.addLine(to: CGPoint(x: 9.333 * s, y: 22.167 * s))
            p.addLine(to: CGPoint(x: 22.167 * s, y: 14 * s))
            p.closeSubpath()
        }
        return p
    }

    private var nextIcon: Path {
        let s = Theme.iconSize / 24
        var p = Path()
        p.move(to: CGPoint(x: 7 * s, y: 21 * s))
        p.addLine(to: CGPoint(x: 16.917 * s, y: 14 * s))
        p.addLine(to: CGPoint(x: 7 * s, y: 7 * s))
        p.closeSubpath()
        p.addRect(CGRect(x: 18.667 * s, y: 7 * s, width: 2.333 * s, height: 14 * s))
        return p
    }
}

// Highlight lines matching Rainmeter's explicit line segments (not a full perimeter stroke).
// Each button gets different segments since Prev/Next have partial sides due to the large arc.
private enum ButtonHighlightLines {
    // 100-unit canvas, 1pt inset from each edge
    // top edge, left side (full), right side (full) — Play button
    static func play(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var p = Path()
        // top edge
        p.move(to: CGPoint(x: 9.38 * s, y: 1.04 * s))
        p.addLine(to: CGPoint(x: 90.63 * s, y: 1.04 * s))
        // left side
        p.move(to: CGPoint(x: 1.04 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 1.04 * s, y: 90.63 * s))
        // right side
        p.move(to: CGPoint(x: 98.96 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 98.96 * s, y: 90.63 * s))
        return p.offsetBy(dx: rect.minX, dy: rect.minY)
    }

    // Prev: left side stops at y≈61.46 (before the large bottom-left arc tangent at y=62.5)
    static func prev(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var p = Path()
        // top edge
        p.move(to: CGPoint(x: 9.38 * s, y: 1.04 * s))
        p.addLine(to: CGPoint(x: 90.63 * s, y: 1.04 * s))
        // left side — stops before large bottom-left arc
        p.move(to: CGPoint(x: 1.04 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 1.04 * s, y: 61.46 * s))
        // right side — full
        p.move(to: CGPoint(x: 98.96 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 98.96 * s, y: 90.63 * s))
        return p.offsetBy(dx: rect.minX, dy: rect.minY)
    }

    // Next: right side stops at y≈61.46 (before the large bottom-right arc tangent at y=62.5)
    static func next(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var p = Path()
        // top edge
        p.move(to: CGPoint(x: 9.38 * s, y: 1.04 * s))
        p.addLine(to: CGPoint(x: 90.63 * s, y: 1.04 * s))
        // left side — full
        p.move(to: CGPoint(x: 1.04 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 1.04 * s, y: 90.63 * s))
        // right side — stops before large bottom-right arc
        p.move(to: CGPoint(x: 98.96 * s, y: 9.38 * s))
        p.addLine(to: CGPoint(x: 98.96 * s, y: 61.46 * s))
        return p.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

private struct MediaButton<S: Shape>: View {
    let shape: S
    let icon: Path
    let action: () -> Void
    // Closure producing the inset highlight line segments for this button shape
    let highlightLines: (CGRect) -> Path

    @State private var isPressed = false

    var body: some View {
        ZStack {
            shape
                .fill(isPressed ? Theme.buttonPressedFill : Theme.buttonFill)
            // Outer stroke
            shape
                .stroke(Theme.buttonStroke, lineWidth: 1)
            // Inset highlight lines matching Rainmeter's explicit line segments.
            // Top edge uses buttonHighlightEdge (a=13); sides use buttonHighlightSide (a=7).
            // On press, both collapse to buttonPressedEdge (dark inset shadow).
            GeometryReader { geo in
                let r = CGRect(origin: .zero, size: geo.size)
                if isPressed {
                    highlightLines(r)
                        .stroke(Theme.buttonPressedEdge, lineWidth: 1)
                } else {
                    // Top edge segment (first move+line in each helper = top edge)
                    topEdgePath(in: r)
                        .stroke(Theme.buttonHighlightEdge, lineWidth: 1)
                    // Side segments
                    sideEdgePaths(in: r)
                        .stroke(Theme.buttonHighlightSide, lineWidth: 1)
                }
            }
            // Icon
            icon
                .fill(isPressed ? Theme.iconPressedColor : Theme.iconColor)
                .frame(width: Theme.iconSize, height: Theme.iconSize)
        }
        .frame(width: Theme.buttonWidth, height: Theme.buttonHeight)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    action()
                }
        )
    }

    // Extract only the top edge line (first segment) from the highlight path
    private func topEdgePath(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var p = Path()
        p.move(to: CGPoint(x: 9.38 * s + rect.minX, y: 1.04 * s + rect.minY))
        p.addLine(to: CGPoint(x: 90.63 * s + rect.minX, y: 1.04 * s + rect.minY))
        return p
    }

    // Side lines only (left + right, no top edge)
    private func sideEdgePaths(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var p = Path()
        let leftEnd = leftSideEndY(s: s, rect: rect)
        p.move(to: CGPoint(x: 1.04 * s + rect.minX, y: 9.38 * s + rect.minY))
        p.addLine(to: CGPoint(x: 1.04 * s + rect.minX, y: leftEnd))
        let rightEnd = rightSideEndY(s: s, rect: rect)
        p.move(to: CGPoint(x: 98.96 * s + rect.minX, y: 9.38 * s + rect.minY))
        p.addLine(to: CGPoint(x: 98.96 * s + rect.minX, y: rightEnd))
        return p
    }

    // These are overridden per button via the highlightLines closure indirectly;
    // we decode the end-y from the closure's shape type via stored values.
    private let leftSideEndYValue: CGFloat
    private let rightSideEndYValue: CGFloat

    init(shape: S, icon: Path, action: @escaping () -> Void,
         highlightLines: @escaping (CGRect) -> Path,
         leftSideEndY: CGFloat, rightSideEndY: CGFloat) {
        self.shape = shape
        self.icon = icon
        self.action = action
        self.highlightLines = highlightLines
        self.leftSideEndYValue = leftSideEndY
        self.rightSideEndYValue = rightSideEndY
    }

    private func leftSideEndY(s: CGFloat, rect: CGRect) -> CGFloat {
        leftSideEndYValue * s + rect.minY
    }
    private func rightSideEndY(s: CGFloat, rect: CGRect) -> CGFloat {
        rightSideEndYValue * s + rect.minY
    }
}
