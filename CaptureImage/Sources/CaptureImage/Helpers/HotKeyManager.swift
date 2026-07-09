import Carbon
import Foundation

@MainActor
protocol HotKeyManaging {
    func registerCaptureShortcut(handler: @escaping () -> Void) throws
}

@MainActor
final class HotKeyManager: HotKeyManaging {
    nonisolated(unsafe) private var hotKeyRef: EventHotKeyRef?
    nonisolated(unsafe) private var hotKeyHandler: EventHandlerRef?
    private var handler: (() -> Void)?

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let hotKeyHandler {
            RemoveEventHandler(hotKeyHandler)
        }
    }

    func registerCaptureShortcut(handler: @escaping () -> Void) throws {
        self.handler = handler

        let hotKeyID = EventHotKeyID(signature: OSType("CIMG".fourCharCode), id: 1)
        let status = RegisterEventHotKey(
            UInt32(AppShortcut.captureArea.carbonKeyCode),
            UInt32(AppShortcut.captureArea.carbonModifiers),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard status == noErr else {
            throw HotKeyError.registrationFailed(status)
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, eventRef, userData in
            guard let eventRef, let userData else { return noErr }

            var receivedID = EventHotKeyID()
            GetEventParameter(
                eventRef,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &receivedID
            )

            if receivedID.id == 1 {
                let managerPointer = userData
                Task { @MainActor in
                    let manager = Unmanaged<HotKeyManager>.fromOpaque(managerPointer).takeUnretainedValue()
                    manager.handler?()
                }
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &hotKeyHandler
        )
    }
}

enum HotKeyError: LocalizedError {
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .registrationFailed(let status):
            return "Hotkey registration failed with status \(status)."
        }
    }
}
