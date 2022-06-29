import Speech

extension SFSpeechRecognizer {
    func isAuthorizedToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            Self.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
