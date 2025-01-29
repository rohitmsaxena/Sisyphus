import SwiftUI
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()
        setupKeyboardShortcuts()
    }

    private func setupKeyboardShortcuts() {
        for i in 1...9 {
            let shortcutName = KeyboardShortcuts.Name("pasteItem\(i)")
            KeyboardShortcuts.onKeyDown(for: shortcutName) {
                ClipboardManager.shared.pasteItem(at: i - 1)
            }

            // Assign Command + Shift + 1...9 to the shortcuts
            let key = KeyboardShortcuts.Key(rawValue: String(i))!
            let modifiers: NSEvent.ModifierFlags = [.command, .shift]
            KeyboardShortcuts.setShortcut(.init(key, modifiers: modifiers), for: shortcutName)
        }
    }
}
 
