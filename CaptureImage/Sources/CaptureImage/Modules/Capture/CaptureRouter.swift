import AppKit

@MainActor
protocol CaptureRouting {
    func presentCaptureOverlay(onCapture: @escaping (CGRect) -> Void, onCancel: @escaping () -> Void)
    func presentPreview(image: NSImage, fileURL: URL)
    func openFolder(_ url: URL)
    func showWarning(title: String, message: String)
}

@MainActor
final class CaptureRouter: CaptureRouting {
    private var overlayWindow: CaptureOverlayWindow?

    func presentCaptureOverlay(onCapture: @escaping (CGRect) -> Void, onCancel: @escaping () -> Void) {
        guard overlayWindow == nil else {
            CaptureLogger.info("Capture overlay already presented")
            return
        }

        let window = CaptureOverlayWindow()
        window.onCapture = { [weak self] rect in
            CaptureLogger.info("Overlay captured rect \(rect.debugDescription)")
            self?.dismissOverlay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                CaptureLogger.info("Dispatching capture after overlay dismissal")
                onCapture(rect)
            }
        }
        window.onCancel = { [weak self] in
            CaptureLogger.info("Overlay cancel received")
            self?.dismissOverlay()
            onCancel()
        }
        overlayWindow = window
        window.show()
    }

    func presentPreview(image: NSImage, fileURL: URL) {
        CaptureLogger.info("Presenting capture preview for \(fileURL.path)")
        CaptureShelfPresenter.show(image: image, fileURL: fileURL)
    }

    func openFolder(_ url: URL) {
        CaptureLogger.info("Opening folder with NSWorkspace: \(url.path)")
        NSWorkspace.shared.open(url)
    }

    func showWarning(title: String, message: String) {
        CaptureLogger.error("Showing warning: \(title) - \(message)")
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    private func dismissOverlay() {
        CaptureLogger.info("Dismissing capture overlay")
        overlayWindow?.close()
        overlayWindow = nil
    }
}
