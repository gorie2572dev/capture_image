import Foundation
import Testing
@testable import CaptureImage

struct FileNameBuilderTests {
    @Test func replacesUnsafeCharactersInAppName() {
        let date = Date(timeIntervalSince1970: 1_788_198_645)
        let fileName = FileNameBuilder.screenshotName(sourceAppName: "Safari: Private / Tab", date: date)

        #expect(fileName == "Safari__Private___Tab_2026-08-31_17-50-45.png")
    }

    @Test func fallsBackWhenAppNameHasNoSafeCharacters() {
        let date = Date(timeIntervalSince1970: 1_788_198_645)
        let fileName = FileNameBuilder.screenshotName(sourceAppName: "///", date: date)

        #expect(fileName == "Capture_2026-08-31_17-50-45.png")
    }
}
