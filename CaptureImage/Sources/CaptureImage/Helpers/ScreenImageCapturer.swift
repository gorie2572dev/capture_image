import AppKit
import CoreGraphics

protocol ScreenImageCapturing {
    func capture(rect: CGRect) throws -> NSImage
}

struct ScreenImageCapturer: ScreenImageCapturing {
    func capture(rect: CGRect) throws -> NSImage {
        guard CGPreflightScreenCaptureAccess() else {
            CaptureLogger.error("Screen Recording permission is not granted")
            _ = CGRequestScreenCaptureAccess()
            throw CaptureError.screenRecordingPermissionDenied
        }

        CaptureLogger.info("Calling CGWindowListCreateImage for rect \(rect.debugDescription)")
        guard let cgImage = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, [.bestResolution]) else {
            CaptureLogger.error("CGWindowListCreateImage returned nil")
            throw CaptureError.couldNotReadScreenImage
        }
        CaptureLogger.info("CGImage size: \(cgImage.width)x\(cgImage.height)")
        return NSImage(cgImage: cgImage, size: NSSize(width: rect.width, height: rect.height))
    }
}
