import SwiftUI
import AppKit
import NoroPlayerLib

@main
struct NoroPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        NoroPlayerLib.registerCustomFont()
    }

    var body: some Scene {
        WindowGroup {
            PlayerView()
                .background(Color.clear)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            Button("Show / Hide") {
                appDelegate.toggleWindow()
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "play.circle.fill")
        }
    }
}
