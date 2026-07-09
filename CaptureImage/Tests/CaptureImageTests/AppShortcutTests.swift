import Testing
@testable import CaptureImage

struct AppShortcutTests {
    @Test func captureAreaUsesCommandS() {
        AppLanguage.current = .english

        #expect(AppShortcut.captureArea.key == "S")
        #expect(AppShortcut.captureArea.displayValue == "Command + S")
    }

    @Test func visibleShortcutsIncludeCoreCaptureActions() {
        AppLanguage.current = .english

        let titles = AppShortcut.visibleShortcuts.map(\.title)

        #expect(titles == [
            "Capture Area",
            "Repeat Last Area",
            "Open Save Folder",
            "Quit CaptureImage"
        ])
    }

    @Test func menuRowsExposeActionAndShortcutColumns() {
        AppLanguage.current = .english

        #expect(AppShortcut.menuRows == [
            ShortcutMenuRow(action: "Capture Area", shortcut: "Command + S"),
            ShortcutMenuRow(action: "Repeat Last Area", shortcut: "Command + R"),
            ShortcutMenuRow(action: "Open Save Folder", shortcut: "Command + O"),
            ShortcutMenuRow(action: "Quit CaptureImage", shortcut: "Command + Q")
        ])
    }
}
