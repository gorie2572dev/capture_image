import AppKit

@MainActor
final class MenuBarController {
    private let capturePresenter: any CapturePresenting
    private var statusItem: NSStatusItem?

    init(capturePresenter: any CapturePresenting) {
        self.capturePresenter = capturePresenter
    }

    func install() {
        CaptureLogger.info("Installing menu bar item")
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "CaptureImage")
        item.button?.title = " \(AppText.value(.statusTitle))"
        item.button?.toolTip = "CaptureImage"
        item.menu = buildMenu()
        statusItem = item

        capturePresenter.activate()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(menuItem(title: AppShortcut.captureArea.title, action: #selector(captureArea), shortcut: .captureArea))
        menu.addItem(menuItem(title: AppShortcut.repeatLastArea.title, action: #selector(repeatLastArea), shortcut: .repeatLastArea))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuItem(title: AppText.value(.showShortcuts), action: #selector(showShortcuts), keyEquivalent: "?"))
        menu.addItem(languageMenuItem())
        menu.addItem(menuItem(title: AppShortcut.openSaveFolder.title, action: #selector(openSaveFolder), shortcut: .openSaveFolder))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuItem(title: AppShortcut.quit.title, action: #selector(quit), shortcut: .quit))
        return menu
    }

    private func languageMenuItem() -> NSMenuItem {
        let item = NSMenuItem(title: AppText.value(.language), action: nil, keyEquivalent: "")
        let submenu = NSMenu()

        for language in AppLanguage.allCases {
            let languageItem = NSMenuItem(
                title: language.displayName,
                action: #selector(languageSelected(_:)),
                keyEquivalent: ""
            )
            languageItem.target = self
            languageItem.representedObject = language.rawValue
            languageItem.state = language == AppLanguage.current ? .on : .off
            submenu.addItem(languageItem)
        }

        item.submenu = submenu
        return item
    }

    private func menuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        return item
    }

    private func menuItem(title: String, action: Selector, shortcut: AppShortcut) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: shortcut.key.lowercased())
        item.target = self
        item.keyEquivalentModifierMask = [.command]
        return item
    }

    @objc private func captureArea() {
        CaptureLogger.info("Menu action: capture area")
        capturePresenter.captureAreaRequested()
    }

    @objc private func repeatLastArea() {
        CaptureLogger.info("Menu action: repeat last area")
        capturePresenter.repeatLastAreaRequested()
    }

    @objc private func openSaveFolder() {
        CaptureLogger.info("Menu action: open save folder")
        capturePresenter.openSaveFolderRequested()
    }

    @objc private func showShortcuts() {
        ShortcutMenuPresenter.show(rows: AppShortcut.menuRows)
    }

    @objc private func languageSelected(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let language = AppLanguage(rawValue: rawValue)
        else {
            return
        }

        CaptureLogger.info("Changing language to \(language.rawValue)")
        AppLanguage.current = language
        statusItem?.button?.title = " \(AppText.value(.statusTitle))"
        statusItem?.menu = buildMenu()
    }

    @objc private func quit() {
        CaptureLogger.info("Menu action: quit")
        NSApp.terminate(nil)
    }
}
