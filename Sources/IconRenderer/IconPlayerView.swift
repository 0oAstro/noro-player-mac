import SwiftUI
import NoroPlayerLib

// A static snapshot of PlayerView for icon rendering.
// Replaces NSView-backed SeekBarNSView with a pure SwiftUI bar,
// and adds pixelated eyes to the screen area.
struct IconPlayerView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .fill(Theme.shellColor)
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .strokeBorder(Theme.shellHighlight, lineWidth: 1)
                .padding(1)
            RoundedRectangle(cornerRadius: Theme.shellRadius)
                .strokeBorder(Theme.shellStroke, lineWidth: 1)

            VStack(spacing: 0) {
                IconScreenView()
                    .padding(.top, Theme.screenY)
                    .padding(.horizontal, Theme.screenX)

                GrilleView()
                    .padding(.top, Theme.grilleY - (Theme.screenY + Theme.screenHeight))
                    .padding(.horizontal, Theme.grilleX)

                ControlsRow(
                    isPlaying: false,
                    onPrev: {}, onPlayPause: {}, onNext: {}
                )
                .padding(.top, Theme.buttonY - (Theme.grilleY + Theme.grilleHeight))
                .padding(.horizontal, Theme.button1X)

                Spacer()
            }
        }
        .frame(width: Theme.shellWidth, height: Theme.shellHeight)
    }
}

// Screen with pure SwiftUI progress bar and pixelated eyes.
private struct IconScreenView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScreenClipShape()
                .fill(Theme.screenFallback)

            // Grid overlay
            Canvas { ctx, size in
                let step: CGFloat = 12
                var x: CGFloat = step
                while x < size.width {
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: 0))
                    line.addLine(to: CGPoint(x: x, y: size.height))
                    ctx.stroke(line, with: .color(Theme.gridColor), lineWidth: 1)
                    x += step
                }
                var y: CGFloat = step
                while y < size.height {
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: size.width, y: y))
                    ctx.stroke(line, with: .color(Theme.gridColor), lineWidth: 1)
                    y += step
                }
            }
            .clipShape(ScreenClipShape())

            // Dark gradient
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

            // Pixelated eyes — centered in screen
            PixelEyes()

            // Bottom row: elapsed | title | clock
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .center, spacing: 0) {
                    Text("0:00")
                        .font(.custom(Theme.displayFont, size: 12))
                        .foregroundColor(Theme.textColor)
                        .frame(width: Theme.elapsedMeterW, alignment: .leading)
                        .padding(.leading, Theme.elapsedX - Theme.screenX)

                    Spacer()

                    Text("NORO PLAYER")
                        .font(.custom(Theme.displayFont, size: 11).weight(.medium))
                        .foregroundColor(Theme.textColor)
                        .tracking(0.8)
                        .lineLimit(1)

                    Spacer()

                    Text("1:00 AM")
                        .font(.custom(Theme.displayFont, size: 12))
                        .foregroundColor(Theme.textColor)
                        .frame(width: Theme.clockMeterW, alignment: .trailing)
                        .padding(.trailing, (Theme.screenX + Theme.screenWidth) - Theme.clockX)
                }
                .frame(height: Theme.titleAreaHeight)
                .padding(.bottom, Theme.screenHeight - Theme.infoY)

                // Pure SwiftUI progress bar — no NSView
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Theme.progressBase)
                            .frame(height: Theme.progressHeight)
                        Rectangle()
                            .fill(Theme.progressFill)
                            .frame(width: geo.size.width * 0.38, height: Theme.progressHeight)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: 20)
            }
        }
        .frame(width: Theme.screenWidth, height: Theme.screenHeight)
    }
}

// Kawaii pixel face: UwU closed eyes + rosy cheeks.
// 1 = white, 2 = pink cheek, 0 = off
private struct PixelEyes: View {
    // Closed happy eye: arc shape (^)
    private let eye: [[Int]] = [
        [0, 1, 1, 0],
        [1, 0, 0, 1],
        [1, 0, 0, 0],
    ]

    // Rosy cheek: small 3×2 blush patch
    private let cheek: [[Int]] = [
        [1, 1, 1],
        [1, 1, 1],
    ]

    var body: some View {
        Canvas { ctx, size in
            let px: CGFloat = 8
            let eyeW  = CGFloat(eye[0].count)  * px
            let eyeH  = CGFloat(eye.count)     * px
            let gap: CGFloat = 48
            let totalW = eyeW * 2 + gap
            let originX = (size.width  - totalW) / 2
            let originY = (size.height - eyeH)   / 2 - 14

            let white = Theme.textColor
            let pink  = Color(red: 1, green: 0.55, blue: 0.6)

            // Draw both eyes
            for offsetX in [originX, originX + eyeW + gap] {
                for (row, cols) in eye.enumerated() {
                    for (col, val) in cols.enumerated() {
                        guard val == 1 else { continue }
                        ctx.fill(
                            Path(CGRect(x: offsetX + CGFloat(col)*px,
                                        y: originY + CGFloat(row)*px,
                                        width: px, height: px)),
                            with: .color(white)
                        )
                    }
                }
            }

            // Cheeks — below each eye, inset slightly
            let cheekW = CGFloat(cheek[0].count) * px
            let cheekH = CGFloat(cheek.count)    * px
            let cheekY = originY + eyeH + px
            let leftCheekX  = originX
            let rightCheekX = originX + eyeW + gap + eyeW - cheekW

            for offsetX in [leftCheekX, rightCheekX] {
                for (row, cols) in cheek.enumerated() {
                    for (col, val) in cols.enumerated() {
                        guard val == 1 else { continue }
                        ctx.fill(
                            Path(CGRect(x: offsetX + CGFloat(col)*px,
                                        y: cheekY  + CGFloat(row)*px,
                                        width: px, height: px)),
                            with: .color(pink)
                        )
                    }
                }
            }
            _ = cheekH
        }
        .frame(width: Theme.screenWidth, height: Theme.screenHeight)
    }
}
