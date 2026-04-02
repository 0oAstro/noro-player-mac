import SwiftUI

// All values ported directly from NoroPlayer/@Resources/Variables.inc
public enum Theme {
    // MARK: - Shell
    public static let shellWidth: CGFloat = 340
    public static let shellHeight: CGFloat = 356
    public static let shellRadius: CGFloat = 51
    public static let grainAlpha: Double = 7.2 / 255.0

    // MARK: - Screen
    public static let screenX: CGFloat = 14
    public static let screenY: CGFloat = 14
    public static let screenWidth: CGFloat = 312
    public static let screenHeight: CGFloat = 188
    public static let screenRadiusTop: CGFloat = 36
    public static let screenRadiusBottom: CGFloat = 4

    // MARK: - Title / Info row (within screen, relative coords)
    public static let titleAreaY: CGFloat = 170  // from screen top
    public static let titleAreaHeight: CGFloat = 20
    public static let elapsedMeterW: CGFloat = 72
    public static let clockMeterW: CGFloat = 88
    public static let infoY: CGFloat = 184       // from screen top
    public static let elapsedX: CGFloat = 26     // from screen left
    public static let statusTopY: CGFloat = 42   // from screen top
    public static let clockX: CGFloat = 314      // right edge (screen right = screenX + screenWidth = 326, clockX from shell left)

    // MARK: - Record dot (relative to screen)
    public static let recordDotInsetX: CGFloat = 24
    public static let recordDotInsetY: CGFloat = 22
    public static let recordDotSize: CGFloat = 10

    // MARK: - Update badge (relative to screen)
    public static let updateBadgeX: CGFloat = 18
    public static let updateBadgeY: CGFloat = 16
    public static let updateBadgeWidth: CGFloat = 70
    public static let updateBadgeHeight: CGFloat = 18
    public static let updateBadgeRadius: CGFloat = 9

    // MARK: - Progress bar
    public static let progressHeight: CGFloat = 3

    // MARK: - Grille
    public static let grilleX: CGFloat = 14
    public static let grilleY: CGFloat = 212
    public static let grilleWidth: CGFloat = 312
    public static let grilleHeight: CGFloat = 24

    // MARK: - Buttons
    public static let buttonY: CGFloat = 240
    public static let buttonGap: CGFloat = 6
    public static let buttonWidth: CGFloat = 100
    public static let buttonHeight: CGFloat = 100
    public static let buttonRadius: CGFloat = 8
    public static let button1X: CGFloat = 14
    public static let button2X: CGFloat = 120
    public static let button3X: CGFloat = 226
    public static let iconSize: CGFloat = 28

    // MARK: - Font
    public static let displayFont = "CozetteVector"

    // MARK: - URLs
    public static let updateManifestURL = "https://raw.githubusercontent.com/SunkenInTime/noro-player/master/latest.ini"
    public static let latestDownloadURL = "https://github.com/SunkenInTime/noro-player/releases/latest/download/NoroPlayer.rmskin"

    // MARK: - Colors
    public static let shellColor    = Color(r: 26,  g: 26,  b: 26,  a: 255)
    public static let shellStroke   = Color(r: 0,   g: 0,   b: 0,   a: 255)
    public static let shellHighlight = Color(r: 255, g: 255, b: 255, a: 26)

    public static let screenFrameColor = Color(r: 0,   g: 0,   b: 0,   a: 255)
    public static let screenStroke     = Color(r: 0,   g: 0,   b: 0,   a: 255)
    public static let screenHighlight  = Color(r: 255, g: 255, b: 255, a: 26)
    public static let screenFallback   = Color(r: 0,   g: 0,   b: 0,   a: 255)

    public static let gridColor = Color(r: 255, g: 255, b: 255, a: 10)

    public static let textColor        = Color(r: 255, g: 255, b: 255, a: 255)
    public static let iconColor        = Color(r: 208, g: 208, b: 208, a: 255)
    public static let recordColor      = Color(r: 255, g: 59,  b: 48,  a: 255)

    public static let updateBadgeFill      = Color(r: 0,   g: 0,   b: 0,   a: 170)
    public static let updateBadgeStroke    = Color(r: 255, g: 59,  b: 48,  a: 210)
    public static let updateBadgeTextColor = Color(r: 255, g: 255, b: 255, a: 255)

    public static let progressBase = Color(r: 255, g: 255, b: 255, a: 13)
    public static let progressFill = Color(r: 255, g: 255, b: 255, a: 255)

    public static let grilleFill   = Color(r: 26,  g: 26,  b: 26,  a: 255)
    public static let grilleStroke = Color(r: 0,   g: 0,   b: 0,   a: 255)
    public static let grilleDotTint = Color(r: 0,  g: 0,   b: 0,   a: 165)

    public static let buttonFill        = Color(r: 26,  g: 26,  b: 26,  a: 255)
    public static let buttonStroke      = Color(r: 10,  g: 10,  b: 10,  a: 255)
    public static let buttonHighlightEdge = Color(r: 255, g: 255, b: 255, a: 13)
    public static let buttonHighlightSide = Color(r: 255, g: 255, b: 255, a: 7)
    public static let buttonPressedEdge = Color(r: 0,   g: 0,   b: 0,   a: 77)
    public static let buttonPressedSide = Color(r: 0,   g: 0,   b: 0,   a: 38)
    public static let buttonPressedFill = Color(r: 20,  g: 20,  b: 20,  a: 255)
    public static let iconPressedColor  = Color(r: 182, g: 182, b: 182, a: 255)
}

// Convenience init: Rainmeter uses 0-255 RGBA
private extension Color {
    init(r: Double, g: Double, b: Double, a: Double) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, opacity: a / 255)
    }
}
