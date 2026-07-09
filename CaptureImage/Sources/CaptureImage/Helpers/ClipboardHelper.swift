import AppKit

protocol ClipboardWriting {
    func write(image: NSImage)
}

struct ClipboardHelper: ClipboardWriting {
    func write(image: NSImage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
    }
}
