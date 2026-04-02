import SwiftUI

// Screen area: top corners r=36, bottom corners r=4 (matches Rainmeter ScreenOuter path)
public struct ScreenClipShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: rect,
            cornerRadii: RectangleCornerRadii(
                topLeading: Theme.screenRadiusTop,
                bottomLeading: Theme.screenRadiusBottom,
                bottomTrailing: Theme.screenRadiusBottom,
                topTrailing: Theme.screenRadiusTop
            ),
            style: .circular
        )
    }
}
