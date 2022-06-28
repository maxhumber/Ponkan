import Speech

extension SFSpeechRecognizer {
    func isAuthorizedToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            Self.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
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
