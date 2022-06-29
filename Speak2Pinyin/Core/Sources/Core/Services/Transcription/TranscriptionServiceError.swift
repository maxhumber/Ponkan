import Foundation

public enum TranscriptionServiceError: Error {
    case notAvailable
    case notAuthorizedToRecognizeSpeech
    case notAuthorizedToRecordAudio
}
