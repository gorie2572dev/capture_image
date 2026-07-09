import AppKit

@MainActor
protocol CapturePresenting {
    func activate()
    func captureAreaRequested()
    func repeatLastAreaRequested()
    func openSaveFolderRequested()
}

@MainActor
final class CapturePresenter: CapturePresenting {
    private let interactor: any CaptureInteracting
    private let router: any CaptureRouting
    private let frontmostApp: any FrontmostAppProviding
    private let hotKey: any HotKeyManaging
    private var lastRect: CGRect?

    init(
        interactor: any CaptureInteracting,
        router: any CaptureRouting,
        frontmostApp: any FrontmostAppProviding,
        hotKey: any HotKeyManaging
    ) {
        self.interactor = interactor
        self.router = router
        self.frontmostApp = frontmostApp
        self.hotKey = hotKey
    }

    func activate() {
        do {
            try hotKey.registerCaptureShortcut { [weak self] in
                self?.captureAreaRequested()
            }
            CaptureLogger.info("Registered capture shortcut \(AppShortcut.captureArea.displayValue)")
        } catch {
            CaptureLogger.error("Could not register capture shortcut \(AppShortcut.captureArea.displayValue): \(error.localizedDescription)")
            router.showWarning(
                title: AppText.value(.hotkeyUnavailable),
                message: AppText.couldNotRegister(AppShortcut.captureArea.displayValue)
            )
        }
    }

    func captureAreaRequested() {
        CaptureLogger.info("Presenting capture overlay")
        router.presentCaptureOverlay(
            onCapture: { [weak self] rect in
                self?.performCapture(rect: rect)
            },
            onCancel: {
                CaptureLogger.info("Capture overlay cancelled")
            }
        )
    }

    func repeatLastAreaRequested() {
        guard let lastRect else {
            CaptureLogger.info("Repeat last area requested without a previous capture")
            NSSound.beep()
            return
        }
        CaptureLogger.info("Repeating last capture rect \(lastRect.debugDescription)")
        performCapture(rect: lastRect)
    }

    func openSaveFolderRequested() {
        CaptureLogger.info("Opening save folder \(interactor.saveDirectory.path)")
        router.openFolder(interactor.saveDirectory)
    }

    private func performCapture(rect: CGRect) {
        guard rect.width >= AppConstants.minimumCaptureSize, rect.height >= AppConstants.minimumCaptureSize else {
            CaptureLogger.info("Ignored capture rect below minimum size: \(rect.debugDescription)")
            NSSound.beep()
            return
        }

        do {
            lastRect = rect
            CaptureLogger.info("Starting capture for rect \(rect.debugDescription)")
            let request = CaptureRequest(rect: rect, sourceAppName: frontmostApp.name)
            let result = try interactor.capture(request: request)
            CaptureLogger.info("Capture succeeded: \(result.fileURL.path)")
            router.presentPreview(image: result.image, fileURL: result.fileURL)
        } catch {
            CaptureLogger.error("Capture failed: \(error.localizedDescription)")
            router.showWarning(title: AppText.value(.captureFailed), message: error.localizedDescription)
        }
    }
}
