import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController!
    var hotkeyManager: HotkeyManager!
    var bindingStore = WindowBindingStore()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAccessibilityPermission()
        
        menuBarController = MenuBarController(bindingStore: bindingStore)
        hotkeyManager = HotkeyManager(bindingStore: bindingStore)
        hotkeyManager.registerHotkeys()
    }
    
    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
