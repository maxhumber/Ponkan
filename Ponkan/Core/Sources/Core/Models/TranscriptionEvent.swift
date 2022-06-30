import Foundation

public struct TranscriptionEvent: Codable {
    public var id: UUID
    public var date: Date
    public var seconds: Double
    public var wordsCorrect: Int
    public var wordsTotal: Int
    
    public init(id: UUID = .init(), date: Date = .now, seconds: Double, wordsCorrect: Int, wordsTotal: Int) {
        self.id = id
        self.date = date
        self.seconds = seconds
        self.wordsCorrect = wordsCorrect
        self.wordsTotal = wordsTotal
    }
}
