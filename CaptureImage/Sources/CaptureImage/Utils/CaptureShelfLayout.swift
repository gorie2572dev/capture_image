struct CaptureShelfLayout {
    let itemHeight: Double
    let spacing: Double
    let verticalInset: Double
    let counterHeight: Double

    func visibleItems<Item>(from items: [Item], availableHeight: Double) -> (items: [Item], overflowCount: Int) {
        guard !items.isEmpty else {
            return ([], 0)
        }

        let capacityWithoutCounter = capacity(for: availableHeight, reservesCounter: false)
        if items.count <= capacityWithoutCounter {
            return (Array(items.prefix(capacityWithoutCounter)), 0)
        }

        let capacityWithCounter = capacity(for: availableHeight, reservesCounter: true)
        let visible = Array(items.prefix(capacityWithCounter))
        return (visible, max(0, items.count - visible.count))
    }

    private func capacity(for availableHeight: Double, reservesCounter: Bool) -> Int {
        let counterSpace = reservesCounter ? counterHeight + spacing : 0
        let usableHeight = max(0, availableHeight - verticalInset * 2 - counterSpace)
        return max(1, Int((usableHeight + spacing) / (itemHeight + spacing)))
    }
}
