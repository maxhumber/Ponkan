import AVFoundation
import Foundation
import Speech
import Core

@MainActor final class TranscribeViewModel: ObservableObject {
    @Published var blocks = [TranscriptFragment]()
    @Published var active = false
    private var task: Task<Void, Never>? = nil
    private let transcriber = TranscriptionService(.mandarin)
    
    init(transcription: String = "", active: Bool = false) {
        self.blocks = blockify(transcription)
        self.active = active
    }
    
    private func blockify(_ text: String) -> [TranscriptFragment] {
        text.atomize()
            .filter { !$0.isWhitespace }
            .map { TranscriptFragment($0) }
    }
    
    var score: String? {
        let validBlocks = blocks.filter { $0.isChinese }
        if validBlocks.isEmpty || active { return nil }
        let wrong = validBlocks.filter { $0.flagged }.count
        let total = validBlocks.count
        let correct = 1 - (Double(wrong) / Double(total))
        return formatter.string(from: NSNumber(value: correct))
    }
    
    func toggle() {
        active ? stop() : start()
    }
    
    private func start() {
        active = true
        task = Task(priority: .userInitiated) {
            do {
                try await transcriber.start()
                for try await transcription in transcriber.transcribe() {
                    if let transcription {
                        self.blocks = blockify(transcription)
                    }
                }
            } catch {
                stop()
            }
        }
    }
    
    private func stop() {
        transcriber.stop()
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
