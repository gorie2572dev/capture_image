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
    private var warningPanel: NSPanel?

    func presentCaptureOverlay(onCapture: @escaping (CGRect) -> Void, onCancel: @escaping () -> Void) {
        guard overlayWindow == nil else {
            CaptureLogger.info("Capture overlay already presented")
            return
        }

        let window = CaptureOverlayWindow()
        window.onCapture = { [weak self] rect in
            guard let self else { return }
            CaptureLogger.info("Overlay captured rect \(rect.debugDescription)")
            DispatchQueue.main.async {
                self.dismissOverlay()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    CaptureLogger.info("Dispatching capture after overlay dismissal")
                    onCapture(rect)
                }
            }
        }
        window.onCancel = { [weak self] in
            guard let self else { return }
            CaptureLogger.info("Overlay cancel received")
            DispatchQueue.main.async {
                self.dismissOverlay()
                onCancel()
            }
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
        warningPanel?.close()

        let contentView = CaptureWarningView(title: title, message: message) { [weak self] in
            self?.dismissWarning()
        }
        let panel = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: 460, height: 190),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = title
        panel.contentView = contentView
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.center()
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        warningPanel = panel
    }

    private func dismissOverlay() {
        CaptureLogger.info("Dismissing capture overlay")
        overlayWindow?.dismissWithoutAnimation()
        overlayWindow = nil
    }

    private func dismissWarning() {
        warningPanel?.orderOut(nil)
        warningPanel?.close()
        warningPanel = nil
    }
}

final class CaptureWarningView: NSView {
    private let onClose: () -> Void

    init(title: String, message: String, onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init(frame: CGRect(x: 0, y: 0, width: 460, height: 190))
        wantsLayer = true
        layer?.backgroundColor = CaptureTheme.background.cgColor
        build(title: title, message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(title: String, message: String) {
        let icon = NSImageView(image: NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil) ?? NSImage())
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        icon.contentTintColor = CaptureTheme.accent
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = CaptureTheme.textPrimary
        titleLabel.lineBreakMode = .byTruncatingTail

        let messageLabel = NSTextField(wrappingLabelWithString: message)
        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = CaptureTheme.textSecondary
        messageLabel.maximumNumberOfLines = 3

        let textStack = NSStackView(views: [titleLabel, messageLabel])
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let topStack = NSStackView(views: [icon, textStack])
        topStack.orientation = .horizontal
        topStack.alignment = .top
        topStack.spacing = 14
        topStack.translatesAutoresizingMaskIntoConstraints = false

        let button = NSButton(title: AppText.value(.ok), target: self, action: #selector(close))
        button.bezelStyle = .rounded
        button.keyEquivalent = "\r"
        button.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topStack)
        addSubview(button)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),

            topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            topStack.topAnchor.constraint(equalTo: topAnchor, constant: 26),

            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    @objc private func close() {
        onClose()
    }
}
