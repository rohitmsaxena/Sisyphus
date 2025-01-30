import SwiftUI
import AVFoundation

struct ClipboardHistoryView: View {
    @ObservedObject private var clipboardManager = ClipboardManager.shared

    var body: some View {
        VStack {
            List(clipboardManager.history.indices, id: \.self) { index in
                let item = clipboardManager.history[index]
                ClipboardItemView(item: item, index: index)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

/// **📌 Subview for rendering different clipboard content types**
struct ClipboardItemView: View {
    let item: ClipboardItem
    let index: Int
    @State private var videoDurationText: String = "Loading..."

    var body: some View {
        HStack {
            switch item {
            case .text(let text):
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)

            case .image(let data):
                if let nsImage = NSImage(data: data) {
                    let size = nsImage.size
                    VStack {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        Text("\(Int(size.width)) × \(Int(size.height)) px")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                } else {
                    Text("Invalid Image Data")
                }

            case .file(let url):
                VStack {
                    HStack {
                        Image(systemName: isVideoFile(url) ? "video.fill" : "doc.fill")
                        Text(url.lastPathComponent)
                    }
                    if isVideoFile(url) {
                        Text(videoDurationText)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .onAppear {
                                fetchVideoDuration(url) { duration in
                                    videoDurationText = duration
                                }
                            }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)

            case .pdf, .rtf, .html, .unknown:
                Text("Unsupported Clipboard Item")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                ClipboardManager.shared.pasteItem(at: index)
            }) {
                Image(systemName: "doc.on.clipboard") // Paste icon
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    /// **📌 Determines if a file is a video**
    private func isVideoFile(_ url: URL) -> Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv"]
        return videoExtensions.contains(url.pathExtension.lowercased())
    }

    /// **📌 Fetch Video Duration (Async, macOS 13+ compatible)**
    private func fetchVideoDuration(_ url: URL, completion: @escaping (String) -> Void) {
        let asset: AVAsset

        if #available(macOS 15.0, *) {
            asset = AVURLAsset(url: url) // ✅ Use AVURLAsset in macOS 15+
        } else {
            asset = AVAsset(url: url) // ✅ Fallback for older macOS versions
        }

        if #available(macOS 13.0, *) {
            Task {
                do {
                    let duration = try await asset.load(.duration)
                    let seconds = CMTimeGetSeconds(duration)
                    DispatchQueue.main.async {
                        completion(String(format: "%.1f sec", seconds))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("Unknown")
                    }
                }
            }
        } else {
            let seconds = CMTimeGetSeconds(asset.duration)
            completion(String(format: "%.1f sec", seconds))
        }
    }
}
