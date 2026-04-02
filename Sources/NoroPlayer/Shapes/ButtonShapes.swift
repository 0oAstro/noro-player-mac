import SwiftUI

// Prev button: top corners r=8, bottom-right r=8, bottom-left large arc (r=37.5 on 100pt canvas)
// Scaled to actual buttonWidth x buttonHeight at draw time via path(in:)
public struct PrevButtonShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let s = w / 100  // scale factor from Rainmeter's 100-unit canvas

        let r: CGFloat = 8 * s        // standard corner radius
        let arc: CGFloat = 37.5 * s   // large bottom-left arc radius

        var p = Path()
        p.move(to: CGPoint(x: 8.33 * s, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addRelativeArc(center: CGPoint(x: w - r, y: r), radius: r, startAngle: .degrees(-90), delta: .degrees(90))
        p.addLine(to: CGPoint(x: w, y: h - r))
        p.addRelativeArc(center: CGPoint(x: w - r, y: h - r), radius: r, startAngle: .degrees(0), delta: .degrees(90))
        // bottom-left convex arc: center inside at (arc, h-arc)
        p.addLine(to: CGPoint(x: arc, y: h))
        p.addRelativeArc(center: CGPoint(x: arc, y: h - arc), radius: arc, startAngle: .degrees(90), delta: .degrees(90))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addRelativeArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(180), delta: .degrees(90))
        p.closeSubpath()
        return p.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

// Play button: uniform r=8 on all four corners (simple rounded rect)
public struct PlayButtonShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: Theme.buttonRadius)
    }
}

// Next button: top corners r=8, bottom-left r=8, bottom-right large arc (r=37.5 on 100pt canvas)
public struct NextButtonShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let s = w / 100

        let r: CGFloat = 8 * s
        let arc: CGFloat = 37.5 * s

        var p = Path()
        p.move(to: CGPoint(x: r, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addRelativeArc(center: CGPoint(x: w - r, y: r), radius: r, startAngle: .degrees(-90), delta: .degrees(90))
        // bottom-right convex arc: center inside at (w-arc, h-arc)
        p.addLine(to: CGPoint(x: w, y: h - arc))
        p.addRelativeArc(center: CGPoint(x: w - arc, y: h - arc), radius: arc, startAngle: .degrees(0), delta: .degrees(90))
        p.addLine(to: CGPoint(x: r, y: h))
        p.addRelativeArc(center: CGPoint(x: r, y: h - r), radius: r, startAngle: .degrees(90), delta: .degrees(90))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addRelativeArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(180), delta: .degrees(90))
        p.closeSubpath()
        return p.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}
