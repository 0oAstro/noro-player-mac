import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let positionKey = "windowOriginX"
    private let positionYKey = "windowOriginY"

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureWindow()
        restoreWindowPosition()
    }

    func applicationWillTerminate(_ notification: Notification) {
        saveWindowPosition()
    }

    func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask = [.borderless, .fullSizeContentView]
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
    }

    func toggleWindow() {
        guard let window = NSApplication.shared.windows.first else { return }
        if window.isVisible {
            saveWindowPosition()
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    private func saveWindowPosition() {
        guard let window = NSApplication.shared.windows.first else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set(Double(origin.x), forKey: positionKey)
        UserDefaults.standard.set(Double(origin.y), forKey: positionYKey)
    }

    private func restoreWindowPosition() {
        guard let window = NSApplication.shared.windows.first else { return }
        let x = UserDefaults.standard.double(forKey: positionKey)
        let y = UserDefaults.standard.double(forKey: positionYKey)
        if x != 0 || y != 0 {
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}
