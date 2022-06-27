import AVFoundation
import Foundation
import Speech
import SwiftUI

extension String {
    public func pinyin() -> String {
        if isEmpty { return "" }
        let cfString = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(cfString, nil, kCFStringTransformToLatin, false)
        return cfString! as String
    }
}

public enum TranscriberError: Error {
    case notAuthorizedToRecognizeSpeech
    case notAuthorizedToRecordAudio
}

public protocol Transcribing {
    mutating func start() async throws
    func transcribe() -> AsyncThrowingStream<String?, Error>
    mutating func stop()
}

public struct Transcriber: Transcribing {
    private let recognizer: SFSpeechRecognizer
    private let bus: AVAudioNodeBus
    private let frames: AVAudioFrameCount
    private let session: AVAudioSession
    private var engine: AVAudioEngine!
    private var request: SFSpeechRecognitionRequest!
    
    public init(locale: String = "en-US", bus: AVAudioNodeBus = 0, frames: AVAudioFrameCount = 1024, session: AVAudioSession = .sharedInstance()) {
        self.recognizer = SFSpeechRecognizer(locale: .init(identifier: locale))!
        self.bus = bus
        self.frames = frames
        self.session = session
    }
    
    public mutating func start() async throws {
        guard await recognizer.isAuthorizedToRecognize() else { throw TranscriberError.notAuthorizedToRecognizeSpeech }
        guard await session.isAuthorizedToRecord() else { throw TranscriberError.notAuthorizedToRecordAudio }
        engine = AVAudioEngine()
        request = SFSpeechRecognitionRequest(engine, bus, frames)
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        engine.prepare()
        try engine.start()
    }
    
    public func transcribe() -> AsyncThrowingStream<String?, Error> {
//        recognizer.stream(request)
        AsyncThrowingStream { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if error != nil {
                    continuation.finish(throwing: error)
                }
                if result?.isFinal == true {
                    continuation.finish()
                }
                continuation.yield(result?.bestTranscription.formattedString)
            }
        }
    }

    public mutating func stop() {
        engine?.stop()
        engine?.inputNode.removeTap(onBus: bus)
        engine = nil
        request = nil
    }
}

extension SFSpeechRecognizer {
    func stream(_ request: SFSpeechAudioBufferRecognitionRequest) -> AsyncThrowingStream<String?, Error> {
        AsyncThrowingStream { continuation in
            recognitionTask(with: request) { result, error in
                if error != nil { continuation.finish(throwing: error) }
                if result?.isFinal == true { continuation.finish() }
                continuation.yield(result?.bestTranscription.formattedString)
            }
        }
    }
}

typealias SFSpeechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest

extension SFSpeechRecognitionRequest {
    convenience init(_ engine: AVAudioEngine, _ bus: AVAudioNodeBus = 0, _ frames: AVAudioFrameCount = 1024) {
        self.init()
        self.shouldReportPartialResults = true
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: bus)
        inputNode.installTap(onBus: bus, bufferSize: frames, format: recordingFormat) { buffer, _ in
            self.append(buffer)
        }
    }
}

extension SFSpeechRecognizer {
    func isAuthorizedToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            Self.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func isAuthorizedToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
