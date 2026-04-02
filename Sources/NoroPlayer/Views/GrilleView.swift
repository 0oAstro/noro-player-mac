import SwiftUI
import AppKit

public struct GrilleView: View {
    public init() {}
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.grilleFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Theme.grilleStroke, lineWidth: 1)
                )
            // Tiled dot pattern — 2x1pt dark dot per 4x4pt cell, matching GrilleTile.png layout.
            // Drawn procedurally to guarantee correct tiling without bundle-loading the PNG.
            GrilleDotPattern(tint: Theme.grilleDotTint)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(width: Theme.grilleWidth, height: Theme.grilleHeight)
    }
}

// Pure-SwiftUI dot grid: replicates the 4x4 GrilleTile.png tile
// (2x1 white dot at top-left of each cell, tinted to grilleDotTint).
private struct GrilleDotPattern: View {
    let tint: Color

    var body: some View {
        Canvas { ctx, size in
            let dotW: CGFloat = 2
            let dotH: CGFloat = 1
            let stepX: CGFloat = 4
            let stepY: CGFloat = 4

            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    ctx.fill(
                        Path(CGRect(x: x, y: y, width: dotW, height: dotH)),
                        with: .color(tint)
                    )
                    y += stepY
                }
                x += stepX
            }
        }
    }
}

// TiledImageView kept for GrainTile usage in PlayerView (grain overlay, not grille dots).
public struct TiledImageView: NSViewRepresentable {
    public let image: NSImage
    public let tint: Color

    public init(image: NSImage, tint: Color) { self.image = image; self.tint = tint }
    public func makeNSView(context: Context) -> TilingNSView {
        TilingNSView(image: image, tint: tint)
    }
    public func updateNSView(_ view: TilingNSView, context: Context) {
        view.patternImage = image
        view.tintColor = tint
        view.needsDisplay = true
    }
}

// NSView subclass that tiles an image using NSColor(patternImage:).
public class TilingNSView: NSView {
    var patternImage: NSImage
    var tintColor: Color

    init(image: NSImage, tint: Color) {
        self.patternImage = image
        self.tintColor = tint
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }

    override public func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        // Tile via pattern color
        let tinted = tintedImage(patternImage)
        NSColor(patternImage: tinted).setFill()
        // Flip pattern to match top-left origin convention
        ctx.saveGState()
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)
        NSBezierPath(rect: bounds).fill()
        ctx.restoreGState()
    }

    private func tintedImage(_ source: NSImage) -> NSImage {
        let size = source.size
        let out = NSImage(size: size)
        out.lockFocus()
        source.draw(in: NSRect(origin: .zero, size: size))
        NSColor(tintColor).set()
        NSRect(origin: .zero, size: size).fill(using: .sourceAtop)
        out.unlockFocus()
        return out
    }
}
