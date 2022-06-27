import SwiftUI
import AVFoundation
import Speech
import Core

final class ViewModel: ObservableObject {
    @Published var text = ""
    @Published var active = false
    private var transcriber: any Transcribing = Transcriber(locale: "zh-CN")
    private var task: Task<Void, Never>?
    
    @MainActor func start() {
        if active { return }
        active = true
        task = Task(priority: .userInitiated) {
            do {
                try await transcriber.start()
                for try await text in transcriber.transcribe() {
                    if let text {
                        self.text = text
                    }
                }
            } catch {
                stop()
            }
        }
    }
    
    func stop() {
        transcriber.stop()
        task?.cancel()
        task = nil
        active = false
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .foregroundColor(.red)
                .opacity(viewModel.active ? 1 : 0)
            
            Text(viewModel.text)
            
            Text(viewModel.text.pinyin())
            
            Button {
                viewModel.start()
            } label: {
                Text("Start")
            }
            
            Button {
                viewModel.stop()
            } label: {
                Text("Stop")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
