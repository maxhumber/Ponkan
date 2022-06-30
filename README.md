### About

Hi, I'm Max! I made Ponkan to help me study Mandarin. 
*Nǐ hǎo, wǒ jiào Max! Wǒ zhìzuò “Ponkan” yīnwèi wǒ yào xuéxí zhōngwén.*
(Obviously, I still have a long way to go!)



### Screenshots





### Design

Ponkan is an open-source iOS app designed to contrast the *iOS Dev Tutorial* on [Transcribing Speech to Text](https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text). Whereas the linked Apple tutorial uses `DispatchQueue` + completion handlers, and sticks all of the logic directly onto the View, Ponkan leverages modern `async/await` and structures everything according to [MVVM + CADI](https://github.com/maxhumber/BreadBuddy#%EF%B8%8F-cadi).



### Code

Ponkan is powered by the `Speech` and `AVFoundation` APIs. The core Ponkan `TranscriptionService` wraps and converts the output from `SFSpeechRecognizer` to an `AsyncThrowingStream` of strings which allows a ViewModel to manage and orchestrate the speech recognition task.

The `transcribe` method on the service looks like this:

```swift 
...    
    public func transcribe() -> AsyncThrowingStream<String?, Error> {
        AsyncThrowingStream { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if error != nil { continuation.finish(throwing: error) }
                if result?.isFinal == true { continuation.finish() }
                continuation.yield(result?.bestTranscription.formattedString)
            }
        }
    }
...
```

Which enables the ViewModel to interact with the service like this:

```swift
import Core

@MainActor final class ViewModel: ObservableObject {
    @Published var text = ""
    @Published var listening = false
  
    private let service = TranscriptionService(.mandarin)
    private var task: Task<Void, Never>?
  
    private func start() {
        listening = true
        task = Task(priority: .userInitiated) {
            do {
                try await service.start()
                for try await text in service.transcribe() {
                    if let text {
                        self.text = text
                    }
                }
            } catch {
                stop()
            }
        }
    }
    
    private func stop() {
        service.stop()
        task?.cancel()
        task = nil
        listening = false
    }
}
```



### 🍊 Name

I have a running joke with my partner that I'm not quite a Mandarin (speaker) yet, I'm still just a little clementine (in my abilities). Unfortunately, "Clementine" is already an app name, so I had to settle for "Pokan", another type of small mandarin orange. While not my first choice, the name is growing on me!
