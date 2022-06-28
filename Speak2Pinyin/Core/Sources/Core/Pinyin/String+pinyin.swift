import Foundation

extension String {
    public func pinyin() -> String {
        if isEmpty { return "" }
        let cfString = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        return cfString! as String
    }
}
