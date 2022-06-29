import Foundation

extension String {
    public func pinyin() -> String {
        if isEmpty { return "" }
        let cfString = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        return cfString! as String
    }
    
    public func atomize() -> [String] {
        var words = [String]()
        enumerateSubstrings(in: startIndex..., options: .byWords) { substring, range, enclosedRange, _ in
            words.append(substring!)
            words += self[range.upperBound..<enclosedRange.upperBound]
                .split { $0.isWhitespace }
                .map { String($0) }
        }
        return words
    }
    
    public var isWhitespace: Bool {
        rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
    
    var isChinese: Bool {
        guard range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) != nil else { return false }
        return true
    }
    
    var isNumber: Bool {
        !isEmpty && rangeOfCharacter(from: .decimalDigits.inverted) == nil
    }
    
    var isPunctuation: Bool {
        map { $0 }.allSatisfy { $0.isPunctuation }
    }
}
