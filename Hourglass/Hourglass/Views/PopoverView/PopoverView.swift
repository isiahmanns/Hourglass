import SwiftUI

class PopoverView: NSView {
    private let rootView: NSView

    init(with view: some View) {
        self.rootView = NSHostingView(rootView: view)
        super.init(frame: NSRect(origin: .zero, size: rootView.fittingSize))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rootView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override func viewDidMoveToSuperview() {
        if let popoverFrame = self.superview { // NSPopoverFrame <- NSVisualEffectView <- NSView
            let backgroundView = NSView(frame: popoverFrame.frame)
            backgroundView.wantsLayer = true
            backgroundView.layer?.backgroundColor = NSColor(Color.background).cgColor
            popoverFrame.addSubview(backgroundView, positioned: .below, relativeTo: self)
        }
    }
}
