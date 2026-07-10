import AppKit
import UniformTypeIdentifiers

struct CaptureShelfItem: Identifiable {
    let id = UUID()
    let image: NSImage
    let fileURL: URL
}

@MainActor
enum CaptureShelfPresenter {
    private static var panel: NSPanel?
    private static var shelfView: CaptureShelfView?
    private static var items: [CaptureShelfItem] = []
    private static let shelfWidth: CGFloat = 260
    private static let itemHeight: CGFloat = 156
    private static let spacing: CGFloat = 12
    private static let verticalInset: CGFloat = 18
    private static let counterHeight: CGFloat = 30
    private static var zoomPanel: NSPanel?

    static func show(image: NSImage, fileURL: URL) {
        items.insert(CaptureShelfItem(image: image, fileURL: fileURL), at: 0)
        ensurePanel()
        render()
    }

    private static func ensurePanel() {
        guard panel == nil else { return }

        let view = CaptureShelfView()
        let window = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: shelfWidth, height: 400),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.contentView = view
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.ignoresMouseEvents = false

        panel = window
        shelfView = view
    }

    private static func render() {
        guard let screen = NSScreen.main, let panel, let shelfView else { return }
        guard !items.isEmpty else {
            panel.orderOut(nil)
            return
        }

        let screenFrame = screen.visibleFrame
        let availableHeight = max(itemHeight + verticalInset * 2, screenFrame.height - 36)
        let layout = CaptureShelfLayout(
            itemHeight: Double(itemHeight),
            spacing: Double(spacing),
            verticalInset: Double(verticalInset),
            counterHeight: Double(counterHeight)
        )
        let result = layout.visibleItems(from: items, availableHeight: Double(availableHeight))
        let visibleCount = items.count
        let contentHeight = verticalInset * 2
            + CGFloat(visibleCount) * itemHeight
            + CGFloat(max(0, visibleCount - 1)) * spacing
            + (result.overflowCount > 0 ? counterHeight + spacing : 0)

        let height = min(max(contentHeight, itemHeight + verticalInset * 2), availableHeight)
        let origin = CGPoint(
            x: screenFrame.minX + 18,
            y: screenFrame.maxY - height - 18
        )

        CaptureLogger.info("Rendering capture shelf on left side with \(items.count) item(s), \(result.overflowCount) outside viewport")
        panel.setFrame(CGRect(x: origin.x, y: origin.y, width: shelfWidth, height: height), display: true)
        shelfView.render(items: items, overflowCount: result.overflowCount)
        panel.orderFrontRegardless()
    }

    fileprivate static func zoom(_ item: CaptureShelfItem) {
        zoomPanel?.close()

        let imageView = NSImageView(image: item.image)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let screen = panel?.screen ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? CGRect(x: 0, y: 0, width: 960, height: 640)
        let frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: min(960, max(520, visibleFrame.width - 180)),
                height: min(680, max(380, visibleFrame.height - 180))
            )
        )
        let container = PreviewOverlayView(frame: frame)
        container.addSubview(imageView)

        let closeButton = OverlayIconButton(
            symbolName: "xmark",
            accessibilityLabel: AppText.value(.closePreview)
        )
        closeButton.target = container
        closeButton.action = #selector(PreviewOverlayView.close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 42),
            closeButton.heightAnchor.constraint(equalToConstant: 42)
        ])

        let panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.contentView = container
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.animationBehavior = .none
        panel.isReleasedWhenClosed = false
        container.onClose = { [weak panel] in
            panel?.close()
        }
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        zoomPanel = panel
    }

    fileprivate static func copy(_ item: CaptureShelfItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([item.image])
    }

    fileprivate static func openImage(_ item: CaptureShelfItem) {
        NSWorkspace.shared.open(item.fileURL)
    }

    fileprivate static func showInFinder(_ item: CaptureShelfItem) {
        NSWorkspace.shared.activateFileViewerSelecting([item.fileURL])
    }

    fileprivate static func remove(_ item: CaptureShelfItem) {
        items.removeAll { $0.id == item.id }
        render()
    }
}

final class CaptureShelfView: NSView {
    private let scrollView = NSScrollView()
    private let documentView = FlippedView()
    private let stackView = NSStackView()
    private let rootStackView = NSStackView()
    private var activeItemViews: [CaptureShelfItemView] = []
    private var overflowView: CaptureShelfOverflowView?

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(items: [CaptureShelfItem], overflowCount: Int) {
        activeItemViews.removeAll()
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for item in items {
            let itemView = CaptureShelfItemView(item: item)
            activeItemViews.append(itemView)
            stackView.addArrangedSubview(itemView)
            itemView.heightAnchor.constraint(equalToConstant: 156).isActive = true
            itemView.widthAnchor.constraint(equalToConstant: 226).isActive = true
        }

        if let overflowView {
            rootStackView.removeArrangedSubview(overflowView)
            overflowView.removeFromSuperview()
        }
        overflowView = nil

        if overflowCount > 0 {
            let counter = CaptureShelfOverflowView(count: overflowCount)
            rootStackView.addArrangedSubview(counter)
            counter.heightAnchor.constraint(equalToConstant: 30).isActive = true
            counter.widthAnchor.constraint(equalToConstant: 226).isActive = true
            overflowView = counter
        }

        documentView.layoutSubtreeIfNeeded()
        scrollView.contentView.scroll(to: CGPoint(x: 0, y: 0))
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }

    private func setup() {
        rootStackView.orientation = .vertical
        rootStackView.alignment = .centerX
        rootStackView.spacing = 12
        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.verticalScrollElasticity = .allowed
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView

        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.addSubview(stackView)
        rootStackView.addArrangedSubview(scrollView)
        addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17),
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),

            scrollView.widthAnchor.constraint(equalToConstant: 226),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 156),

            documentView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),

            stackView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: documentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor)
        ])
    }
}

final class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

final class CaptureShelfItemView: NSView, NSDraggingSource {
    private let item: CaptureShelfItem
    private let filePromiseDelegate: CaptureFilePromiseDelegate
    private let removeButton = OverlayIconButton(symbolName: "xmark", accessibilityLabel: AppText.value(.removeFromList))
    private var mouseDownEvent: NSEvent?
    private var trackingArea: NSTrackingArea?

    init(item: CaptureShelfItem) {
        self.item = item
        self.filePromiseDelegate = CaptureFilePromiseDelegate(sourceURL: item.fileURL)
        super.init(frame: CGRect(x: 0, y: 0, width: 226, height: 156))
        wantsLayer = true
        removeButton.alphaValue = 0
        removeButton.target = self
        removeButton.action = #selector(removeFromList)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(removeButton)
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            removeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let imageRect = bounds
        NSGraphicsContext.saveGraphicsState()
        NSBezierPath(roundedRect: imageRect, xRadius: 14, yRadius: 14).addClip()
        drawImageAspectFill(in: imageRect)
        NSGraphicsContext.restoreGraphicsState()
    }

    override func updateTrackingAreas() {
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseEnteredAndExited, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }

    override func mouseEntered(with event: NSEvent) {
        removeButton.animator().alphaValue = 1
    }

    override func mouseExited(with event: NSEvent) {
        removeButton.animator().alphaValue = 0
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownEvent = event
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(contextMenuItem(title: AppText.value(.zoomImage), action: #selector(zoomImage)))
        menu.addItem(contextMenuItem(title: AppText.value(.copyImage), action: #selector(copyImage)))
        menu.addItem(contextMenuItem(title: AppText.value(.openImage), action: #selector(openImage)))
        menu.addItem(contextMenuItem(title: AppText.value(.showInFinder), action: #selector(showInFinder)))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(contextMenuItem(title: AppText.value(.removeFromList), action: #selector(removeFromList)))
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    override func mouseDragged(with event: NSEvent) {
        guard let mouseDownEvent else { return }

        let provider = NSFilePromiseProvider(fileType: UTType.png.identifier, delegate: filePromiseDelegate)
        let draggingItem = NSDraggingItem(pasteboardWriter: provider)
        draggingItem.setDraggingFrame(bounds, contents: item.image)
        beginDraggingSession(with: [draggingItem], event: mouseDownEvent, source: self)
        self.mouseDownEvent = nil
    }

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        .copy
    }

    private func contextMenuItem(title: String, action: Selector) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
        menuItem.target = self
        return menuItem
    }

    @objc private func zoomImage() {
        CaptureShelfPresenter.zoom(item)
    }

    @objc private func copyImage() {
        CaptureShelfPresenter.copy(item)
    }

    @objc private func openImage() {
        CaptureShelfPresenter.openImage(item)
    }

    @objc private func showInFinder() {
        CaptureShelfPresenter.showInFinder(item)
    }

    @objc private func removeFromList() {
        CaptureShelfPresenter.remove(item)
    }

    private func drawImageAspectFill(in rect: CGRect) {
        guard item.image.size.width > 0, item.image.size.height > 0 else { return }

        let imageSize = item.image.size
        let scale = max(rect.width / imageSize.width, rect.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let drawRect = CGRect(
            x: rect.midX - drawSize.width / 2,
            y: rect.midY - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )
        item.image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
    }
}

final class OverlayIconButton: NSButton {
    init(symbolName: String, accessibilityLabel: String) {
        super.init(frame: .zero)
        image = NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityLabel)
        image?.size = CGSize(width: 14, height: 14)
        contentTintColor = .white
        isBordered = false
        bezelStyle = .regularSquare
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.42).cgColor
        layer?.cornerRadius = 14
        toolTip = accessibilityLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateLayer() {
        super.updateLayer()
        layer?.cornerRadius = bounds.height / 2
    }
}

final class CaptureShelfOverflowView: NSView {
    private let count: Int

    init(count: Int) {
        self.count = count
        super.init(frame: CGRect(x: 0, y: 0, width: 226, height: 30))
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let pill = NSBezierPath(roundedRect: bounds.insetBy(dx: 22, dy: 2), xRadius: 13, yRadius: 13)
        CaptureTheme.darkStatus.withAlphaComponent(0.58).setFill()
        pill.fill()

        let text = "+\(count)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        text.draw(
            at: CGPoint(x: bounds.midX - textSize.width / 2, y: bounds.midY - textSize.height / 2),
            withAttributes: attributes
        )
    }
}

final class PreviewOverlayView: NSView {
    var onClose: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        refreshAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appearanceDidChange(_:)),
            name: AppAppearance.didChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        CaptureTheme.updateGradientFrame(in: self)
    }

    @objc func close() {
        onClose?()
    }

    private func refreshAppearance() {
        CaptureTheme.applyBackground(to: self)
        layer?.cornerRadius = 16
        layer?.masksToBounds = true
    }

    @objc private func appearanceDidChange(_ notification: Notification) {
        refreshAppearance()
    }
}

final class CaptureFilePromiseDelegate: NSObject, NSFilePromiseProviderDelegate {
    private let sourceURL: URL

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        sourceURL.lastPathComponent
    }

    func filePromiseProvider(
        _ filePromiseProvider: NSFilePromiseProvider,
        writePromiseTo url: URL,
        completionHandler: @escaping ((any Error)?) -> Void
    ) {
        do {
            let destinationURL = url.appendingPathComponent(sourceURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
}
