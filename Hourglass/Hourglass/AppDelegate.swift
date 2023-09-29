import Combine
import FirebaseCore
import SwiftUI

enum WindowContext: Int {
    case app
    case about
    case statistics
}

protocol WindowCoordinator: AnyObject {
    func showWindow(_ windowContext: WindowContext)
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
    private var appWindow: NSWindow!
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
        setupAppUI()
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
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(timestampNSView)

            NSLayoutConstraint.activate([
                timestampNSView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                timestampNSView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                timestampNSView.widthAnchor.constraint(equalTo: button.widthAnchor),
                timestampNSView.heightAnchor.constraint(equalTo: button.heightAnchor)
            ])

            button.action = #selector(toggleAppUI)
            button.setAccessibilityIdentifier("menu-bar-button")

            Dependencies.timerManager.$timeStamp
                .sink { timestamp in
                    button.setAccessibilityTitle(timestamp)
                }
                .store(in: &cancellables)
        }
    }

    @objc private func toggleAppUI() {
        // TODO: - Handle close/opening window
        showWindow(.app)
    }

    private func setupAppUI() {
        let appView = ContentView(viewModel: viewModel, settingsManager: Dependencies.settingsManager)
        let appViewController = NSHostingController(rootView: appView)
        appWindow = NSWindow(contentViewController: appViewController)
        // TODO: - Experiment with using close button on window
        appWindow.styleMask = [.titled, .fullSizeContentView]
        appWindow.titleVisibility = .hidden
        appWindow.titlebarAppearsTransparent = true
        appWindow.level = .floating
    }
}

extension AppDelegate: WindowCoordinator {
    func showWindow(_ windowContext: WindowContext) {
        var window: NSWindow!

        switch windowContext {
        case .app:
            window = appWindow
        case .about:
            window = aboutWindow
        case .statistics:
            window = statisticsWindow
        }

        if window == nil {
            window = setupWindow(windowContext)
        }

        window.makeKeyAndOrderFront(nil)
    }

    private func setupWindow(_ windowContext: WindowContext) -> NSWindow? {
        // TODO: - Release windows on close
        switch windowContext {
        case .app:
            break
        case .about:
            let aboutView = AboutView(bundle: Dependencies.bundle,
                                      iapManager: Dependencies.iapManager)
            let aboutViewController = NSHostingController(rootView: aboutView)
            aboutWindow = NSWindow(contentViewController: aboutViewController)
            aboutWindow.styleMask = [.titled, .closable, .fullSizeContentView]
            aboutWindow.title = "About"
            aboutWindow.titleVisibility = .hidden
            aboutWindow.titlebarAppearsTransparent = true
            aboutWindow.level = .floating
            return aboutWindow
        case .statistics:
            let statisticsView = StatisticsView()
                .environment(\.managedObjectContext, CoreDataStore.shared.context)
            let statisticsViewController = NSHostingController(rootView: statisticsView)
            statisticsWindow = NSWindow(contentViewController: statisticsViewController)
            statisticsWindow.styleMask = [.titled, .closable, .resizable]
            statisticsWindow.title = "Statistics"
            statisticsWindow.titlebarAppearsTransparent = true
            statisticsWindow.level = .floating
            return statisticsWindow
        }

        return nil
    }
}
