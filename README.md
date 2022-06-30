<div align="center">
  <img alt="ponkan" src="https://raw.githubusercontent.com/maxhumber/Ponkan/master/Images/logo.png" height="200px">
</div>


### About

Hi, I'm Max! I made Ponkan to help me study Mandarin. *Nǐ hǎo, wǒ jiào Max! Wǒ zhìzuò “Ponkan” yīnwèi wǒ yào xuéxí zhōngwén.* (Obviously, I still have a long way to go!)

Ponkan is a speech-to-text app that converts Mandarin Chinese to [Pinyin](https://en.wikipedia.org/wiki/Pinyin), in real time<sup>†</sup> The app is for beginners who like and need immediate feedback while practising in order to correct and improve pronunciation. 

I use Ponkan to practise my Mandarin in the same way that I use [MonkeyType](https://monkeytype.com/) to improve my typing. 



### Download 

[![BreadBuddy Download Link](https://raw.githubusercontent.com/maxhumber/BreadBuddy/master/Marketing/Logos/AppStore.svg)](https://apps.apple.com/app/id1620912870)



### Screenshots

<h3>
  <img src="https://raw.githubusercontent.com/maxhumber/BreadBuddy/master/Marketing/Screenshots/screenshot_13pm_1.png" height="300px" alt="BreadBuddy1">
  <img src="https://raw.githubusercontent.com/maxhumber/BreadBuddy/master/Marketing/Screenshots/screenshot_13pm_2.png" height="300px" alt="BreadBuddy2">
  <img src="https://raw.githubusercontent.com/maxhumber/BreadBuddy/master/Marketing/Screenshots/screenshot_13pm_3.png" height="300px" alt="BreadBuddy3">
  <img src="https://raw.githubusercontent.com/maxhumber/BreadBuddy/master/Marketing/Screenshots/screenshot_13pm_4.png" height="300px" alt="BreadBuddy4">
</h3>



### Design

Ponkan is a modern SwiftUI/MVVM app. Whereas the *iOS Dev Tutorial* on [Transcribing Speech to Text](https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text) uses `DispatchQueue` + completion handlers, and sticks all of the logic directly onto the View, Ponkan leverages `async/await` and is organized according to [CADI](https://github.com/maxhumber/BreadBuddy#%EF%B8%8F-cadi).



### Core

Ponkan is powered by the [Speech](https://developer.apple.com/documentation/speech) and [AVFoundation](https://developer.apple.com/documentation/avfoundation) APIs. The core Ponkan [`TranscriptionService`](https://github.com/maxhumber/Ponkan/blob/master/Ponkan/Core/Sources/Core/Services/Transcription/TranscriptionService.swift) wraps and converts the output from `SFSpeechRecognizer` to an `AsyncThrowingStream` of strings which allows a ViewModel to manage and orchestrate speech recognition tasks...

The main `transcribe` method on the service looks like this:

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

Which enables the ViewModel to capture output like this:

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

I have a running joke with my partner that I'm not quite a Mandarin (speaker) yet, I'm still just a little clementine (in my abilities). Unfortunately, "Clementine" is already an app, so I had to settle for [ponkan](https://en.wikipedia.org/wiki/Ponkan), another type of small mandarin orange. While not my first choice, the name is growing on me!



### Disclaimer

<sup>† While the (on-device) speech recognition APIs provided by Apple—and used in this app—are *pretty good*, they're not 100% perfect. So, if Ponkan isn't able to recognize 100% of your "100% perfect" pronunciation, blame Apple! 😘</sup>
