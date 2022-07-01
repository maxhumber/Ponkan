import Foundation

public struct Stopwatch {
    public var timeStart: Date?
    public var timeEnd: Date?
    
    public init(timeStart: Date? = nil, timeEnd: Date? = nil) {
        self.timeStart = timeStart
        self.timeEnd = timeEnd
    }
    
    public var seconds: Double? {
        guard let timeStart = timeStart, let timeEnd = timeEnd else { return nil }
        return timeStart.distance(to: timeEnd)
    }
    
    public mutating func start() {
        timeEnd = nil
        timeStart = .now
    }
    
    public mutating func stop() {
        timeEnd = .now
    }
}
