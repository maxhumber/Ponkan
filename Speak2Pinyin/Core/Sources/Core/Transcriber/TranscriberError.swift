import Foundation

public enum TranscriberError: Error {
    case notAvailable
    case notAuthorizedToRecognizeSpeech
    case notAuthorizedToRecordAudio
}
