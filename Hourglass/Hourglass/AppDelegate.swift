import SwiftUI
import Combine

protocol WindowCoordinator: AnyObject {
    func showAboutWindow()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private struct Dependencies {
        static let timerManager = TimerManager.shared
        static let userNotificationManager = UserNotificationManager.shared
        static let settingsManager = SettingsManager.shared
    }

    private var statusBar: NSStatusBar = NSStatusBar.system
    private var statusItem: NSStatusItem!
    private var aboutWindow: NSWindow!
    private var appWindow: NSWindow!

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        let view = setupContentView()
        setupAppWindow(with: view)
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

            button.action = #selector(toggleAppWindow)
            button.setAccessibilityIdentifier("menu-bar-button")

            Dependencies.timerManager.$timeStamp
                .sink { timestamp in
                    button.setAccessibilityTitle(timestamp)
                }
                .store(in: &cancellables)
        }
    }

    private func setupAppWindow(with view: some View) {
        // let hostingController = NSHostingController(rootView: view)
        let hostingView = NSHostingView(rootView: view)
        //hostingController.view.layer?.backgroundColor = .black
        appWindow = NSWindow(
            contentRect: NSRect(origin: .zero, size: hostingView.fittingSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true)
        appWindow.level = .statusBar //.floating
        appWindow.backgroundColor = NSColor.red //.clear

        // TODO: - Figure out x position of status item button relative to screen
        //appWindow.setFrameOrigin(.zero)
        appWindow.orderFrontRegardless()
        //appWindow.makeKeyAndOrderFront(nil)
        //appWindow.isReleasedWhenClosed = false
    }

    private func setupContentView() -> some View {
        let viewModel = ViewModel(timerManager: Dependencies.timerManager,
                                  userNotificationManager: Dependencies.userNotificationManager,
                                  settingsManager: Dependencies.settingsManager,
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
    @objc private func toggleAppWindow() {
        if appWindow.isVisible {
            hideAppWindow()
        } else {
            showAppWindow()
        }
    }

    private func hideAppWindow() {
        appWindow.orderOut(nil)
        //appWindow.close()
    }

    private func showAppWindow() {
        //appWindow.setIsVisible(true)
        appWindow.makeKeyAndOrderFront(nil)
        //appWindow.makeMain()
    }
}

extension AppDelegate: WindowCoordinator {
    func showAboutWindow() {
        aboutWindow.makeKeyAndOrderFront(nil)
    }
}

//class AppPanel: NSPanel {
//    init() {
//        super.init(contentRect: .init(x: 0, y: 0, width: 800, height: 200),
//                   styleMask: [.nonactivatingPanel], // the only style that works
//                   backing: .buffered,
//                   defer: true)
//
//        self.contentView?.wantsLayer = true
//        self.contentView!.layer!.backgroundColor = NSColor.gray.cgColor
//    }
//}
