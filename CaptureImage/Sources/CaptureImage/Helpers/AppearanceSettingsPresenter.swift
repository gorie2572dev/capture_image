import AppKit

@MainActor
enum AppearanceSettingsPresenter {
    private static var panel: NSPanel?

    static func show() {
        panel?.close()

        let view = AppearanceSettingsView()
        let panel = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: 500, height: 470),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = AppText.value(.appearance)
        panel.contentView = view
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.panel = panel
    }
}

final class AppearanceSettingsView: NSView {
    private let customColorWell = NSColorWell()
    private var optionButtons: [AppearanceOptionButton] = []

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 500, height: 470))
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        build()
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        let title = NSTextField(labelWithString: AppText.value(.appearanceBackground))
        title.font = .systemFont(ofSize: 18, weight: .semibold)

        let colorsLabel = sectionLabel(AppText.value(.appearanceSolidColors))
        let gradientsLabel = sectionLabel(AppText.value(.appearanceGradients))

        let colorScroller = makeHorizontalScroller(for: [
            .ivory, .graphite, .midnight, .sky, .rose, .mint,
            .lavender, .lemon, .slate, .coral
        ])
        let gradientGrid = makeGrid(for: [.ocean, .sunset, .aurora])

        customColorWell.color = AppAppearance.customColor
        customColorWell.target = self
        customColorWell.action = #selector(customColorSelected(_:))
        customColorWell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customColorWell.widthAnchor.constraint(equalToConstant: 74),
            customColorWell.heightAnchor.constraint(equalToConstant: 28)
        ])

        let customLabel = NSTextField(labelWithString: AppText.value(.appearanceCustom))
        customLabel.font = .systemFont(ofSize: 13, weight: .medium)
        let customRow = NSStackView(views: [customLabel, NSView(), customColorWell])
        customRow.orientation = .horizontal
        customRow.alignment = .centerY

        let stack = NSStackView(views: [title, colorsLabel, colorScroller, gradientsLabel, gradientGrid, customRow])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -24),
            colorScroller.widthAnchor.constraint(equalTo: stack.widthAnchor),
            colorScroller.heightAnchor.constraint(equalToConstant: 90),
            gradientGrid.widthAnchor.constraint(equalTo: stack.widthAnchor),
            customRow.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }

    private func sectionLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func makeGrid(for appearances: [AppAppearance]) -> NSGridView {
        let row = appearances.map(makeOptionCell)
        let grid = NSGridView(views: [row])
        grid.columnSpacing = 12
        grid.translatesAutoresizingMaskIntoConstraints = false
        for index in 0 ..< appearances.count {
            grid.column(at: index).width = 136
        }
        return grid
    }

    private func makeHorizontalScroller(for appearances: [AppAppearance]) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let cellWidth: CGFloat = 126
        let spacing: CGFloat = 12
        let contentWidth = CGFloat(appearances.count) * cellWidth + CGFloat(appearances.count - 1) * spacing
        let documentView = NSView(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 74))
        let row = NSStackView(views: appearances.map(makeOptionCell))
        row.orientation = .horizontal
        row.alignment = .top
        row.spacing = spacing
        row.translatesAutoresizingMaskIntoConstraints = false
        documentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
            row.topAnchor.constraint(equalTo: documentView.topAnchor)
        ])
        scrollView.documentView = documentView
        return scrollView
    }

    private func makeOptionCell(_ appearance: AppAppearance) -> NSView {
        let button = AppearanceOptionButton(appearance: appearance)
        button.target = self
        button.action = #selector(appearanceSelected(_:))
        button.translatesAutoresizingMaskIntoConstraints = false
        optionButtons.append(button)

        let label = NSTextField(labelWithString: AppText.value(appearance.localizationKey))
        label.alignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 1

        let cell = NSStackView(views: [button, label])
        cell.orientation = .vertical
        cell.alignment = .centerX
        cell.spacing = 6
        cell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.widthAnchor.constraint(equalToConstant: 126),
            button.widthAnchor.constraint(equalToConstant: 126),
            button.heightAnchor.constraint(equalToConstant: 48),
            label.widthAnchor.constraint(equalToConstant: 126)
        ])
        return cell
    }

    private func updateSelection() {
        optionButtons.forEach { $0.isSelected = $0.option == AppAppearance.current }
        customColorWell.color = AppAppearance.customColor
    }

    @objc private func appearanceSelected(_ sender: AppearanceOptionButton) {
        CaptureLogger.info("Changing appearance to \(sender.option.rawValue)")
        AppAppearance.select(sender.option)
        updateSelection()
    }

    @objc private func customColorSelected(_ sender: NSColorWell) {
        CaptureLogger.info("Changing appearance to custom color")
        AppAppearance.select(.custom, customColor: sender.color)
        updateSelection()
    }
}

final class AppearanceOptionButton: NSButton {
    let option: AppAppearance
    var isSelected = false {
        didSet { updateStyle() }
    }

    private var gradientLayer: CAGradientLayer?

    init(appearance: AppAppearance) {
        self.option = appearance
        super.init(frame: .zero)
        title = ""
        isBordered = false
        bezelStyle = .regularSquare
        focusRingType = .none
        wantsLayer = true
        toolTip = AppText.value(appearance.localizationKey)
        updateStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        gradientLayer?.frame = bounds
    }

    private func updateStyle() {
        guard let layer else { return }
        gradientLayer?.removeFromSuperlayer()

        let colors = option.colors
        if colors.count == 1 {
            layer.backgroundColor = colors[0].cgColor
            gradientLayer = nil
        } else {
            layer.backgroundColor = nil
            let gradient = CAGradientLayer()
            gradient.colors = colors.map(\.cgColor)
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = bounds
            layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        }

        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = isSelected ? 3 : 1
        layer.borderColor = isSelected ? NSColor.controlAccentColor.cgColor : NSColor.separatorColor.cgColor
        image = isSelected ? NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil) : nil
        image?.size = CGSize(width: 17, height: 17)
        contentTintColor = option.isDark ? .white : .black
    }
}
