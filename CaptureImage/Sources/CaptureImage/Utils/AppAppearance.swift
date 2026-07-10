import AppKit

enum AppAppearance: String, CaseIterable {
    case ivory
    case graphite
    case midnight
    case sky
    case rose
    case mint
    case lavender
    case lemon
    case slate
    case coral
    case ocean
    case sunset
    case aurora
    case custom

    private static let storageKey = "CaptureImage.AppAppearance"
    private static let customRedKey = "CaptureImage.CustomBackground.Red"
    private static let customGreenKey = "CaptureImage.CustomBackground.Green"
    private static let customBlueKey = "CaptureImage.CustomBackground.Blue"

    static let didChangeNotification = Notification.Name("CaptureImage.AppearanceDidChange")

    static var current: AppAppearance {
        guard let rawValue = UserDefaults.standard.string(forKey: storageKey) else {
            return .ivory
        }
        return AppAppearance(rawValue: rawValue) ?? .ivory
    }

    static var customColor: NSColor {
        NSColor(
            calibratedRed: component(forKey: customRedKey, fallback: 0.12),
            green: component(forKey: customGreenKey, fallback: 0.38),
            blue: component(forKey: customBlueKey, fallback: 0.32),
            alpha: 1
        )
    }

    static func select(_ appearance: AppAppearance, customColor: NSColor? = nil) {
        if let customColor, let color = customColor.usingColorSpace(.sRGB) {
            UserDefaults.standard.set(color.redComponent, forKey: customRedKey)
            UserDefaults.standard.set(color.greenComponent, forKey: customGreenKey)
            UserDefaults.standard.set(color.blueComponent, forKey: customBlueKey)
        }
        UserDefaults.standard.set(appearance.rawValue, forKey: storageKey)
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }

    var colors: [NSColor] {
        switch self {
        case .ivory:
            return [NSColor(hex: 0xFAF8F3)]
        case .graphite:
            return [NSColor(hex: 0x292929)]
        case .midnight:
            return [NSColor(hex: 0x0F172A)]
        case .sky:
            return [NSColor(hex: 0xE0F2FE)]
        case .rose:
            return [NSColor(hex: 0xFFF1F2)]
        case .mint:
            return [NSColor(hex: 0xD1FAE5)]
        case .lavender:
            return [NSColor(hex: 0xEDE9FE)]
        case .lemon:
            return [NSColor(hex: 0xFEF9C3)]
        case .slate:
            return [NSColor(hex: 0xE2E8F0)]
        case .coral:
            return [NSColor(hex: 0xFFE4E6)]
        case .ocean:
            return [NSColor(hex: 0x0F766E), NSColor(hex: 0x0369A1)]
        case .sunset:
            return [NSColor(hex: 0xF97316), NSColor(hex: 0xE11D48)]
        case .aurora:
            return [NSColor(hex: 0x0F766E), NSColor(hex: 0x7C3AED)]
        case .custom:
            return [Self.customColor]
        }
    }

    var isDark: Bool {
        let color = colors[0].usingColorSpace(.sRGB) ?? colors[0]
        return color.redComponent * 0.2126 + color.greenComponent * 0.7152 + color.blueComponent * 0.0722 < 0.48
    }

    var localizationKey: AppTextKey {
        switch self {
        case .ivory: return .appearanceIvory
        case .graphite: return .appearanceGraphite
        case .midnight: return .appearanceMidnight
        case .sky: return .appearanceSky
        case .rose: return .appearanceRose
        case .mint: return .appearanceMint
        case .lavender: return .appearanceLavender
        case .lemon: return .appearanceLemon
        case .slate: return .appearanceSlate
        case .coral: return .appearanceCoral
        case .ocean: return .appearanceOcean
        case .sunset: return .appearanceSunset
        case .aurora: return .appearanceAurora
        case .custom: return .appearanceCustom
        }
    }

    private static func component(forKey key: String, fallback: CGFloat) -> CGFloat {
        guard let value = UserDefaults.standard.object(forKey: key) as? NSNumber else {
            return fallback
        }
        return CGFloat(value.doubleValue)
    }
}

enum CaptureTheme {
    static var background: NSColor { AppAppearance.current.colors[0] }
    static var sidebar: NSColor { background }
    static var surface: NSColor { background }
    static var border: NSColor { AppAppearance.current.isDark ? NSColor.white.withAlphaComponent(0.18) : NSColor(hex: 0xE5E0D8) }
    static var textPrimary: NSColor { AppAppearance.current.isDark ? .white : NSColor(hex: 0x34322F) }
    static var textSecondary: NSColor { AppAppearance.current.isDark ? NSColor.white.withAlphaComponent(0.72) : NSColor(hex: 0x77736A) }
    static var accent: NSColor { AppAppearance.current.isDark ? NSColor(hex: 0x7DD3FC) : NSColor(hex: 0xD97757) }
    static var accentSoft: NSColor { AppAppearance.current.isDark ? NSColor(hex: 0xBAE6FD) : NSColor(hex: 0xF3DDD3) }
    static var darkStatus: NSColor { AppAppearance.current.isDark ? background : NSColor(hex: 0x2F302D) }
    static let alertDot = NSColor(hex: 0x2D8CDE)
    static let overlayScrim = NSColor.black.withAlphaComponent(0.24)

    @MainActor static func applyBackground(to view: NSView) {
        view.wantsLayer = true
        let layer = view.layer
        layer?.sublayers?
            .filter { $0.name == "CaptureImage.AppearanceGradient" }
            .forEach { $0.removeFromSuperlayer() }

        let colors = AppAppearance.current.colors
        guard colors.count > 1 else {
            layer?.backgroundColor = colors[0].cgColor
            return
        }

        layer?.backgroundColor = nil
        let gradient = CAGradientLayer()
        gradient.name = "CaptureImage.AppearanceGradient"
        gradient.colors = colors.map(\.cgColor)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        layer?.insertSublayer(gradient, at: 0)
    }

    @MainActor static func updateGradientFrame(in view: NSView) {
        view.layer?.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .filter { $0.name == "CaptureImage.AppearanceGradient" }
            .forEach { $0.frame = view.bounds }
    }

    @MainActor static func fillBackground(in path: NSBezierPath) {
        let colors = AppAppearance.current.colors
        guard colors.count > 1 else {
            colors[0].setFill()
            path.fill()
            return
        }
        NSGradient(colors: colors)?.draw(in: path, angle: -45)
    }
}

private extension NSColor {
    convenience init(hex: Int) {
        self.init(
            calibratedRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
