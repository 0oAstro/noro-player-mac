import AppKit
import SwiftUI
import NoroPlayerLib

// Render PlayerView offscreen and save as a 1024×1024 PNG.
// Usage: IconRenderer <output-path>

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)

registerCustomFont()

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "AppIcon-1024.png"

@MainActor
func renderIcon(to path: String) {
    let scale: CGFloat = 2
    let view = IconPlayerView()
        .environment(\.displayScale, scale)

    let renderer = ImageRenderer(content: view)
    renderer.scale = scale

    guard let nsImage = renderer.nsImage else {
        fputs("IconRenderer: ImageRenderer produced nil\n", stderr)
        exit(1)
    }

    // Pad to square (shell background) then scale to 1024×1024.
    let src = nsImage.size
    let side = max(src.width, src.height)
    let padX = (side - src.width)  / 2
    let padY = (side - src.height) / 2

    let targetSize = NSSize(width: 1024, height: 1024)
    let out = NSImage(size: targetSize)
    out.lockFocus()
    // Fill background with shell color (#1a1a1a)
    NSColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1).setFill()
    NSRect(origin: .zero, size: targetSize).fill()
    let destRect = NSRect(
        x: padX / side * 1024,
        y: padY / side * 1024,
        width: src.width / side * 1024,
        height: src.height / side * 1024
    )
    nsImage.draw(in: destRect, from: .zero, operation: .sourceOver, fraction: 1)
    out.unlockFocus()

    guard
        let cgImg = out.cgImage(forProposedRect: nil, context: nil, hints: nil),
        let dest  = CGImageDestinationCreateWithURL(
            URL(fileURLWithPath: path) as CFURL,
            "public.png" as CFString, 1, nil
        )
    else {
        fputs("IconRenderer: failed to create image destination\n", stderr)
        exit(1)
    }

    CGImageDestinationAddImage(dest, cgImg, nil)
    guard CGImageDestinationFinalize(dest) else {
        fputs("IconRenderer: failed to write PNG\n", stderr)
        exit(1)
    }

    print("IconRenderer: wrote \(path)")
}

DispatchQueue.main.async {
    renderIcon(to: outputPath)
    exit(0)
}

app.run()
