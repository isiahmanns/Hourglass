import SwiftUI

#if DEBUG || RELEASE
@main
struct HourglassApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .font(Font.poppins)
        } label: {
            HStack {
                Image(systemName: "hourglass")
                Text("<timestamp>")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("menu-bar-select")
        }
        .menuBarExtraStyle(.window)
    }
}

#elseif CITESTING
@main
struct HourglassApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {}
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.windows.forEach { window in
            window.close()
        }

        let contentView = ContentView()
            .font(Font.poppins)

        self.window = NSWindow()
        window.contentViewController = NSHostingController(rootView: contentView)
        window.setContentSize(.init(width: window.maxSize.width, height: window.maxSize.height))
        window.styleMask.insert(.closable)
        window.standardWindowButton(.closeButton)!.action = #selector(hideWindow)
        window.standardWindowButton(.closeButton)!.target = self
        showApp()

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.title = "<timestamp>"
            button.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "menu-bar-select")
            button.action = #selector(toggleWindow)
        }
    }

    @objc func toggleWindow(_ sender: AnyObject?) {
        if window.isVisible {
            hideApp()
        } else {
            showApp()
        }
    }

    @objc func hideWindow(_ sender: AnyObject?) {
        hideApp()
    }

    private func hideApp() {
        NSApplication.shared.hide(nil)
    }

    private func showApp() {
        NSApplication.shared.unhide(nil)
        window.makeKeyAndOrderFront(nil)
    }
}
#endif
