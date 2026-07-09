import AppKit
import CoreGraphics

protocol CaptureInteracting {
    var saveDirectory: URL { get }
    func capture(request: CaptureRequest) throws -> CaptureResult
}

final class CaptureInteractor: CaptureInteracting {
    private let imageCapturer: any ScreenImageCapturing
    private let store: any CaptureStoring
    private let clipboard: any ClipboardWriting

    var saveDirectory: URL {
        store.saveDirectory
    }

    init(
        imageCapturer: any ScreenImageCapturing,
        store: any CaptureStoring,
        clipboard: any ClipboardWriting
    ) {
        self.imageCapturer = imageCapturer
        self.store = store
        self.clipboard = clipboard
    }

    func capture(request: CaptureRequest) throws -> CaptureResult {
        CaptureLogger.info("Interactor received capture request, source app: \(request.sourceAppName)")
        let image = try imageCapturer.capture(rect: request.rect)
        CaptureLogger.info("Screen image captured, saving PNG")
        let fileURL = try store.save(image: image, sourceAppName: request.sourceAppName)
        clipboard.write(image: image)
        CaptureLogger.info("Image copied to clipboard")
        return CaptureResult(image: image, fileURL: fileURL)
    }
}
