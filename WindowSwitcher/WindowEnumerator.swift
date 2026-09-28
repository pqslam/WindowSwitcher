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
        var windows: [WindowInfo] = []
        
        let runningApps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        
        for app in runningApps {
            guard let appName = app.localizedName, let appIcon = app.icon else {
                continue
            }
            
            let pid = app.processIdentifier
            let appElement = AXUIElementCreateApplication(pid)
            
            var windowsValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXWindowsAttribute as CFString,
                &windowsValue
            )
            
            guard result == .success,
                  let windowArray = windowsValue as? [AXUIElement] else {
                continue
            }
            
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
        
        return windows
    }
}
