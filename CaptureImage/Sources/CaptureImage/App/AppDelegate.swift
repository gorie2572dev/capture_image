import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        CaptureLogger.markLaunch()
        CaptureLogger.info("Application did finish launching")
        NSApp.setActivationPolicy(.accessory)

        let capturePresenter = CaptureModuleBuilder.build()
        menuBarController = MenuBarController(capturePresenter: capturePresenter)
        menuBarController?.install()
    }
}
