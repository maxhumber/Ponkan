import Speech

extension SFSpeechAudioBufferRecognitionRequest {
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
