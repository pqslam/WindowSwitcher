import Cocoa
import Carbon

class HotkeyManager {
    private let bindingStore: WindowBindingStore
    private var hotkeyRefs: [EventHotKeyRef?] = Array(repeating: nil, count: 6)
    private var eventHandler: EventHandlerRef?
    
    init(bindingStore: WindowBindingStore) {
        self.bindingStore = bindingStore
    }
    
    func registerHotkeys() {
        // Register Option+1 through Option+6
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, event, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            
            var hotkeyID = EventHotKeyID()
            GetEventParameter(event, UInt32(kEventParamDirectObject), UInt32(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotkeyID)
            
            let slot = Int(hotkeyID.id)
            manager.handleHotkey(slot: slot)
            
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        // Register each slot (1-6)
        for slot in 1...6 {
            var hotkeyID = EventHotKeyID(signature: OSType(0x57696E64), id: UInt32(slot)) // 'Wind'
            var hotkeyRef: EventHotKeyRef?
            
            // Option + digit key
            let keyCode = UInt32([kVK_ANSI_1, kVK_ANSI_2, kVK_ANSI_3, kVK_ANSI_4, kVK_ANSI_5, kVK_ANSI_6][slot - 1])
            
            RegisterEventHotKey(keyCode, UInt32(optionKey), hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
            hotkeyRefs[slot - 1] = hotkeyRef
        }
    }
    
    func unregisterHotkeys() {
        for hotkeyRef in hotkeyRefs {
            if let ref = hotkeyRef {
                UnregisterEventHotKey(ref)
            }
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }
    
    private func handleHotkey(slot: Int) {
        guard let binding = bindingStore.binding(for: slot) else {
            // Slot empty, do nothing
            return
        }
        
        WindowActivator.activate(binding: binding, store: bindingStore, slot: slot)
    }
}
