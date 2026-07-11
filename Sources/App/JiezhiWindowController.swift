import AppKit
import SwiftUI

@MainActor
final class JiezhiWindowController: NSWindowController {
    init(model: JiezhiModel) {
        let hostingController = NSHostingController(rootView: JiezhiView(model: model))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "止界"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func present() {
        guard let window else { return }
        showWindow(nil)
        NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        window.makeKeyAndOrderFront(nil)
    }
}
