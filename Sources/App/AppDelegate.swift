import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private static let statusIconPointSize: CGFloat = 17

    private let model = JiezhiModel()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var windowController: JiezhiWindowController?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("止界：applicationDidFinishLaunching")
        NSApp.setActivationPolicy(.accessory)
        windowController = JiezhiWindowController(model: model)
        configureStatusItem()

        model.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.updateStatusIcon() }
            }
            .store(in: &cancellables)
        updateStatusIcon()

        DispatchQueue.main.async { [weak self] in
            self?.windowController?.present()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowController?.present()
        return true
    }

    private func configureStatusItem() {
        statusItem.button?.toolTip = "止界"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()

        let state = model.allowsPointerAcrossDevices ? "开" : "关"
        let stateItem = NSMenuItem(title: "跨设备：\(state)", action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        let toggleTitle = model.allowsPointerAcrossDevices ? "关闭跨设备" : "允许跨设备"
        let toggle = NSMenuItem(title: toggleTitle, action: #selector(toggleState), keyEquivalent: "")
        toggle.target = self
        toggle.isEnabled = !model.isWorking
        menu.addItem(toggle)

        if let error = model.errorMessage {
            let errorItem = NSMenuItem(title: error, action: nil, keyEquivalent: "")
            errorItem.isEnabled = false
            menu.addItem(errorItem)
        }

        menu.addItem(.separator())
        let show = NSMenuItem(title: "显示止界", action: #selector(showWindow), keyEquivalent: "")
        show.target = self
        menu.addItem(show)
        let quit = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    private func updateStatusIcon() {
        let description = model.allowsPointerAcrossDevices ? "允许指针跨设备" : "指针不跨设备"
        let baseImage = NSImage(
            systemSymbolName: "arrow.left.and.right.circle.fill",
            accessibilityDescription: description
        )
        let configuration = NSImage.SymbolConfiguration(
            pointSize: Self.statusIconPointSize,
            weight: .regular
        )
        let image = baseImage?.withSymbolConfiguration(configuration) ?? baseImage
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.appearsDisabled = model.isWorking || !model.allowsPointerAcrossDevices
        statusItem.button?.toolTip = description
    }

    @objc private func toggleState() { model.toggle() }
    @objc private func showWindow() { windowController?.present() }
    @objc private func quit() { NSApp.terminate(nil) }
}
