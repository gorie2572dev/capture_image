import Foundation

protocol FileNameBuilding {
    static func screenshotName(sourceAppName: String, date: Date) -> String
}

enum FileNameBuilder: FileNameBuilding {
    static func screenshotName(sourceAppName: String, date: Date) -> String {
        let safeAppName = sanitized(sourceAppName)
        return "\(safeAppName)_\(timestamp(date)).png"
    }

    private static func sanitized(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = value
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "_" }
            .map(String.init)
            .joined()
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return sanitized.isEmpty ? "Capture" : sanitized
    }

    private static func timestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: date)
    }
}
