import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case vietnamese = "vi"
    case french = "fr"
    case latin = "la"

    private static let storageKey = "CaptureImage.AppLanguage"

    static var current: AppLanguage {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: storageKey) else {
                return .english
            }
            return AppLanguage(rawValue: rawValue) ?? .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .vietnamese:
            return "Tiếng Việt"
        case .french:
            return "Français"
        case .latin:
            return "Latina"
        }
    }
}

enum AppTextKey: Equatable, Hashable {
    case statusTitle
    case captureArea
    case repeatLastArea
    case openSaveFolder
    case quitCaptureImage
    case showShortcuts
    case language
    case shortcutTitle
    case action
    case shortcut
    case ok
    case hotkeyUnavailable
    case captureFailed
    case dragToCapture
    case zoomImage
    case copyImage
    case openImage
    case showInFinder
    case removeFromList
    case zoomTitle
    case couldNotEncodePNG
    case couldNotReadScreenImage
    case screenRecordingPermissionDenied
}

enum AppText {
    static func value(_ key: AppTextKey, language: AppLanguage = .current) -> String {
        switch language {
        case .english:
            return english[key] ?? ""
        case .vietnamese:
            return vietnamese[key] ?? english[key] ?? ""
        case .french:
            return french[key] ?? english[key] ?? ""
        case .latin:
            return latin[key] ?? english[key] ?? ""
        }
    }

    static func couldNotRegister(_ shortcut: String, language: AppLanguage = .current) -> String {
        switch language {
        case .english:
            return "Could not register \(shortcut)."
        case .vietnamese:
            return "Không thể đăng ký \(shortcut)."
        case .french:
            return "Impossible d'enregistrer \(shortcut)."
        case .latin:
            return "Non potui \(shortcut) registrare."
        }
    }

    private static let english: [AppTextKey: String] = [
        .statusTitle: "Capture",
        .captureArea: "Capture Area",
        .repeatLastArea: "Repeat Last Area",
        .openSaveFolder: "Open Save Folder",
        .quitCaptureImage: "Quit CaptureImage",
        .showShortcuts: "Show Shortcuts",
        .language: "Language",
        .shortcutTitle: "CaptureImage Shortcuts",
        .action: "Action",
        .shortcut: "Shortcut",
        .ok: "OK",
        .hotkeyUnavailable: "Hotkey unavailable",
        .captureFailed: "Capture failed",
        .dragToCapture: "Drag to capture area. Press Esc to cancel.",
        .zoomImage: "Zoom Image",
        .copyImage: "Copy Image",
        .openImage: "Open Image",
        .showInFinder: "Show in Finder",
        .removeFromList: "Remove from List",
        .zoomTitle: "Image Preview",
        .couldNotEncodePNG: "Could not encode the screenshot as PNG.",
        .couldNotReadScreenImage: "Could not read the selected screen area.",
        .screenRecordingPermissionDenied: "Screen Recording permission is required. Open System Settings > Privacy & Security > Screen Recording, enable CaptureImage, then restart the app."
    ]

    private static let vietnamese: [AppTextKey: String] = [
        .statusTitle: "Chụp",
        .captureArea: "Chụp vùng",
        .repeatLastArea: "Chụp lại vùng trước",
        .openSaveFolder: "Mở thư mục lưu",
        .quitCaptureImage: "Thoát CaptureImage",
        .showShortcuts: "Hiển thị phím tắt",
        .language: "Ngôn ngữ",
        .shortcutTitle: "Phím tắt CaptureImage",
        .action: "Hành động",
        .shortcut: "Phím tắt",
        .ok: "OK",
        .hotkeyUnavailable: "Không dùng được phím tắt",
        .captureFailed: "Chụp thất bại",
        .dragToCapture: "Kéo để chọn vùng chụp. Nhấn Esc để hủy.",
        .zoomImage: "Phóng to ảnh",
        .copyImage: "Sao chép ảnh",
        .openImage: "Mở ảnh",
        .showInFinder: "Hiển thị trong Finder",
        .removeFromList: "Xóa khỏi danh sách",
        .zoomTitle: "Xem trước ảnh",
        .couldNotEncodePNG: "Không thể mã hóa ảnh chụp thành PNG.",
        .couldNotReadScreenImage: "Không thể đọc vùng màn hình đã chọn.",
        .screenRecordingPermissionDenied: "Cần quyền Ghi màn hình. Mở Cài đặt hệ thống > Quyền riêng tư & Bảo mật > Ghi màn hình, bật CaptureImage, rồi khởi động lại app."
    ]

    private static let french: [AppTextKey: String] = [
        .statusTitle: "Capturer",
        .captureArea: "Capturer une zone",
        .repeatLastArea: "Répéter la dernière zone",
        .openSaveFolder: "Ouvrir le dossier",
        .quitCaptureImage: "Quitter CaptureImage",
        .showShortcuts: "Afficher les raccourcis",
        .language: "Langue",
        .shortcutTitle: "Raccourcis CaptureImage",
        .action: "Action",
        .shortcut: "Raccourci",
        .ok: "OK",
        .hotkeyUnavailable: "Raccourci indisponible",
        .captureFailed: "Capture échouée",
        .dragToCapture: "Faites glisser pour capturer une zone. Appuyez sur Esc pour annuler.",
        .zoomImage: "Agrandir l'image",
        .copyImage: "Copier l'image",
        .openImage: "Ouvrir l'image",
        .showInFinder: "Afficher dans le Finder",
        .removeFromList: "Retirer de la liste",
        .zoomTitle: "Aperçu de l'image",
        .couldNotEncodePNG: "Impossible d'encoder la capture en PNG.",
        .couldNotReadScreenImage: "Impossible de lire la zone sélectionnée.",
        .screenRecordingPermissionDenied: "L'autorisation Enregistrement de l'écran est requise. Ouvrez Réglages Système > Confidentialité et sécurité > Enregistrement de l'écran, activez CaptureImage, puis redémarrez l'app."
    ]

    private static let latin: [AppTextKey: String] = [
        .statusTitle: "Cape",
        .captureArea: "Cape Regionem",
        .repeatLastArea: "Repete Regionem Ultimam",
        .openSaveFolder: "Aperi Folder Servandi",
        .quitCaptureImage: "Exi CaptureImage",
        .showShortcuts: "Monstra Compendia",
        .language: "Lingua",
        .shortcutTitle: "Compendia CaptureImage",
        .action: "Actio",
        .shortcut: "Compendium",
        .ok: "OK",
        .hotkeyUnavailable: "Compendium non praesto",
        .captureFailed: "Captura defecit",
        .dragToCapture: "Trahe ut regionem capias. Preme Esc ut abroges.",
        .zoomImage: "Amplifica Imaginem",
        .copyImage: "Copia Imaginem",
        .openImage: "Aperi Imaginem",
        .showInFinder: "Monstra in Finder",
        .removeFromList: "Remove ex Indice",
        .zoomTitle: "Praevisio Imaginis",
        .couldNotEncodePNG: "Non potui capturam in PNG convertere.",
        .couldNotReadScreenImage: "Non potui regionem selectam legere.",
        .screenRecordingPermissionDenied: "Permissio Screen Recording requiritur. Aperi System Settings > Privacy & Security > Screen Recording, activa CaptureImage, deinde app reini."
    ]
}
