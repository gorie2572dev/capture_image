import AppKit

struct CaptureRequest {
    let rect: CGRect
    let sourceAppName: String
}

struct CaptureResult {
    let image: NSImage
    let fileURL: URL
}
