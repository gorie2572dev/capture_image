import Foundation

enum CaptureLogger {
    static var logFileURL: URL {
        resolvedLogDirectory().appendingPathComponent("captureimage.log")
    }

    static func info(_ message: @autoclosure () -> String) {
        log(level: "INFO", message: message())
    }

    static func error(_ message: @autoclosure () -> String) {
        log(level: "ERROR", message: message())
    }

    static func markLaunch() {
        info("Log file: \(logFileURL.path)")
        info("Current directory: \(FileManager.default.currentDirectoryPath)")
        info("Home directory: \(FileManager.default.homeDirectoryForCurrentUser.path)")
        info("Bundle path: \(Bundle.main.bundlePath)")
    }

    private static let queue = DispatchQueue(label: "dev.tien.captureimage.logger")

    private static func log(level: String, message: String) {
        let line = "[CaptureImage] [\(level)] \(message)"
        NSLog(line)

        let fileLine = "\(timestamp()) \(line)\n"
        queue.async {
            append(fileLine, to: logFileURL)
        }
    }

    private static func append(_ line: String, to url: URL) {
        do {
            let directory = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path, contents: nil)
            }

            let handle = try FileHandle(forWritingTo: url)
            defer {
                try? handle.close()
            }
            try handle.seekToEnd()
            if let data = line.data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
        } catch {
            NSLog("[CaptureImage] [ERROR] Could not write log file: \(error.localizedDescription)")
        }
    }

    private static func resolvedLogDirectory() -> URL {
        let fileManager = FileManager.default

        if let override = ProcessInfo.processInfo.environment["CAPTUREIMAGE_LOG_DIR"], !override.isEmpty {
            return URL(fileURLWithPath: override, isDirectory: true)
        }

        let currentProject = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
            .appendingPathComponent("logs", isDirectory: true)
        if canUseDirectory(currentProject) {
            return currentProject
        }

        let home = fileManager.homeDirectoryForCurrentUser
        let documentsProject = home
            .appendingPathComponent("Documents", isDirectory: true)
            .appendingPathComponent("New MacOS Tool", isDirectory: true)
            .appendingPathComponent("CaptureImage", isDirectory: true)
            .appendingPathComponent("logs", isDirectory: true)
        if canUseDirectory(documentsProject) {
            return documentsProject
        }

        let workingProject = home
            .appendingPathComponent("working", isDirectory: true)
            .appendingPathComponent("CaptureImage", isDirectory: true)
            .appendingPathComponent("logs", isDirectory: true)
        if canUseDirectory(workingProject) {
            return workingProject
        }

        return home
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Logs", isDirectory: true)
            .appendingPathComponent("CaptureImage", isDirectory: true)
    }

    private static func canUseDirectory(_ url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }

    private static func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}
