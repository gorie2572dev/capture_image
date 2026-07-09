import AppKit

protocol CaptureStoring {
    var saveDirectory: URL { get }
    func save(image: NSImage, sourceAppName: String) throws -> URL
}

struct CaptureStore: CaptureStoring {
    let fileNameBuilder: any FileNameBuilding.Type

    var saveDirectory: URL {
        let pictures = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
        return pictures.appendingPathComponent("CaptureImage", isDirectory: true)
    }

    func save(image: NSImage, sourceAppName: String) throws -> URL {
        CaptureLogger.info("Ensuring save directory exists: \(saveDirectory.path)")
        try FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        let fileName = fileNameBuilder.screenshotName(sourceAppName: sourceAppName, date: Date())
        let url = saveDirectory.appendingPathComponent(fileName)
        CaptureLogger.info("Encoding screenshot as PNG: \(url.path)")

        guard
            let tiff = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let data = bitmap.representation(using: .png, properties: [:])
        else {
            CaptureLogger.error("Failed to encode PNG")
            throw CaptureError.couldNotEncodePNG
        }

        try data.write(to: url, options: .atomic)
        CaptureLogger.info("Saved screenshot bytes: \(data.count)")
        return url
    }
}

enum CaptureError: LocalizedError {
    case couldNotEncodePNG
    case couldNotReadScreenImage
    case screenRecordingPermissionDenied

    var errorDescription: String? {
        switch self {
        case .couldNotEncodePNG:
            return AppText.value(.couldNotEncodePNG)
        case .couldNotReadScreenImage:
            return AppText.value(.couldNotReadScreenImage)
        case .screenRecordingPermissionDenied:
            return AppText.value(.screenRecordingPermissionDenied)
        }
    }
}
