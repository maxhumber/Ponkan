import Foundation

public protocol Transcribing {
    func start() async throws
    func transcribe() -> AsyncThrowingStream<String?, Error>
    func stop()
}
