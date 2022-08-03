import SwiftUI

struct TranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: TranscribeViewModel
    
    init(_ text: String = "", listening: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text, listening: listening))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .opacity(0)
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach($viewModel.history, id: \.self) { $text in
                            Text(viewModel.pinyin ? text.pinyin() : text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(viewModel.pinyin ? viewModel.current.pinyin() : viewModel.current)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "arrow.turn.down.left")
                            .font(.system(size: viewModel.fontSize-2))
                            .foregroundColor(.blue)
                            .onTapGesture { viewModel.newline() }
                            .opacity(viewModel.newlineIsDisplayed ? 1 : 0)
                        Image(systemName: "circle")
                            .opacity(0)
                            .id("LAST")
                    }
                    .font(.system(size: viewModel.fontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.current) { _ in
                    reader.scrollTo("LAST")
                }
            }
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    HStack {
                        Image(systemName: "textformat.size.smaller")
                            .font(.title2)
                        Slider(value: $viewModel.fontSize, in: 20...40)
                            .tint(.primary)
                        Image(systemName: "textformat.size.larger")
                            .font(.title2)
                    }
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
                                .stroke(.primary)
                        )
                        .foregroundColor(.primary)
                        .font(.caption)
                    }
                }
                .opacity(viewModel.settingsIsDisplayed ? 1 : 0)
                HStack(spacing: 0) {
                    Button {
                        viewModel.clear()
                    } label: {
                        Image(systemName: "clear")
                            .padding(10)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(viewModel.listening ? 0 : 1)
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
                    Button {
                        viewModel.settingsIsDisplayed.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                    }
                    .opacity(viewModel.listening ? 0 : 1)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
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
                )
                .foregroundColor(.primary)
                .font(.title3)
            }
            .padding()
        }
        .background(
            Color.secondary
                .opacity(0.04)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct TranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        TranscribeView()
    }
}
