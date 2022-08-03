import SwiftUI

struct NewTranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: NewTranscribeViewModel
    @State private var fontSize: Double = 25
    @State private var sliderIsDisplayed = false
    
    init(_ text: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .opacity(0)
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach($viewModel.history, id: \.self) { $text in
                            Text(text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(viewModel.current)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("LAST")
                        Image(systemName: "arrow.turn.down.left")
                            .font(.system(size: fontSize-2))
                            .foregroundColor(.blue)
                            .onTapGesture { viewModel.newline() }
                            .opacity(viewModel.newlineIsDisplayed ? 1 : 0)
                        Text(viewModel.current)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(0)
                    }
                    .font(.system(size: fontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.current) { _ in
                    reader.scrollTo("LAST")
                }
            }
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "textformat.size.smaller")
                        .font(.title2)
                    Slider(value: $fontSize, in: 20...40)
                    Image(systemName: "textformat.size.larger")
                        .font(.title2)
                }
                .padding(.horizontal)
                .opacity(sliderIsDisplayed ? 1 : 0)
                HStack(spacing: 0) {
                    Button {
                        viewModel.clear()
                    } label: {
                        Image(systemName: "clear")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    Button {
                        viewModel.toggle()
                    } label: {
                        ZStack {
                            Image(systemName: "mic")
                                .opacity(0)
                            Image(systemName: viewModel.listening == false ? "mic" : "pause")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(viewModel.listening == false ? .orange : .red)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    Button {
                        sliderIsDisplayed.toggle()
                    } label: {
                        Image(systemName: "textformat.size")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
                )
            }
            .padding()
        }
        .background(
            Color.secondary
                .opacity(0.05)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct NewTranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        NewTranscribeView()
    }
}
