import SwiftUI

@main
struct SisyphusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        let types = NSPasteboard.general.types ?? []
        print("Clipboard contains types: \(types)")
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
