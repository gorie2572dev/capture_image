import Testing
@testable import CaptureImage

struct CaptureShelfLayoutTests {
    @Test func newestItemsStayAtTopWithinAvailableHeight() {
        let layout = CaptureShelfLayout(itemHeight: 120, spacing: 10, verticalInset: 20, counterHeight: 28)
        let result = layout.visibleItems(from: ["newest", "middle", "oldest"], availableHeight: 340)

        #expect(result.items == ["newest", "middle"])
        #expect(result.overflowCount == 1)
    }

    @Test func overflowIsZeroWhenAllItemsFit() {
        let layout = CaptureShelfLayout(itemHeight: 120, spacing: 10, verticalInset: 20, counterHeight: 28)
        let result = layout.visibleItems(from: ["one", "two"], availableHeight: 420)

        #expect(result.items == ["one", "two"])
        #expect(result.overflowCount == 0)
    }
}
