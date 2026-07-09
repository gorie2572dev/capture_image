import AppKit

@MainActor
enum ShortcutMenuPresenter {
    private static var window: NSWindow?

    static func show(rows: [ShortcutMenuRow]) {
        window?.close()

        let contentView = ShortcutMenuView(rows: rows)
        let panel = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 300),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = contentView
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = panel
    }

    static func dismiss() {
        window?.close()
        window = nil
    }
}

final class ShortcutMenuView: NSView {
    private let rows: [ShortcutMenuRow]

    init(rows: [ShortcutMenuRow]) {
        self.rows = rows
        super.init(frame: CGRect(x: 0, y: 0, width: 420, height: 300))
        wantsLayer = true
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        let cardRect = bounds.insetBy(dx: 10, dy: 10)
        let shadowPath = NSBezierPath(roundedRect: cardRect, xRadius: 24, yRadius: 24)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
        shadow.shadowOffset = CGSize(width: 0, height: -8)
        shadow.shadowBlurRadius = 24
        shadow.set()
        CaptureTheme.darkStatus.setFill()
        shadowPath.fill()
        NSGraphicsContext.restoreGraphicsState()

        CaptureTheme.darkStatus.setFill()
        shadowPath.fill()
        CaptureTheme.accent.withAlphaComponent(0.65).setStroke()
        shadowPath.lineWidth = 1
        shadowPath.stroke()
    }

    private func build() {
        let container = NSStackView()
        container.orientation = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = NSImageView(image: NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: nil) ?? NSImage())
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        icon.contentTintColor = .white
        icon.wantsLayer = true
        icon.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.18).cgColor
        icon.layer?.cornerRadius = 12
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 52),
            icon.heightAnchor.constraint(equalToConstant: 52)
        ])

        let title = NSTextField(labelWithString: AppText.value(.shortcutTitle))
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        title.textColor = .white

        let grid = makeGrid()

        let button = NSButton(title: AppText.value(.ok), target: self, action: #selector(close))
        button.bezelStyle = .rounded
        button.keyEquivalent = "\r"

        container.addArrangedSubview(icon)
        container.addArrangedSubview(title)
        container.addArrangedSubview(grid)
        container.addArrangedSubview(button)

        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 38),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -38),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 38),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28)
        ])
    }

    private func makeGrid() -> NSGridView {
        let header = [
            headerLabel(AppText.value(.action)),
            headerLabel(AppText.value(.shortcut))
        ]
        let rowViews = rows.map { row in
            [
                bodyLabel(row.action),
                shortcutLabel(row.shortcut)
            ]
        }

        let grid = NSGridView(views: [header] + rowViews)
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.rowSpacing = 8
        grid.columnSpacing = 18
        grid.column(at: 0).xPlacement = .leading
        grid.column(at: 1).xPlacement = .trailing
        grid.column(at: 1).width = 130
        return grid
    }

    private func headerLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = CaptureTheme.accentSoft
        return label
    }

    private func bodyLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        return label
    }

    private func shortcutLabel(_ text: String) -> NSTextField {
        let label = bodyLabel(text)
        label.alignment = .right
        label.textColor = NSColor.white.withAlphaComponent(0.88)
        return label
    }

    @objc private func close() {
        ShortcutMenuPresenter.dismiss()
    }
}
