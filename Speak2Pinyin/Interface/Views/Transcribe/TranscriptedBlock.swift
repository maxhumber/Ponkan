import Foundation

struct TranscriptedBlock: Identifiable, Codable {
    var id = UUID()
    var heard: String
    var correction = ""
    var flagged = false
    
    init(_ string: String) {
        self.heard = string
    }
    
    var pinyin: String {
        heard.pinyin()
    }
    
    var kind: Kind {
        if heard.isChinese { return .chinese }
        if heard.isNumber { return .number }
        if heard.isPunctuation { return .punctuation }
        if heard.isWhitespace { return .whitespace }
        return .other
    }
    
    var hasCorrection: Bool {
        !correction.isEmpty
    }
    
    enum Kind: Codable {
        case chinese
        case number
        case punctuation
        case whitespace
        case other
    }
}
