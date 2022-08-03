import AVFoundation
import Core
import Foundation
import Speech

@MainActor final class NewTranscribeViewModel: ObservableObject {
    @Published var history = [String]()
    @Published var current = ""
    @Published var listening = false
    
    private let service = TranscriptionService(.mandarin)
    private var task: Task<Void, Never>?
    
    init(_ text: String = "", active: Bool = false) {
        self.current = text
        self.listening = active
    }
    
    func toggle() {
        listening ? stop() : start()
    }
    
    func newline() {
        stop()
        start()
    }
    
    var newlineIsDisplayed: Bool {
        listening && !current.isEmpty
    }
    
    private func start() {
        if !current.isEmpty { history.append(current) }
        current = ""
        listening = true
        task = Task(priority: .userInitiated) {
            do {
                try await service.start()
                for try await text in service.transcribe() {
                    if let text = text {
                        self.current = text.pinyin()
                    }
                }
            } catch {
                print(error)
                stop()
            }
        }
    }
    
    private func stop() {
        listening = false
        service.stop()
        task?.cancel()
        task = nil
    }
    
    func clear() {
        history = []
        current = ""
    }
}
