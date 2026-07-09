import AppKit

enum CaptureTheme {
    static let background = NSColor(hex: 0xFAF8F3)
    static let sidebar = NSColor(hex: 0xF3F1EA)
    static let surface = NSColor.white
    static let border = NSColor(hex: 0xE5E0D8)
    static let textPrimary = NSColor(hex: 0x34322F)
    static let textSecondary = NSColor(hex: 0x77736A)
    static let accent = NSColor(hex: 0xD97757)
    static let accentSoft = NSColor(hex: 0xF3DDD3)
    static let darkStatus = NSColor(hex: 0x2F302D)
    static let alertDot = NSColor(hex: 0x2D8CDE)
    static let overlayScrim = NSColor.black.withAlphaComponent(0.24)
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
