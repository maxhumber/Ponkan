import SwiftUI
import Core
import Sugar

extension ColorScheme {
    var isDark: Bool {
        self == .dark
    }
}

struct TranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: TranscribeViewModel
    
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
            HStack {
                accountButton
                Spacer()
                strikeButton
            }
            headerContent
        }
        .padding()
    }
    
    private var accountButton: some View {
        Button {
            print("NOT CONNECTED")
        } label: {
            Image(systemName: "person")
                .foregroundColor(.primary.opacity(0.2))
        }
        .disabled(true)
        .opacity(0)
    }
    
    private var strikeButton: some View {
        Button {
            print("NOT CONNECTED")
        } label: {
            Text("S") {
                $0.foregroundColor = .primary
                $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .red)
            }
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(pinkishColor)
            )
        }
        .opacity(0)
    }
    
    @ViewBuilder private var headerContent: some View {
        ZStack {
            statistics
                .opacity(0)
            if viewModel.active {
                Image(systemName: "circle.fill")
                    .foregroundColor(.red)
            } else if viewModel.fragments.isEmpty {
                Text("")
                    .foregroundColor(.secondary)
            } else {
                statistics
            }
        }
    }
    
    private var statistics: some View {
        HStack {
            statistic(viewModel.stringWords, label: "words")
            statistic(viewModel.stringSeconds, label: "time")
            statistic(viewModel.stringWordsPerMinute, label: "wpm")
            statistic(viewModel.stringScore, label: "score")
        }
        .foregroundColor(.secondary)
    }
    
    private func statistic(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Text("100%").opacity(0)
                Text(value)
            }
            .font(.caption.monospacedDigit())
            ZStack {
                Text("score").opacity(0)
                Text(label)
            }
            .font(.caption2)
        }
    }
    
    private var content: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                flowGrid
            }
            .onChange(of: viewModel.fragments) { _ in
                reader.scrollTo(viewModel.fragments.last?.id)
            }
        }
    }
    
    @ViewBuilder var flowGrid: some View {
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
                .id(fragment.id)
            }
        }
        .padding(.horizontal)
    }
    
    private func makeLabel(_ fragment: Fragment) -> some View {
        VStack {
            Text(fragment.correction ?? "")
                .font(.caption)
                .opacity(0)
            Text(fragment.pinyin) {
                $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: fragment.flagged ? .red : .clear)
            }
            .font(.title)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(fragment.flagged ? pinkishColor : .clear)
            )
            // .font(.title2)
            // INCREASE / DECREASE TEXT SIZE
        }
        // FIX PADDING FOR THINGS THAT LEAD PUNCTUATION...
        .padding(EdgeInsets(top: 10, leading: fragment.isPunctuation ? 0 : 0, bottom: 10, trailing: 5))
        .foregroundColor(fragment.isPunctuation ? .secondary.opacity(0.60) : .primary)
    }
    
    private var pinkishColor: Color {
        colorScheme.isDark ? .pink.opacity(0.40) : .red.opacity(0.15)
    }
    
    private var footer: some View {
        HStack(spacing: 30) {
            micButton
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
                    Circle().foregroundColor(viewModel.active ? .red : .orange)
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
