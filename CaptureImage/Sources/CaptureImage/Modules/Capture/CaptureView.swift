import AppKit
import Carbon

final class CaptureOverlayWindow: NSWindow {
    var onCapture: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private let overlayView = CaptureOverlayView()
    private var combinedScreenFrame: CGRect {
        NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
    }

    init() {
        super.init(
            contentRect: NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) },
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        animationBehavior = .none
        isReleasedWhenClosed = false
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        overlayView.autoresizingMask = [.width, .height]
        contentView = overlayView

        overlayView.onCapture = { [weak self] localRect in
            guard let self else { return }
            let globalRect = localRect.offsetBy(dx: self.frame.minX, dy: self.frame.minY)
            self.onCapture?(globalRect)
        }
        overlayView.onCancel = { [weak self] in
            self?.onCancel?()
        }
    }

    func show() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            setFrame(combinedScreenFrame, display: true)
            CaptureLogger.info("Showing overlay window over frame \(frame.debugDescription)")
            makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func dismissWithoutAnimation() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            orderOut(nil)
            close()
        }
    }

    override var canBecomeKey: Bool { true }
}

final class CaptureOverlayView: NSView {
    var onCapture: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        window?.makeFirstResponder(self)
        CaptureLogger.info("Overlay view moved to window with bounds \(bounds.debugDescription)")
    }

    override func draw(_ dirtyRect: NSRect) {
        CaptureTheme.overlayScrim.setFill()
        bounds.fill()

        guard let selectionRect else {
            drawHelpText()
            return
        }

        NSColor.white.withAlphaComponent(0.95).setFill()
        selectionRect.fill(using: .destinationOut)

        CaptureTheme.accent.setStroke()
        let path = NSBezierPath(rect: selectionRect)
        path.lineWidth = 2
        path.stroke()

        drawSizeLabel(for: selectionRect)
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        CaptureLogger.info("Overlay mouse down at \(String(describing: startPoint))")
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        guard let rect = selectionRect, rect.width >= AppConstants.minimumCaptureSize, rect.height >= AppConstants.minimumCaptureSize else {
            CaptureLogger.info("Overlay mouse up without valid selection")
            onCancel?()
            return
        }
        CaptureLogger.info("Overlay mouse up with selection \(rect.debugDescription)")
        onCapture?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            onCancel?()
        }
    }

    private var selectionRect: CGRect? {
        guard let startPoint, let currentPoint else { return nil }
        return CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(startPoint.x - currentPoint.x),
            height: abs(startPoint.y - currentPoint.y)
        )
    }

    private func drawHelpText() {
        let text = AppText.value(.dragToCapture)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let size = text.size(withAttributes: attributes)
        let point = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
        text.draw(at: point, withAttributes: attributes)
    }

    private func drawSizeLabel(for rect: CGRect) {
        let text = "\(Int(rect.width)) x \(Int(rect.height))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let size = text.size(withAttributes: attributes)
        let labelRect = CGRect(x: rect.minX, y: rect.maxY + 8, width: size.width + 16, height: size.height + 8)
        let background = NSBezierPath(roundedRect: labelRect, xRadius: 8, yRadius: 8)
        CaptureTheme.accent.setFill()
        background.fill()
        text.draw(at: CGPoint(x: labelRect.minX + 8, y: labelRect.minY + 4), withAttributes: attributes)
    }
}
