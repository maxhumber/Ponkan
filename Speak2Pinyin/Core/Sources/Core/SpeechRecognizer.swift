import AVFoundation
import Foundation
import Speech
import SwiftUI

extension String {
    public func pinyin() -> String {
        guard !self.isEmpty else { return "" }
        let cfString = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        let result: String = cfString! as String
        return result
    }
}


enum RecognizerError: Error {
    case nilRecognizer
    case notAuthorizedToRecognize
    case notPermittedToRecord
    case recognizerIsUnavailable
    
    var message: String {
        switch self {
        case .nilRecognizer: return "Can't initialize speech recognizer"
        case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
        case .notPermittedToRecord: return "Not permitted to record audio"
        case .recognizerIsUnavailable: return "Recognizer is unavailable"
        }
    }
}

public final class SpeechRecognizer {
    private let session: AVAudioSession
    private let recognizer: SFSpeechRecognizer?
    private var engine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    public init() {
        self.session = AVAudioSession.sharedInstance()
        self.recognizer = SFSpeechRecognizer(locale: .init(identifier: "zh-CN"))
    }
    
    deinit {
        reset()
    }
    
    public func start() async throws {
        guard let recognizer else { throw RecognizerError.nilRecognizer }
        guard recognizer.isAvailable else { throw RecognizerError.recognizerIsUnavailable }
        guard await recognizer.hasAuthorizationToRecognize() else { throw RecognizerError.notAuthorizedToRecognize }
        guard await session.hasPermissionToRecord() else { throw RecognizerError.notPermittedToRecord }
        let (engine, request) = try setup()
        self.engine = engine
        self.request = request
    }
    
    public func transcribe() -> AsyncThrowingStream<String?, Error> {
        recognizer!.recognitionTask(with: request!)
    }
                                                  
    public func stop() {
        reset()
    }
    
    private func reset() {
        engine?.stop()
        engine = nil
        request = nil
    }
    
    private func setup() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        return (audioEngine, request)
    }
}

extension SFSpeechRecognizer {
    func recognitionTask(with request: SFSpeechAudioBufferRecognitionRequest) -> AsyncThrowingStream<String?, Error> {
        AsyncThrowingStream { continuation in
            recognitionTask(with: request) { result, error in
                if error != nil { continuation.finish(throwing: error) }
                if result?.isFinal == true { continuation.finish() }
                continuation.yield(result?.bestTranscription.formattedString)
            }
        }
    }
}

extension SFSpeechRecognizer {
    func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            Self.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
