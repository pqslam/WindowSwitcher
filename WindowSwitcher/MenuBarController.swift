import Cocoa
import SwiftUI
import Combine

class MenuBarController {
    private var statusItem: NSStatusItem!
    private let bindingStore: WindowBindingStore
    private var assignmentPopover: NSPopover?
    
    init(bindingStore: WindowBindingStore) {
        self.bindingStore = bindingStore
        setupStatusItem()
    }
    
    private func setupStatusItem() {
        // Create status item with SF Symbol icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // SF Symbol with text fallback for visibility
            if let image = NSImage(systemSymbolName: "rectangle.stack", accessibilityDescription: "WindowSwitcher") {
                button.image = image
                button.image?.isTemplate = true
            } else {
                button.title = "WS"
            }
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        updateMenu()
        
        // Observe binding changes to update menu
        bindingStore.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateMenu()
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @objc private func statusBarButtonClicked() {
        updateMenu()
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        
        // Show current bindings
        if bindingStore.bindings.isEmpty {
            let item = NSMenuItem(title: "No shortcuts assigned", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for slot in 1...6 {
                if let binding = bindingStore.binding(for: slot) {
                    let item = NSMenuItem(title: "⌥\(slot) — \(binding.displayLabel)", action: nil, keyEquivalent: "")
                    item.isEnabled = false
                    menu.addItem(item)
                }
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Assign Shortcut…
        let assignItem = NSMenuItem(title: "Assign Shortcut…", action: #selector(showAssignmentPicker), keyEquivalent: "")
        assignItem.target = self
        menu.addItem(assignItem)
        
        // Clear All Assignments
        let clearItem = NSMenuItem(title: "Clear All Assignments", action: #selector(clearAllBindings), keyEquivalent: "")
        clearItem.target = self
        clearItem.isEnabled = !bindingStore.bindings.isEmpty
        menu.addItem(clearItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func showAssignmentPicker() {
        let pickerView = AssignmentPickerView(bindingStore: bindingStore)
        let hostingView = NSHostingController(rootView: pickerView)
        
        let popover = NSPopover()
        popover.contentViewController = hostingView
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 500, height: 600)
        
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        
        assignmentPopover = popover
    }
    
    @objc private func clearAllBindings() {
        bindingStore.clearAll()
    }
}
