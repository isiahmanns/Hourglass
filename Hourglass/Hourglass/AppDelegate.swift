import SwiftUI
import Combine

protocol WindowCoordinator: AnyObject {
    func showAboutWindow()
    func showPopoverIfNeeded()
    func showStatisticsWindow()
}

private struct Dependencies {
    static let dataManager = DataManager.shared
    static let settingsManager = SettingsManager.shared
    static let timerManager = TimerManager.shared
    static let timerModelStateManager = TimerModelStateManager.shared
    static let userNotificationManager = UserNotificationManager.shared
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: NSStatusBar = NSStatusBar.system
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var aboutWindow: NSWindow!
    private var statisticsWindow: NSWindow!

    // Root Dependencies
    private var timerModelStateManager = Dependencies.timerModelStateManager
    private var dataManager = Dependencies.dataManager
    private var viewModel = ViewModel(dataManager: Dependencies.dataManager,
                                      settingsManager: Dependencies.settingsManager,
                                      timerManager: Dependencies.timerManager,
                                      userNotificationManager: Dependencies.userNotificationManager)

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupDelegates()
        setupStatusItem()
        let view = setupContentView()
        setupPopover(with: view)
        setupAboutWindow()
        //setupStatisticsWindow()
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
        return ContentView(viewModel: viewModel, settingsManager: Dependencies.settingsManager)
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

    private func setupStatisticsWindow() {
        let statisticsView = StatisticsView()
            .environment(
                \.managedObjectContext,
                 CoreDataStore.shared.context)

        let statisticsViewController = NSHostingController(rootView: statisticsView)
        //statisticsWindow = NSWindow(contentViewController: statisticsViewController)
        statisticsWindow = StatWindow()
        statisticsWindow?.delegate = self
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
        // Note: Fixes bug where tapping the status item wouldn't close the popover on the first time after an alert popup.
        if !popover.isShown {
            showPopover()
        }
    }

    func showStatisticsWindow() {
        print(statisticsWindow)

        if statisticsWindow == nil {
            setupStatisticsWindow()
        }
        statisticsWindow?.makeKeyAndOrderFront(nil)
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

class StatWindow: NSWindow {
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 400, height: 400), styleMask: [.titled, .closable], backing: .buffered, defer: true)
        /**
         Note: - isReleasedWhenClosed's default value is true when subclassing NSWindow; false when using the contentViewController init.
         Setting to false to mimic current behavior above.
         */
        isReleasedWhenClosed = false

        /**
         It seems like to use isReleasedWhenClosed properly, in the use case of tapping a button to create/show a window,
         logic is needed to determine when the window was closed (toggling a flag in the window delegate). There is no way
         to use the current window reference to determine if it was released because when this property is active, the memory can't be accessed once released (bad access).
         Via the additional logic/flag is how it can be determined whether or not the window was closed prior to createing/showing a new one.

         Another solution to this is to keep isReleasedWhenClosed false, and use the window delegate to set the property to nil manually. This is the current implementation above.
         This subclass is a way to verify that under these conditions, the window's deinit still gets called.
         */
    }
    deinit {
        print("stat window dealloc")
    }
}
