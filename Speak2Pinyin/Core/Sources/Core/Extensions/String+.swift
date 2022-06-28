import Foundation

extension String {
    public func explode() -> [String] {
        var words = [String]()
        enumerateSubstrings(in: startIndex..., options: .byWords) { substring, range, enclosedRange, _ in
            words.append(substring!)
            let start = range.upperBound
            let end = enclosedRange.upperBound
            words += self[start..<end]
                .split { $0.isWhitespace }
                .map { String($0) }
        }
        return words
    }
    
    public var isChinese: Bool {
        guard range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) != nil else { return false }
        return true
    }
    
    public var isNumber: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    public var isWhitespace: Bool {
        rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
    
    public var isPunctuation: Bool {
        map { $0 }.allSatisfy { $0.isPunctuation }
    }
}
