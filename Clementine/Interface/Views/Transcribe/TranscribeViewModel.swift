import AVFoundation
import Foundation
import Speech
import Core

@MainActor final class TranscribeViewModel: ObservableObject {
    @Published var selectedFragment: Fragment?
    @Published var fragments = [Fragment]()
    @Published var active = false
    @Published var correcting = false
    @Published var stopwatch = Stopwatch()
    
    private let service = TranscriptionService(.mandarin)
    private var task: Task<Void, Never>?
    
    init(_ text: String = "", active: Bool = false) {
        self.fragments = fragmentize(text)
        self.active = active
    }
    
    private func fragmentize(_ text: String) -> [Fragment] {
        text.atomize()
            .filter { !$0.isWhitespace }
            .map { Fragment($0) }
    }
    
    private var validFragments: [Fragment] {
        fragments.filter { $0.isChinese }
    }
    
    private var noValidFragments: Bool {
        validFragments.isEmpty
    }
    
    var total: (value: Int?, string: String?) {
        if noValidFragments { return (nil, nil) }
        let value = validFragments.count
        return (value, "\(value)")
    }
    
    private var correct: (value: Int?, string: String?) {
        if noValidFragments { return (nil, nil) }
        let value = validFragments.filter { !$0.flagged }.count
        return (value, "\(value)")
    }
//
//    private var accuracy: Double? {
//        if validFragments.isEmpty || active { return nil }
//        return Double(correct) / Double(total)
//    }
//
//    var score: String? {
//        if validBlocks.isEmpty || active { return nil }
//        let wrong = validBlocks.filter { $0.flagged }.count
//        let total = validBlocks.count
//
//        return formatter.string(from: NSNumber(value: correct))
//    }
    
    func toggle() {
        active ? stop() : start()
    }
    
    private func start() {
        stopwatch.start()
        active = true
        task = Task(priority: .userInitiated) {
            do {
                try await service.start()
                for try await transcription in service.transcribe() {
                    if let transcription {
                        self.fragments = fragmentize(transcription)
                    }
                }
            } catch {
                stop()
            }
        }
    }
    
    private func stop() {
        stopwatch.stop()
        service.stop()
        task?.cancel()
        task = nil
        active = false
    }
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
