//
//  AppDelegate.swift
//  Sisyphus
//
//  Created by Rohit Saxena on 1/29/25.
//


import SwiftUI
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController!
    private var clipboardManager = ClipboardManager.shared 

    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardManager = ClipboardManager.shared
        menuBarController = MenuBarController()
        setupKeyboardShortcuts()
    }

    private func setupKeyboardShortcuts() {
        let keyCodes = [18, 19, 20, 21, 23, 22, 26, 28, 25] // Key codes for 1...9

        for i in 1...9 {
            let shortcutName = KeyboardShortcuts.Name("pasteItem\(i)")
            
            // ✅ Debugging print
//            print("Registering shortcut: Command + Shift + \(i) -> pasteItem\(i)")

            KeyboardShortcuts.onKeyDown(for: shortcutName) {
//                print("Shortcut pressed: Command + Shift + \(i)") // ✅ Debugging
                ClipboardManager.shared.pasteItem(at: i - 1)
            }

            let key = KeyboardShortcuts.Key(rawValue: keyCodes[i - 1]) // Use key code
            let modifiers: NSEvent.ModifierFlags = [.command, .shift] // Command + Shift
            
            KeyboardShortcuts.setShortcut(.init(key, modifiers: modifiers), for: shortcutName)
        }
    }

}
 
