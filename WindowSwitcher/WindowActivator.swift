import Cocoa
import ApplicationServices

class WindowActivator {
    /// Activates the window bound to a slot, handling un-minimize and stale references
    static func activate(binding: WindowBinding, store: WindowBindingStore, slot: Int) {
        // Check if window is minimized and un-minimize
        var minimizedValue: CFTypeRef?
        let minimizedResult = AXUIElementCopyAttributeValue(binding.axWindow, kAXMinimizedAttribute as CFString, &minimizedValue)
        
        if minimizedResult == .success,
           let isMinimized = minimizedValue as? Bool,
           isMinimized {
            // Un-minimize
            AXUIElementSetAttributeValue(binding.axWindow, kAXMinimizedAttribute as CFString, false as CFTypeRef)
        }
        
        // Raise the window via kAXRaiseAction
        let raiseResult = AXUIElementPerformAction(binding.axWindow, kAXRaiseAction as CFString)
        
        if raiseResult != .success {
            // Window likely closed (stale reference)
            store.unbind(slot: slot)
            showNotification(title: "Window Closed", message: "That window was closed — shortcut cleared.")
            return
        }
        
        // Activate the owning application
        if let app = NSRunningApplication(processIdentifier: binding.pid) {
            app.activate(options: [.activateIgnoringOtherApps])
        }
        
        // Note: Cross-Space navigation should work automatically via AXRaise + activate.
        // If window is already frontmost, this becomes a no-op (expected behavior).
    }
    
    private static func showNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = nil
        NSUserNotificationCenter.default.deliver(notification)
    }
}
