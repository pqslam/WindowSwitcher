# WindowSwitcher

A native macOS menu bar app that assigns keyboard shortcuts (Option+1 through Option+6) to specific windows across all applications.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- 🎯 **Quick Window Switching**: Assign any open window to Option+1-6 shortcuts
- 🔍 **Smart Window Picker**: Searchable list of all open windows across all apps
- 🪟 **Multi-Window Support**: Handle multiple windows of the same app (e.g., Chrome profiles)
- 🚀 **Fast Activation**: Instantly bring windows to front, un-minimize, and switch Spaces
- 📱 **Menu Bar Only**: Clean interface, no Dock icon
- 🔒 **Sandboxed**: App Store ready, uses only public APIs
- 💾 **Session-Based**: In-memory bindings (no persistence between launches)

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (for building)
- Accessibility permission (granted on first launch)

## Installation

### Option 1: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/WindowSwitcher.git
   cd WindowSwitcher
   ```

2. Open in Xcode:
   ```bash
   open WindowSwitcher.xcodeproj
   ```

3. Build and run (⌘R) or archive for release

4. Copy built app to Applications:
   ```bash
   # After building in Xcode
   cp -R ~/Library/Developer/Xcode/DerivedData/WindowSwitcher-*/Build/Products/Release/WindowSwitcher.app /Applications/
   ```

### First Launch

1. Right-click `WindowSwitcher.app` → Open (bypasses Gatekeeper warning)
2. Grant Accessibility permission when prompted
3. Menu bar icon appears

### Auto-Start on Login (Optional)

1. Open System Settings → General → Login Items
2. Click `+` and select `WindowSwitcher.app`

## Usage

1. **Assign a shortcut:**
   - Click menu bar icon
   - Select "Assign Shortcut..."
   - Search or browse windows
   - Click slot number (1-6) next to desired window

2. **Switch to window:**
   - Press Option+1 through Option+6
   - Window activates, un-minimizes if needed, switches Space if necessary

3. **Clear bindings:**
   - Click menu bar icon → "Clear All"

## Architecture

Built with modern macOS APIs:

- **Accessibility API** (`AXUIElement`) - Window enumeration and control
- **Carbon Event Manager** - Global hotkey registration (Option+1-6)
- **SwiftUI** - Window picker interface
- **AppKit** - Menu bar presence (`NSStatusItem`)

### Key Components

- `WindowEnumerator.swift` - Discovers all windows via Accessibility API
- `HotkeyManager.swift` - Registers and handles global hotkeys
- `WindowActivator.swift` - Brings windows to front, handles stale references
- `AssignmentPickerView.swift` - SwiftUI picker with search
- `WindowBindingStore.swift` - In-memory slot→window mapping

## Technical Details

### Why Accessibility API?

`CGWindowListCopyWindowInfo` can list windows but returns non-actionable references. Accessibility API provides `AXUIElement` handles that can raise, un-minimize, and control windows reliably.

### Sandboxing

App uses App Sandbox entitlement. Accessibility API and Carbon hotkeys work within sandbox without additional entitlements.

### Stale Window Detection

When a bound window closes, activation returns `false`. Binding is automatically cleared and user is notified via menu.

## Limitations

- Bindings reset on app quit (session-based, no persistence)
- Some system windows may not be enumerable (by design)
- Requires Accessibility permission

## Development

### Project Structure

```
WindowSwitcher/
├── WindowSwitcher.xcodeproj/
├── WindowSwitcher/
│   ├── AppDelegate.swift           # App lifecycle
│   ├── main.swift                  # Entry point
│   ├── MenuBarController.swift     # Menu bar UI
│   ├── WindowEnumerator.swift      # Window discovery
│   ├── HotkeyManager.swift         # Global hotkey handling
│   ├── WindowActivator.swift       # Window activation logic
│   ├── WindowBindingStore.swift    # Binding storage
│   ├── AssignmentPickerView.swift  # SwiftUI picker
│   ├── Info.plist                  # LSUIElement=true
│   ├── WindowSwitcher.entitlements # App Sandbox
│   └── Assets.xcassets/            # App icons
└── README.md
```

### Building

```bash
# Debug build
xcodebuild -project WindowSwitcher.xcodeproj -scheme WindowSwitcher -configuration Debug build

# Release build
xcodebuild -project WindowSwitcher.xcodeproj -scheme WindowSwitcher -configuration Release build
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Issues and pull requests welcome. Please ensure:
- Code follows existing style
- App remains sandboxed (no private APIs)
- Maintains macOS 13.0+ compatibility

## Acknowledgments

Built with Swift, AppKit, and SwiftUI. Uses public Apple APIs only.

---

**Note**: This app requires Accessibility permission to enumerate and control windows. Permission is requested on first launch and can be managed in System Settings → Privacy & Security → Accessibility.
