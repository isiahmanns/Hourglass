import SwiftUI
import Combine

protocol WindowCoordinator: AnyObject {
    func showAboutWindow()
    func showPopoverIfNeeded()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private struct Dependencies {
        static let dataManager = DataManager.shared
        static let progressTrackingManager = ProgressTrackingManager.shared
        static let settingsManager = SettingsManager.shared
        static let timerEventProvider = TimerManager.shared
        static let timerManager = TimerManager.shared
        static let userNotificationManager = UserNotificationManager.shared
    }

    private var statusBar: NSStatusBar = NSStatusBar.system
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var aboutWindow: NSWindow!

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        let view = setupContentView()
        setupPopover(with: view)
        setupAboutWindow()
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

    private func setupPopover(with view: some View) {
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = PopoverViewController(with: view)
    }

    private func setupContentView() -> some View {
        let viewModel = ViewModel(dataManager: Dependencies.dataManager,
                                  settingsManager: Dependencies.settingsManager,
                                  timerManager: Dependencies.timerManager,
                                  userNotificationManager: Dependencies.userNotificationManager,
                                  windowCoordinator: self)

        return ContentView(viewModel: viewModel)
            .font(.poppins)
    }

    private func setupAboutWindow() {
        let aboutViewController = NSHostingController(rootView: AboutView())
        aboutWindow = NSWindow(contentViewController: aboutViewController)
        aboutWindow.styleMask = [.titled, .closable, .fullSizeContentView]
        aboutWindow.titleVisibility = .hidden
        aboutWindow.titlebarAppearsTransparent = true
        aboutWindow.setContentSize(aboutViewController.view.fittingSize)
    }
}

extension AppDelegate {
    @objc private func togglePopover() {
        if popover.isShown {
            hidePopover()
        } else {
            showPopover()
        }
    }

    private func hidePopover() {
        popover.performClose(nil)
    }

    private func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

extension AppDelegate: WindowCoordinator {
    func showAboutWindow() {
        aboutWindow.makeKeyAndOrderFront(nil)
    }

    func showPopoverIfNeeded() {
        if !popover.isShown {
            showPopover()
        }
    }
}

class WindowCoordinatorMock: WindowCoordinator {
    func showAboutWindow() {}
    func showPopoverIfNeeded() {}
}
