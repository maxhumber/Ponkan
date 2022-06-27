import SwiftUI
import AVFoundation
import Speech
import Core

final class ViewModel: ObservableObject {
    @Published var text = ""
    private let recognizer = SpeechRecognizer()
    private var task: Task<(), Never>?
    
    @MainActor func start() {
        task = Task(priority: .userInitiated) {
            do {
                try await recognizer.start()
                for try await text in recognizer.transcribe() {
                    if let text {
                        self.text = text
                    }
                }
            } catch {
                print(error)
                recognizer.stop()
            }
        }
    }
    
    func stop() {
        recognizer.stop()
        task?.cancel()
        task = nil
    }
}

struct ContentView: View {
    @State var text: String = ""
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.text.pinyin())
                .textSelection(.enabled)
            
            Button {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    print(granted)
                }
            } label: {
                Text("Enable Microphone")
            }
            Button {
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    print(authStatus)
                }
            } label: {
                Text("Enable Recognition")
            }
            
            Button {
                viewModel.start()
            } label: {
                Text("Start")
            }
            
            Button {
                viewModel.stop()
            } label: {
                Text("Stop & Reset")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
