import AppKit

/// A universal storage format for clipboard items
enum ClipboardItem: Codable, Equatable {
    case text(String)
    case image(Data)
    case file(URL)
    case pdf(Data)
    case rtf(Data)
    case html(Data)
//    case movie(Data)
    case unknown(Data)
    
    /// Encode and Decode for JSON persistence
    enum CodingKeys: String, CodingKey {
        case type, data, url
    }
    
    /// ✅ Add a custom `Equatable` implementation
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        switch (lhs, rhs) {
        case (.text(let a), .text(let b)):
            return a == b
        case (.image(let a), .image(let b)):
            return a == b
        case (.file(let a), .file(let b)):
            return a == b
        case (.pdf(let a), .pdf(let b)):
            return a == b
        case (.rtf(let a), .rtf(let b)):
            return a == b
        case (.html(let a), .html(let b)):
            return a == b
        case (.unknown(let a), .unknown(let b)):
            return a == b
        default:
            return false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .data)
        case .image(let data):
            try container.encode("image", forKey: .type)
            try container.encode(data, forKey: .data)
        case .file(let url):
            try container.encode("file", forKey: .type)
            try container.encode(url, forKey: .url)
        case .pdf(let data):
            try container.encode("pdf", forKey: .type)
            try container.encode(data, forKey: .data)
        case .rtf(let data):
            try container.encode("rtf", forKey: .type)
            try container.encode(data, forKey: .data)
        case .html(let data):
            try container.encode("html", forKey: .type)
            try container.encode(data, forKey: .data)
        case .unknown(let data):
            try container.encode("unknown", forKey: .type)
            try container.encode(data, forKey: .data)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            self = .text(try container.decode(String.self, forKey: .data))
        case "image":
            self = .image(try container.decode(Data.self, forKey: .data))
        case "file":
            self = .file(try container.decode(URL.self, forKey: .url))
        case "pdf":
            self = .pdf(try container.decode(Data.self, forKey: .data))
        case "rtf":
            self = .rtf(try container.decode(Data.self, forKey: .data))
        case "html":
            self = .html(try container.decode(Data.self, forKey: .data))
        case "unknown":
            self = .unknown(try container.decode(Data.self, forKey: .data))
        default:
            self = .unknown(try container.decode(Data.self, forKey: .data))
        }
    }
}
