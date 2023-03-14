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
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.windows.forEach { window in
            window.close()
        }

        let contentView = ContentView()
            .font(Font.poppins)

        self.popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.title = "<timestamp>"
            button.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "menu-bar-select")
            button.action = #selector(togglePopover)
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
#endif
