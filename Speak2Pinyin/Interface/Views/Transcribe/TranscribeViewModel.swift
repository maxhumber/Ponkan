import AVFoundation
import Foundation
import Speech
import Core

@MainActor final class TranscribeViewModel: ObservableObject {
    @Published var blocks = [TranscriptedBlock]()
    @Published var active = false
    private var task: Task<Void, Never>? = nil
    private let transcriber: any Transcribing = Transcriber(.mandarin)
    
    init(transcription: String = "", active: Bool = false) {
        self.blocks = blockify(transcription)
        self.active = active
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
    
    var score: String? {
        let validBlocks = blocks.filter { $0.kind == .chinese }
        if validBlocks.isEmpty || active { return nil }
        let wrong = validBlocks.filter { $0.flagged }.count
        let total = validBlocks.count
        let correct = 1 - (Double(wrong) / Double(total))
        return formatter.string(from: NSNumber(value: correct))
    }
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 1
        return formatter

    }

    func blockify(_ text: String) -> [TranscriptedBlock] {
        text.explode().filter { !$0.isWhitespace }.map { TranscriptedBlock($0) }
    }
    
    private func stop() {
        transcriber.stop()
        task?.cancel()
        task = nil
        active = false
    }
}
