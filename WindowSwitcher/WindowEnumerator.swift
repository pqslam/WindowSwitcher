import Cocoa
import ApplicationServices

struct WindowInfo {
    let axWindow: AXUIElement
    let pid: pid_t
    let appName: String
    let appIcon: NSImage
    let windowTitle: String
    
    var displayLabel: String {
        "\(appName) — \(windowTitle)"
    }
}

class WindowEnumerator {
    static func enumerateWindows() -> [WindowInfo] {
        NSLog("🔍 WindowEnumerator called")
        let trusted = AXIsProcessTrusted()
        NSLog("🔒 AXIsProcessTrusted: \(trusted)")
        
        var windows: [WindowInfo] = []
        
        let runningApps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        NSLog("📱 Found \(runningApps.count) apps")
        
        for app in runningApps {
            guard let appName = app.localizedName, let appIcon = app.icon else {
                continue
            }
            
            let pid = app.processIdentifier
            NSLog("  → \(appName)")
            let appElement = AXUIElementCreateApplication(pid)
            
            var windowsValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXWindowsAttribute as CFString,
                &windowsValue
            )
            
            NSLog("    AXResult: \(result.rawValue)")
            
            guard result == .success,
                  let windowArray = windowsValue as? [AXUIElement] else {
                continue
            }
            
            NSLog("    Windows: \(windowArray.count)")
            
            for axWindow in windowArray {
                var titleValue: CFTypeRef?
                let titleResult = AXUIElementCopyAttributeValue(
                    axWindow,
                    kAXTitleAttribute as CFString,
                    &titleValue
                )
                
                guard titleResult == .success,
                      let windowTitle = titleValue as? String,
                      !windowTitle.isEmpty else {
                    continue
                }
                
                let info = WindowInfo(
                    axWindow: axWindow,
                    pid: pid,
                    appName: appName,
                    appIcon: appIcon,
                    windowTitle: windowTitle
                )
                windows.append(info)
            }
        }
        
        NSLog("✅ Total: \(windows.count) windows")
        return windows
    }
}
