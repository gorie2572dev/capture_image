enum CaptureModuleBuilder {
    @MainActor
    static func build() -> any CapturePresenting {
        let store = CaptureStore(fileNameBuilder: FileNameBuilder.self)
        let interactor = CaptureInteractor(
            imageCapturer: ScreenImageCapturer(),
            store: store,
            clipboard: ClipboardHelper()
        )
        let router = CaptureRouter()
        let presenter = CapturePresenter(
            interactor: interactor,
            router: router,
            frontmostApp: FrontmostAppHelper(),
            hotKey: HotKeyManager()
        )
        return presenter
    }
}
