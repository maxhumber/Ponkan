import SwiftUI
import Core
import Sugar

struct TranscribeView: View {
    @StateObject var viewModel: TranscribeViewModel
    
    init(_ text: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            header
            content
            footer
        }
    }
    
    private var header: some View {
        ZStack {
            Text("100%").opacity(0)
            if let score = viewModel.score {
                Text(score)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            FlowGrid {
                ForEach($viewModel.fragments) { $fragment in
                    Button {
                        if viewModel.correcting {
                            viewModel.selectedFragment = fragment
                        } else {
                            fragment.flagged.toggle()
                        }
                    } label: {
                        makeLabel(fragment)
                    }
                    .disabled(viewModel.active)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func makeLabel(_ fragment: TranscriptFragment) -> some View {
        VStack {
            Text(fragment.correction ?? "")
                .font(.caption)
                .opacity(0)
            Text(fragment.pinyin) {
                $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: fragment.flagged ? .red : .clear)
                $0.backgroundColor = fragment.flagged ? .red.opacity(0.15) : .clear
            }
            .font(.title)
        }
        .padding(EdgeInsets(top: 10, leading: fragment.isPunctuation ? 0 : 10, bottom: 10, trailing: 10))
        .foregroundColor(fragment.isPunctuation ? .secondary.opacity(0.45) : .primary)
        .foregroundColor(.primary)
    }
    
    private var footer: some View {
        HStack(spacing: 30) {
            Image(systemName: "xmark")
            micButton
            Image(systemName: "xmark")
        }
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
        TranscribeView("我爱你。 你也爱我吗？")
    }
}
