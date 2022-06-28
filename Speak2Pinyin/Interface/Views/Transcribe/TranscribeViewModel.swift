import Foundation
import AVFoundation
import Speech
import Core

@MainActor final class TranscribeViewModel: ObservableObject {
    @Published var transcription = ""
    @Published var active = false
    private var task: Task<Void, Never>? = nil
    private let transcriber: any Transcribing = Transcriber(language: .chinese())
    
    init(transcription: String = "", active: Bool = false) {
        self.transcription = transcription
        self.active = active
    }
    
    var units: [TranscriptedUnit] {
        transcription.map { TranscriptedUnit($0) }
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
                        self.transcription = transcription
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
}
