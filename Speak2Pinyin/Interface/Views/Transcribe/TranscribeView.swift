import SwiftUI
import Core
import Sugar

struct TranscribeView: View {
    @StateObject var viewModel: TranscribeViewModel
    
    init(transcription: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(transcription: transcription, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            header
            content
            micButton
        }
    }
    
    private var header: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .opacity(0)
            Spacer()
            ZStack {
                Text("100%").opacity(0)
                if let score = viewModel.score {
                    Text(score)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            FlowGrid {
                ForEach($viewModel.blocks) { $block in
                    Button {
                        block.flagged.toggle()
                    } label: {
                        makeLabel(block)
                    }
                    .disabled(viewModel.active)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func makeLabel(_ block: TranscriptFragment) -> some View {
        VStack {
            Text(block.pinyin)
                .font(.caption)
                .opacity(0)
            Text(block.pinyin) {
                $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: block.flagged ? .red : .clear)
            }
            .font(.title)
        }
        .padding(block.isPunctuation ? 0 : 10)
        .foregroundColor(block.isPunctuation ? .secondary : .primary)
        .foregroundColor(.primary)
    }
    
    private var micButton: some View {
        Button {
            viewModel.toggle()
        } label: {
            Image(systemName: viewModel.active ? "mic.slash" : "mic")
                .font(.title3)
                .foregroundColor(.white)
                .padding(20)
                .background(
                    Circle().foregroundColor(viewModel.active ? .red : .blue)
                        .shadow(radius: 2, x: 0, y: 3)
                )
        }
    }
}

struct TranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        TranscribeView(transcription: "我爱你。 你也爱我吗？")
    }
}
