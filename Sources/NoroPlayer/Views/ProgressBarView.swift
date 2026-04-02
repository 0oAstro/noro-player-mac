import SwiftUI
import AppKit

public struct ProgressBarView: View {
    public var progress: Double
    public var onSeek: ((Double) -> Void)?

    @State private var dragProgress: Double? = nil

    public init(progress: Double, onSeek: ((Double) -> Void)? = nil) {
        self.progress = progress
        self.onSeek = onSeek
    }

    private var displayProgress: Double { dragProgress ?? progress }

    public var body: some View {
        SeekBarNSView(
            progress: displayProgress,
            onChanged: { p in dragProgress = p },
            onEnded: { p in
                dragProgress = nil
                onSeek?(p)
            }
        )
        .frame(height: 20) // tall invisible hit area, bar is drawn inside
    }
}

/// NSView-backed seek bar: handles cursor, mouseDown drag, and renders the bar itself.
private struct SeekBarNSView: NSViewRepresentable {
    var progress: Double
    var onChanged: (Double) -> Void
    var onEnded: (Double) -> Void

    func makeNSView(context: Context) -> SeekNSViewImpl {
        let v = SeekNSViewImpl()
        v.onChanged = onChanged
        v.onEnded = onEnded
        v.progress = progress
        return v
    }

    func updateNSView(_ nsView: SeekNSViewImpl, context: Context) {
        nsView.progress = progress
        nsView.onChanged = onChanged
        nsView.onEnded = onEnded
        nsView.needsDisplay = true
    }
}

final class SeekNSViewImpl: NSView {
    var progress: Double = 0 { didSet { needsDisplay = true } }
    var onChanged: ((Double) -> Void)?
    var onEnded: ((Double) -> Void)?

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let ta = trackingArea { removeTrackingArea(ta) }
        let ta = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self, userInfo: nil
        )
        addTrackingArea(ta)
        trackingArea = ta
    }

    override func mouseEntered(with event: NSEvent) { NSCursor.pointingHand.push() }
    override func mouseExited(with event: NSEvent)  { NSCursor.pop() }

    override func mouseDown(with event: NSEvent) {
        let p = clamp(convert(event.locationInWindow, from: nil).x / bounds.width)
        onChanged?(p)
    }

    override func mouseDragged(with event: NSEvent) {
        let p = clamp(convert(event.locationInWindow, from: nil).x / bounds.width)
        onChanged?(p)
    }

    override func mouseUp(with event: NSEvent) {
        let p = clamp(convert(event.locationInWindow, from: nil).x / bounds.width)
        onEnded?(p)
    }

    private func clamp(_ v: Double) -> Double { max(0, min(1, v)) }

    // Draw the bar directly so it's always in sync with progress (no SwiftUI layout round-trip)
    override func draw(_ dirtyRect: NSRect) {
        let barH: CGFloat = Theme.progressHeight
        let barY = (bounds.height - barH) / 2
        let barRect = NSRect(x: 0, y: barY, width: bounds.width, height: barH)

        // Base
        Theme.progressBase.nsColor.setFill()
        NSBezierPath(rect: barRect).fill()

        // Fill
        let fillRect = NSRect(x: 0, y: barY, width: bounds.width * progress, height: barH)
        Theme.progressFill.nsColor.setFill()
        NSBezierPath(rect: fillRect).fill()
    }
}

private extension Color {
    var nsColor: NSColor { NSColor(self) }
}
