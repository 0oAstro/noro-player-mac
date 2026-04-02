import Testing
import SwiftUI
@testable import NoroPlayerLib

// MARK: - Theme Tests
@Test func themeShellDimensions() {
    #expect(Theme.shellWidth == 340)
    #expect(Theme.shellHeight == 356)
    #expect(Theme.shellRadius == 51)
}

@Test func themeScreenDimensions() {
    #expect(Theme.screenWidth == 312)
    #expect(Theme.screenHeight == 188)
    #expect(Theme.screenX == 14)
    #expect(Theme.screenY == 14)
    #expect(Theme.screenRadiusTop == 36)
    #expect(Theme.screenRadiusBottom == 4)
}

@Test func themeButtonLayout() {
    // Three buttons + two gaps should fill grille width
    let totalButtons = Theme.buttonWidth * 3 + Theme.buttonGap * 2
    #expect(totalButtons == Theme.grilleWidth)
}

@Test func themeGrainAlpha() {
    // GrainAlpha=7.2 maps to 7.2/255 ≈ 0.0282
    #expect(abs(Theme.grainAlpha - 7.2 / 255.0) < 0.0001)
}

// MARK: - Shape Tests
@Test func screenClipShapeBounds() {
    let shape = ScreenClipShape()
    let rect = CGRect(x: 0, y: 0, width: Theme.screenWidth, height: Theme.screenHeight)
    let path = shape.path(in: rect)
    let bounds = path.boundingRect
    // Path should be contained within the given rect
    #expect(bounds.width <= rect.width)
    #expect(bounds.height <= rect.height)
    // And not be empty
    #expect(bounds.width > 0)
    #expect(bounds.height > 0)
}

@Test func prevButtonShapeBounds() {
    let shape = PrevButtonShape()
    let rect = CGRect(x: 0, y: 0, width: Theme.buttonWidth, height: Theme.buttonHeight)
    let path = shape.path(in: rect)
    let bounds = path.boundingRect
    #expect(bounds.width > 0)
    #expect(bounds.height > 0)
    #expect(bounds.maxX <= rect.width + 1)  // +1 for floating point
    #expect(bounds.maxY <= rect.height + 1)
}

@Test func nextButtonShapeBounds() {
    let shape = NextButtonShape()
    let rect = CGRect(x: 0, y: 0, width: Theme.buttonWidth, height: Theme.buttonHeight)
    let path = shape.path(in: rect)
    let bounds = path.boundingRect
    #expect(bounds.width > 0)
    #expect(bounds.height > 0)
    #expect(bounds.maxX <= rect.width + 1)
    #expect(bounds.maxY <= rect.height + 1)
}

// MARK: - MediaRemote Bridge Tests
@Test func mediaRemoteBridgeLoads() {
    // This will succeed on macOS; the framework is always present
    #expect(MediaRemoteBridge.shared.isLoaded == true)
}
