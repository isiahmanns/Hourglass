import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    // TODO: - Show about window
    // TODO: - Alert doesn't actively toggle popup, double-click to dismiss.

    private struct Dependencies {
        static let timerManager = TimerManager.shared
        static let userNotificationManager = UserNotificationManager.shared
        static let settingsManager = SettingsManager.shared
    }

    private var statusBar: NSStatusBar = NSStatusBar.system
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        let timestampSUIView = TimestampView(timerManager: Dependencies.timerManager)
        let timestampNSView = NSHostingView(rootView: timestampSUIView)

        statusItem = statusBar.statusItem(withLength: timestampNSView.fittingSize.width)

        if let button = statusItem.button {
            timestampNSView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(timestampNSView)

            NSLayoutConstraint.activate([
                timestampNSView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                timestampNSView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])

            button.action = #selector(togglePopover)
            button.setAccessibilityIdentifier("menu-bar-button")

            Dependencies.timerManager.$timeStamp
                .sink { timestamp in
                    button.setAccessibilityTitle(timestamp)
                }
                .store(in: &cancellables)
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        let contentView = setupContentView()
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    private func setupContentView() -> some View {
        let viewModel = ViewModel(timerManager: Dependencies.timerManager,
                                  userNotificationManager: Dependencies.userNotificationManager,
                                  settingsManager: Dependencies.settingsManager)
        return ContentView(viewModel: viewModel)
            .font(.poppins)
    }
}
