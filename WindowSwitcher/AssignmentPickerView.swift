import SwiftUI
import ApplicationServices

struct AssignmentPickerView: View {
    @ObservedObject var bindingStore: WindowBindingStore
    @State private var windows: [WindowInfo] = []
    @State private var searchText = ""
    @State private var selectedWindow: WindowInfo?
    @State private var showingSlotPicker = false
    @State private var showingOverwriteConfirm = false
    @State private var pendingSlot: Int?
    
    var filteredWindows: [WindowInfo] {
        if searchText.isEmpty {
            return windows
        }
        return windows.filter { window in
            window.displayLabel.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search windows…", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Window list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredWindows.indices, id: \.self) { index in
                        WindowRowView(
                            window: filteredWindows[index],
                            bindingStore: bindingStore,
                            onAssign: { window in
                                selectedWindow = window
                                showingSlotPicker = true
                            }
                        )
                        
                        if index < filteredWindows.count - 1 {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            refreshWindows()
        }
        .sheet(isPresented: $showingSlotPicker) {
            SlotPickerView(
                window: selectedWindow,
                bindingStore: bindingStore,
                onConfirm: { slot in
                    guard let window = selectedWindow else { return }
                    
                    // Check if slot is already occupied
                    if bindingStore.binding(for: slot) != nil {
                        pendingSlot = slot
                        showingSlotPicker = false
                        showingOverwriteConfirm = true
                    } else {
                        assignBinding(window: window, slot: slot)
                        showingSlotPicker = false
                    }
                }
            )
        }
        .alert("Overwrite Existing Shortcut?", isPresented: $showingOverwriteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Overwrite", role: .destructive) {
                if let window = selectedWindow, let slot = pendingSlot {
                    assignBinding(window: window, slot: slot)
                }
            }
        } message: {
            if let slot = pendingSlot, let existing = bindingStore.binding(for: slot) {
                Text("⌥\(slot) is currently assigned to:\n\(existing.displayLabel)\n\nDo you want to replace it?")
            }
        }
    }
    
    private func refreshWindows() {
        windows = WindowEnumerator.enumerateWindows()
    }
    
    private func assignBinding(window: WindowInfo, slot: Int) {
        let binding = WindowBinding(
            axWindow: window.axWindow,
            pid: window.pid,
            displayLabel: window.displayLabel
        )
        bindingStore.bind(slot: slot, window: binding)
    }
}

struct WindowRowView: View {
    let window: WindowInfo
    @ObservedObject var bindingStore: WindowBindingStore
    let onAssign: (WindowInfo) -> Void
    
    var assignedSlot: Int? {
        bindingStore.bindings.first(where: { $0.value.displayLabel == window.displayLabel })?.key
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: window.appIcon)
                .resizable()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(window.appName)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(window.windowTitle)
                    .font(.system(size: 13))
            }
            
            Spacer()
            
            if let slot = assignedSlot {
                Text("⌥\(slot)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Button("Assign") {
                onAssign(window)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct SlotPickerView: View {
    let window: WindowInfo?
    @ObservedObject var bindingStore: WindowBindingStore
    let onConfirm: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Shortcut Slot")
                .font(.headline)
            
            if let window = window {
                HStack {
                    Image(nsImage: window.appIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading) {
                        Text(window.appName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(window.windowTitle)
                            .font(.body)
                    }
                }
                .padding()
            }
            
            VStack(spacing: 8) {
                ForEach(1...6, id: \.self) { slot in
                    Button(action: {
                        onConfirm(slot)
                        dismiss()
                    }) {
                        HStack {
                            Text("⌥\(slot)")
                                .font(.system(size: 16, design: .monospaced))
                                .frame(width: 40, alignment: .leading)
                            
                            if let existing = bindingStore.binding(for: slot) {
                                Text(existing.displayLabel)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            } else {
                                Text("(Available)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(bindingStore.binding(for: slot) != nil ? Color.secondary.opacity(0.1) : Color.accentColor.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
            Button("Cancel") {
                dismiss()
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(width: 400)
    }
}
