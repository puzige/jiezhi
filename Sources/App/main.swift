import AppKit

MainActor.assumeIsolated {
    let application = NSApplication.shared
    let applicationDelegate = AppDelegate()

    NSLog("止界：启动显式 AppKit 入口")
    application.delegate = applicationDelegate
    application.setActivationPolicy(.accessory)
    application.run()
}
