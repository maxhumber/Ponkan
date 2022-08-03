import AVFoundation
import Core
import Foundation
import Speech
import SwiftUI

@MainActor final class TranscribeViewModel: ObservableObject {
    @AppStorage("PINYIN") var pinyin = true
    @AppStorage("FONT_SIZE") var fontSize: Double = 25
    @Published var settingsIsDisplayed = false
    @Published var listening = false
    @Published var current = ""
    @Published var history = [String]()
    @Published var error: Error? = nil
    
    private let service = TranscriptionService(.mandarin)
    private var task: Task<Void, Never>?
    
    init(_ text: String = "", listening: Bool = false) {
        self.current = text
        self.listening = listening
    }
    
    var scrollmark: String {
        "SCROLLMARK"
    }
    
    var newlineIsDisplayed: Bool {
        listening && !current.isEmpty
    }
    
    func toggle() {
        listening ? stop() : start()
    }
    
    func newline() {
        stop(); start()
    }
    
    func clear() {
        history = []
        current = ""
    }
        
    private func start() {
        listening = true
        settingsIsDisplayed = false
        log()
        task = Task(priority: .userInitiated) {
            do {
                try await service.start()
                for try await text in service.transcribe() {
                    if let text = text {
                        self.current = text
                    }
                }
            } catch {
                self.error = error
                stop()
            }
        }
    }
    
    private func log() {
        if !current.isEmpty {
            history.append(current)
            current = ""
        }
    }
    
    private func stop() {
        listening = false
        service.stop()
        task?.cancel()
        task = nil
    }
}
