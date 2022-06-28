import AVFoundation
import Foundation
import Speech

/// A Multi-lingual Language Transcriber using AVFoundation + Speech
public final class Transcriber: Transcribing {
    private let recognizer: SFSpeechRecognizer
    private let bus: AVAudioNodeBus
    private let frames: AVAudioFrameCount
    private let session: AVAudioSession
    private var engine: AVAudioEngine!
    private var request: SFSpeechAudioBufferRecognitionRequest!
    
    /// Initialize transcriber
    /// - Parameters:
    ///   - locale: Local identifier to use (see: https://www.apple.com/ios/feature-availability/#quicktype-keyboard-dictation)
    ///   - bus: Bus onto which the request will be installed
    ///   - frames: BufferSize for the SFSpeechAudioBufferRecognitionRequest
    ///   - session: AVAudioSession used to capture audio
    public init(locale: String = "en-US", bus: AVAudioNodeBus = 0, frames: AVAudioFrameCount = 1024, session: AVAudioSession = .sharedInstance()) {
        self.recognizer = SFSpeechRecognizer(locale: .init(identifier: locale))!
        self.bus = bus
        self.frames = frames
        self.session = session
    }
    
    /// Initialize transcriber
    /// - Parameters:
    ///   - language: Language with on-device support
    ///   - bus: Bus onto which the request will be installed
    ///   - frames: BufferSize for the SFSpeechAudioBufferRecognitionRequest
    ///   - session: AVAudioSession used to capture audio
    public init(_ language: TranscriberLanguage = .english(), bus: AVAudioNodeBus = 0, frames: AVAudioFrameCount = 1024, session: AVAudioSession = .sharedInstance()) {
        self.recognizer = SFSpeechRecognizer(locale: .init(identifier: language.code))!
        self.bus = bus
        self.frames = frames
        self.session = session
    }
    
    /// Start transcription
    public func start() async throws {
        guard recognizer.isAvailable else { throw TranscriberError.notAvailable }
        guard await recognizer.isAuthorizedToRecognize() else { throw TranscriberError.notAuthorizedToRecognizeSpeech }
        guard await session.isAuthorizedToRecord() else { throw TranscriberError.notAuthorizedToRecordAudio }
        engine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest(engine, bus, frames)
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        engine.prepare()
        try engine.start()
    }
    
    /// Transcribe audio
    /// - Returns: An async throwing stream of (optional) strings
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
        recognizer.stream(request)
    }
    
    /// Stop transcription
    public func stop() {
        engine?.stop()
        engine?.inputNode.removeTap(onBus: bus)
        engine = nil
        request = nil
        try? session.setActive(false)
    }
}
