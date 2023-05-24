import SwiftUI

class PopoverViewController: NSViewController {
    private let rootView: NSView
    private let backgroundColor: Color
    private var needsConfigurePopoverFrame: Bool = true

    init(with view: some View, backgroundColor: Color) {
        self.rootView = NSHostingView(rootView: view)
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }

    override func viewWillAppear() {
        if needsConfigurePopoverFrame {
            configurePopoverFrame()
        }
    }

    private func configurePopoverFrame() {
        defer { needsConfigurePopoverFrame = false }

        if let popoverFrame = self.view.superview { // NSPopoverFrame <- NSVisualEffectView <- NSView
            let backgroundView = NSView(frame: popoverFrame.frame)
            backgroundView.wantsLayer = true
            backgroundView.layer?.backgroundColor = NSColor(backgroundColor).cgColor
            backgroundView.autoresizingMask = [.width, .height]
            popoverFrame.addSubview(backgroundView, positioned: .below, relativeTo: self.view)
        }
    }
}
