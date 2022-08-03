import Foundation

public enum TranscriptionServiceError: LocalizedError {
    case notAvailable
    case notAuthorizedToRecognizeSpeech
    case notAuthorizedToRecordAudio
    case missingResult
    
    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Transcription API not Available"
        case .notAuthorizedToRecognizeSpeech:
            return "Not Authorized to Recognize Speech"
        case .notAuthorizedToRecordAudio:
            return "Not Authorized to Capture Audio"
        case .missingResult:
            return "Transcription Result Missing"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .notAvailable:
            return "Please wait a little while and try again soon."
        case .notAuthorizedToRecognizeSpeech:
            return "Please enable authorization in System Settings, and try again."
        case .notAuthorizedToRecordAudio:
            return "Please enable authorization in System Settings, and try again."
        case .missingResult:
            return "Please quit/restart the app, and try again."
        }
    }
}
