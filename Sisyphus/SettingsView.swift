import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Customize Shortcuts")
                .font(.headline)
                .padding()

            ForEach(1...9, id: \.self) { i in
                HStack {
                    Text("Paste Item \(i):")
                    KeyboardShortcuts.Recorder(for: .init("pasteItem\(i)"))
                }
                .padding(.vertical, 5)
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
