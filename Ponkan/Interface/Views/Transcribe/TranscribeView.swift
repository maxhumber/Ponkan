import SwiftUI
import Sugar

struct TranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: TranscribeViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: .init())
    }
    
    init(_ text: String, listening: Bool = false, pinyin: Bool = true, settings: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text: text, listening: listening, pinyin: pinyin, settings: settings))
    }
    
    init(_ text: [String], listening: Bool = false, pinyin: Bool = true, settings: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text: text, listening: listening, pinyin: pinyin, settings: settings))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            header
            content
            controls
        }
        .background(contentBackground)
        .errorAlert(error: $viewModel.error)
    }
    
    private var header: some View {
        Image(systemName: "circle")
            .opacity(0)
    }
    
    private var content: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    historyText
                    currentText
                    scrollmark
                }
                .font(.system(size: viewModel.fontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .onChange(of: viewModel.current) { _ in
                reader.scrollTo(viewModel.scrollmark)
            }
        }
    }
    
    private var historyText: some View {
        ForEach($viewModel.history, id: \.self) { $text in
            Text(viewModel.pinyin ? text.pinyin() : text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var scrollmark: some View {
        Image(systemName: "circle")
            .opacity(0)
            .id(viewModel.scrollmark)
    }
    
    private var currentText: some View {
        Group {
            if viewModel.activelyListening {
                activeCurrentText
            } else if viewModel.passivelyListening {
                Text("...")
                    .foregroundColor(.secondary)
            } else {
                Text(viewModel.pinyin ? viewModel.current.pinyin() : viewModel.current)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var activeCurrentText: some View {
        Group {
            Text(viewModel.pinyin ? viewModel.current.pinyin() : viewModel.current) +
            Text(" \(Image(systemName: "arrow.turn.down.left"))")
                .font(.system(size: viewModel.fontSize*0.65))
                .foregroundColor(.pink)
        }
        .onTapGesture { viewModel.newline() }
    }
    
    private var controls: some View {
        VStack(spacing: 15) {
            popUpSettings
            HStack(spacing: 0) {
                clearButton
                mainButton
                settingsButton
            }
            .foregroundColor(.primary)
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding()
            .background(controlsBackground)
        }
        .padding()
    }
    
    @ViewBuilder private var popUpSettings: some View {
        if viewModel.settingsIsDisplayed {
            HStack(spacing: 15) {
                fontSlider
                pinyinToggler
                // TODO: tipButton
            }
            .padding(.horizontal, 5)
        }
    }
    
    private var fontSlider: some View {
        HStack {
            Image(systemName: "textformat.size.smaller")
                .font(.title2)
            Slider(value: $viewModel.fontSize, in: 20...40)
                .tint(.primary)
            Image(systemName: "textformat.size.larger")
                .font(.title2)
        }
    }
    
    private var pinyinToggler: some View {
        Button {
            viewModel.pinyin.toggle()
        } label: {
            ZStack {
                Text("拼音")
                    .opacity(0)
                Text(viewModel.pinyin ? "中文" : "拼音")
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(lineWidth: 1.5)
                    .foregroundColor(.primary)
            )
            .foregroundColor(.primary)
            .font(.caption)
        }
    }
    
    private var tipButton: some View {
        Button {
            print("Tip")
        } label: {
            Image(systemName: "app.gift")
                .foregroundColor(.pink)
                .font(.title.weight(.light))
        }
    }
    
    private var clearButton: some View {
        Button {
            viewModel.clear()
        } label: {
            Image(systemName: "clear")
                .padding(10)
        }
        .frame(maxWidth: .infinity)
        .opacity(viewModel.listening ? 0 : 1)
    }
    
    private var mainButton: some View {
        Button {
            viewModel.toggle()
        } label: {
            ZStack {
                Image(systemName: "pause")
                    .opacity(0)
                Image(systemName: viewModel.listening ? "pause" : "mic")
            }
            .font(.title3.weight(viewModel.listening ? .semibold : .regular))
            .foregroundColor(viewModel.listening ? .red : .primary)
            .padding(10)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var settingsButton: some View {
        Button {
            viewModel.settingsIsDisplayed.toggle()
        } label: {
            Image(systemName: "gearshape")
                .frame(maxWidth: .infinity)
                .padding(10)
        }
        .opacity(viewModel.listening ? 0 : 1)
    }
    
    private var controlsBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.primary)
                .colorInvert()
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.primary)
            }
        }
    }
    
    private var contentBackground: some View {
        Color.secondary
            .opacity(0.04)
            .edgesIgnoringSafeArea(.all)
    }
}

struct TranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        screen1
        screen2
        screen3
    }
    
    static var screen1: some View {
        TranscribeView("我喜欢学习中文.", listening: false, pinyin: true, settings: true)
    }
    
    static var screen2: some View {
        TranscribeView("我喜欢学习中文.", listening: true, pinyin: false)
    }
    
    static var screen3: some View {
        TranscribeView(["我喜欢学习中文.", "你喜欢学习中文吗?"], listening: true)
    }
}
