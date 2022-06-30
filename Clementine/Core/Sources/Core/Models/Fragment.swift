import Foundation

public struct Fragment: Identifiable, Codable, Equatable {
    public var id: UUID = .init()
    public var date: Date = .now
    public var heard: String
    public var correction: String? = nil
    public var flagged: Bool = false
    public var precedesPunctuation: Bool
    
    public init(_ heard: String, precedesPunctuation: Bool = false) {
        self.heard = heard
        self.precedesPunctuation = precedesPunctuation
    }
    
    public var hasCorrection: Bool {
        correction != nil
    }
    
    public var pinyin: String {
        heard.pinyin()
    }
    
    public var isChinese: Bool {
        heard.isChinese || heard.isNumber
    }
    
    public var isPunctuation: Bool {
        heard.isPunctuation
    }
}
