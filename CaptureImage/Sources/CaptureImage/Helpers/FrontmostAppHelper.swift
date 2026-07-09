import AppKit

protocol FrontmostAppProviding {
    var name: String { get }
}

struct FrontmostAppHelper: FrontmostAppProviding {
    var name: String {
        NSWorkspace.shared.frontmostApplication?.localizedName ?? "Capture"
    }
}
