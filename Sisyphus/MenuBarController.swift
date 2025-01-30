import AppKit
import SwiftUI

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    override init() {
        super.init()
        print("menu bar controller")
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            print("Button Created")
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Sisyphus Clipboard")
            button.action = #selector(togglePopover(_:))
            button.target = self
        } else {
            print("Failed to create button!")
        }

        let contentView = ClipboardHistoryView()
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc func togglePopover(_ sender: Any?) {
        print("toggling popover")
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
