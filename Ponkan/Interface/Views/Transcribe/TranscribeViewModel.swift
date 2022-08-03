import AVFoundation
import Foundation
import Speech
import Core

@MainActor final class TranscribeViewModel: ObservableObject {
    @Published var selectedFragment: Fragment?
    @Published var fragments = [Fragment]()
    @Published var listening = false
    @Published var correcting = false
    @Published var stopwatch = Stopwatch()
    @Published var error: Error?
    
    private let service = TranscriptionService(.mandarin)
    private var task: Task<Void, Never>?
    
    init(_ text: String = "", active: Bool = false) {
        self.fragments = fragmentize(text)
        self.listening = active
    }
    
    private func fragmentize(_ text: String) -> [Fragment] {
        let atoms = text.atoms.filter({ !$0.isWhitespace })
        var fragments = [Fragment]()
        for (a, b) in zip(atoms, atoms.dropFirst(1)) {
            let fragment = Fragment(a, precedesPunctuation: b.isPunctuation)
            fragments.append(fragment)
        }
        if let last = atoms.last {
            fragments.append(Fragment(last))
        }
        return fragments
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
        guard let score = score else { return "?" }
        return percentFormatter.string(from: NSNumber(value: score)) ?? "?"
    }
    
    func toggle() {
        listening ? stop() : start()
    }
    
    func clearFragments() {
        fragments = []
    }
    
    private func start() {
        fragments = []
        stopwatch.start()
        listening = true
        task = Task(priority: .userInitiated) {
            do {
                try await service.start()
                for try await transcription in service.transcribe() {
                    if let transcription = transcription {
                        self.fragments = fragmentize(transcription)
                    }
                }
            } catch {
                self.error = error
                stop()
            }
        }
    }
    
    private func stop() {
        stopwatch.stop()
        service.stop()
        task?.cancel()
        task = nil
        listening = false
    }
    
    private let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
