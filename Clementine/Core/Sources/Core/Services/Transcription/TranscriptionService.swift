// Contrast with: https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text

import Foundation
import Speech

public final class TranscriptionService {
    private let recognizer: SFSpeechRecognizer
    private let bus: AVAudioNodeBus
    private let frames: AVAudioFrameCount
    private let session: AVAudioSession
    private var engine: AVAudioEngine!
    private var request: SFSpeechAudioBufferRecognitionRequest!
    
    /// Initialize service
    /// - Parameters:
    ///   - language: Languages with on-device support (or other identifier, see: https://www.apple.com/ios/feature-availability/#quicktype-keyboard-dictation)
    ///   - bus: Bus onto which the request will be installed
    ///   - frames: BufferSize for the SFSpeechAudioBufferRecognitionRequest
    ///   - session: AVAudioSession used to capture audio
    public init(_ language: Language = .english, bus: AVAudioNodeBus = 0, frames: AVAudioFrameCount = 1024, session: AVAudioSession = .sharedInstance()) {
        self.recognizer = SFSpeechRecognizer(locale: .init(identifier: language.code))!
        self.bus = bus
        self.frames = frames
        self.session = session
    }
    
    /// Start service
    public func start() async throws {
        guard recognizer.isAvailable else { throw TranscriptionServiceError.notAvailable }
        guard await recognizer.isAuthorizedToRecognize() else { throw TranscriptionServiceError.notAuthorizedToRecognizeSpeech }
        guard await session.isAuthorizedToRecord() else { throw TranscriptionServiceError.notAuthorizedToRecordAudio }
        engine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest(engine, bus, frames)
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        engine.prepare()
        try engine.start()
    }
    
    /// Transcribe audio stream
    /// - Returns: An async throwing stream of (optional) strings
    ///
    /// Example:
    /// ```
    /// try await transcriber.start()
    /// for try await transcription in transcriber.transcribe() {
    ///    if let transcription {
    ///        print(transcription)
    ///    }
    /// }
    /// ```
    public func transcribe() -> AsyncThrowingStream<String?, Error> {
        AsyncThrowingStream { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if error != nil { continuation.finish(throwing: error) }
                if result?.isFinal == true { continuation.finish() }
                continuation.yield(result?.bestTranscription.formattedString)
            }
        }
    }
    
    /// Stop service
    public func stop() {
        engine?.stop()
        engine?.inputNode.removeTap(onBus: bus)
        engine = nil
        request = nil
        try? session.setActive(false)
    }
}
