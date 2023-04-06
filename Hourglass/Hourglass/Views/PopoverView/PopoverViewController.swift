import SwiftUI

class PopoverViewController: NSViewController {
    private let rootView: NSView

    init(with view: some View) {
        self.rootView = PopoverView(with: view)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }
}
