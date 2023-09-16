import Combine
import FirebaseCore
import SwiftUI

protocol WindowCoordinator: AnyObject {
    func showAboutWindow()
    func showStatisticsWindow()
}

private struct Dependencies {
    static let analyticsManager = AnalyticsManager.shared
    static let dataManager = DataManager.shared
    static let settingsManager = SettingsManager.shared
    static let timerManager = TimerManager.shared
    static let timerModelStateManager = TimerModelStateManager.shared
    static let userNotificationManager = UserNotificationManager.shared
    static let bundle = Bundle.main
    static let iapManager = IAPManager.shared
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: NSStatusBar = NSStatusBar.system
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var aboutWindow: NSWindow!
    private var statisticsWindow: NSWindow!

    // Root Dependencies
    private var iapManager = Dependencies.iapManager
    private var timerModelStateManager = Dependencies.timerModelStateManager
    private var dataManager = Dependencies.dataManager
    private var viewModel = ViewModel(analyticsManager: Dependencies.analyticsManager,
                                      dataManager: Dependencies.dataManager,
                                      settingsManager: Dependencies.settingsManager,
                                      timerManager: Dependencies.timerManager,
                                      userNotificationManager: Dependencies.userNotificationManager)

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        FirebaseApp.configure()
        setupDelegates()
        setupStatusItem()
        let view = setupContentView()
        setupPopover(with: view)
        setupAboutWindow()
    }

    private func setupDelegates() {
        viewModel.windowCoordinator = self
        timerModelStateManager.delegate = viewModel
    }

    private func setupStatusItem() {
        let timestampSUIView = TimestampView(timerManager: Dependencies.timerManager)
        let timestampNSView = NSHostingView(rootView: timestampSUIView)

        statusItem = statusBar.statusItem(withLength: timestampNSView.fittingSize.width)

        if let button = statusItem.button {
            timestampNSView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(timestampNSView)

            // TODO: - Troubleshoot ambiguous contraints
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
        popover.contentViewController = PopoverViewController(with: view, backgroundColor: Color.Hourglass.background)
    }

    private func setupContentView() -> some View {
        return ContentView(viewModel: viewModel, settingsManager: Dependencies.settingsManager)
    }

    private func setupAboutWindow() {
        let aboutView = AboutView(bundle: Dependencies.bundle,
                                  iapManager: Dependencies.iapManager)
        let aboutViewController = NSHostingController(rootView: aboutView)
        aboutWindow = NSWindow(contentViewController: aboutViewController)
        aboutWindow.styleMask = [.titled, .closable, .fullSizeContentView]
        aboutWindow.title = "About"
        aboutWindow.titleVisibility = .hidden
        aboutWindow.titlebarAppearsTransparent = true
        aboutWindow.level = .floating
        aboutWindow.setContentSize(aboutViewController.view.fittingSize)
    }

    private func setupStatisticsWindow() {
        let statisticsView = StatisticsView()
            .environment(\.managedObjectContext, CoreDataStore.shared.context)

        let statisticsViewController = NSHostingController(rootView: statisticsView)
        statisticsWindow = NSWindow(contentViewController: statisticsViewController)
        statisticsWindow.styleMask = [.titled, .closable, .resizable]
        statisticsWindow.titlebarAppearsTransparent = true
        statisticsWindow.level = .floating
        statisticsWindow.title = "Statistics"
        statisticsWindow.delegate = self
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

    func showStatisticsWindow() {
        if statisticsWindow == nil {
            setupStatisticsWindow()
        }

        statisticsWindow.makeKeyAndOrderFront(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if sender == statisticsWindow {
            statisticsWindow = nil
        }

        return true
    }
}
