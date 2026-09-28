import Foundation
import ApplicationServices

struct WindowBinding {
    let axWindow: AXUIElement
    let pid: pid_t
    let displayLabel: String
}

class WindowBindingStore: ObservableObject {
    /// In-memory bindings: slot (1-6) → WindowBinding
    @Published private(set) var bindings: [Int: WindowBinding] = [:]
    
    func bind(slot: Int, window: WindowBinding) {
        bindings[slot] = window
    }
    
    func unbind(slot: Int) {
        bindings.removeValue(forKey: slot)
    }
    
    func clearAll() {
        bindings.removeAll()
    }
    
    func binding(for slot: Int) -> WindowBinding? {
        bindings[slot]
    }
}
