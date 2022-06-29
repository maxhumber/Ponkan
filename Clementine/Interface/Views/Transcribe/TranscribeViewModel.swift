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
    
    private var totalFragments: Int {
        validFragments.count
    }
    
    private var correctFragments: Int {
        validFragments.filter { !$0.flagged }.count
    }
    
    private var score: Double? {
        if validFragments.isEmpty || totalFragments <= 0 { return nil }
        return Double(correctFragments) / Double(totalFragments)
    }
    
    var stringWords: String {
        guard totalFragments > 0 else { return "?" }
        return "\(totalFragments)"
    }
    
    var stringSeconds: String {
        guard let seconds = stopwatch.seconds else { return "?" }
        return "\(String(format: "%0.f", seconds))s"
    }
    
    var stringWordsPerMinute: String {
        guard let seconds = stopwatch.seconds else { return "?" }
        let value = Double(totalFragments) / seconds * 60
        return String(format: "%0.f", value)
    }
    
    var stringScore: String {
        guard let score else { return "?" }
        return formatter.string(from: NSNumber(value: score)) ?? "?"
    }
    
    func toggle() {
        active ? stop() : start()
    }
    
    private func start() {
        fragments = []
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
