import AppKit

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    @Published var history: [ClipboardItem] = []
    
    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var isPastingFromHistory = false

    private init() {
        print("✅ ClipboardManager Initialized")
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }
    
    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let copiedItem = getClipboardItem(), history.first != copiedItem {
            addToHistory(copiedItem)
        }
    }

    private func getClipboardItem() -> ClipboardItem? {
        if let text = pasteboard.string(forType: .string) {
            return .text(text)
        }
        if let imageData = pasteboard.data(forType: .tiff) {
            return .image(imageData)
        }
        if let fileURLString = pasteboard.string(forType: .fileURL),
           let fileURL = URL(string: fileURLString) {
            print("📁 Copying File:", fileURL.path)
            do {
                let _ = try Data(contentsOf: fileURL)
                return .file(fileURL)
            } catch {
                print("❌ Failed to copy file contents:", error)
            }
        }
        if let pdfData = pasteboard.data(forType: .pdf) {
            return .pdf(pdfData)
        }
        if let rtfData = pasteboard.data(forType: .rtf) {
            return .rtf(rtfData)
        }
        if let htmlData = pasteboard.data(forType: .html) {
            return .html(htmlData)
        }
        if let rawData = pasteboard.data(forType: pasteboard.types?.first ?? NSPasteboard.PasteboardType("unknown")) {
            return .unknown(rawData)
        }
        return nil
    }

    private func addToHistory(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            print("📋 Adding to history:", item)
            self.history.insert(item, at: 0)
            if self.history.count > 9 {
                self.history.removeLast()
            }
            print("📋 Current history count:", self.history.count)
        }
    }

    /// **📌 Paste an item from clipboard history**
    func pasteItem(at index: Int) {
        guard index < history.count else {
            print("❌ Invalid index: \(index), history count: \(history.count)")
            return
        }

        let item = history[index]

        pasteboard.clearContents()

        switch item {
        case .text(let text):
            print("✅ Pasting text:", text)
            pasteboard.setString(text, forType: .string)
        case .image(let data):
            print("✅ Pasting image")
            pasteboard.setData(data, forType: .tiff)
        case .file(let url):
            print("✅ Pasting file:", url.absoluteString)
            do {
                let fileData = try Data(contentsOf: url)
                pasteboard.setData(fileData, forType: .fileContents)
            } catch {
                print("❌ Failed to read file data:", error)
            }
        case .pdf(let data):
            print("✅ Pasting PDF")
            pasteboard.setData(data, forType: .pdf)
        case .rtf(let data):
            print("✅ Pasting RTF")
            pasteboard.setData(data, forType: .rtf)
        case .html(let data):
            print("✅ Pasting HTML")
            pasteboard.setData(data, forType: .html)
        case .unknown(let data):
            print("⚠️ Pasting unknown data")
            pasteboard.setData(data, forType: NSPasteboard.PasteboardType("unknown"))
        }

        simulatePaste()
    }

    /// **📌 Simulate Cmd + V to Paste**
    func simulatePaste() {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            print("❌ Failed to create event source")
            return
        }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: false)

        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)

        print("✅ Simulated Cmd + V")
    }
}
