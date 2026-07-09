import Carbon

struct ShortcutMenuRow: Equatable {
    let action: String
    let shortcut: String
}

struct AppShortcut: Equatable {
    let titleKey: AppTextKey
    let key: String
    let carbonKeyCode: Int
    let carbonModifiers: Int

    var title: String {
        AppText.value(titleKey)
    }

    var displayValue: String {
        "Command + \(key)"
    }

    static let captureArea = AppShortcut(
        titleKey: .captureArea,
        key: "S",
        carbonKeyCode: kVK_ANSI_S,
        carbonModifiers: cmdKey
    )

    static let repeatLastArea = AppShortcut(
        titleKey: .repeatLastArea,
        key: "R",
        carbonKeyCode: kVK_ANSI_R,
        carbonModifiers: cmdKey
    )

    static let openSaveFolder = AppShortcut(
        titleKey: .openSaveFolder,
        key: "O",
        carbonKeyCode: kVK_ANSI_O,
        carbonModifiers: cmdKey
    )

    static let quit = AppShortcut(
        titleKey: .quitCaptureImage,
        key: "Q",
        carbonKeyCode: kVK_ANSI_Q,
        carbonModifiers: cmdKey
    )

    static let visibleShortcuts: [AppShortcut] = [
        .captureArea,
        .repeatLastArea,
        .openSaveFolder,
        .quit
    ]

    static var menuRows: [ShortcutMenuRow] {
        visibleShortcuts.map {
            ShortcutMenuRow(action: $0.title, shortcut: $0.displayValue)
        }
    }
}
