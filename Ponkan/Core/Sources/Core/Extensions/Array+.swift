import Foundation

extension Array where Element == String {
    func rejoined() -> String {
        var str = ""
        for (a, b) in zip(self, self.dropFirst(1)) {
            str += a
            if !b.isPunctuation {
                str += " "
            }
        }
        if let last = last {
            str += last
        }
        return str
    }
}
