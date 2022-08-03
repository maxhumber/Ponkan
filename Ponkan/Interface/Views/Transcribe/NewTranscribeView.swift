import SwiftUI

struct NewTranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: NewTranscribeViewModel
    @State private var fontSize: Double = 25
    
    init(_ text: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .foregroundColor(.red)
                .opacity(viewModel.listening ? 1 : 0)
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.history, id: \.self) { text in
                            Text(text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                        }
                        Text(viewModel.current)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("LAST")
                    }
                    .font(.system(size: fontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.current) { _ in
                    reader.scrollTo("LAST")
                }
            }
            VStack {
                HStack {
                    Text("10")
                    Slider(value: $fontSize, in: 20...40)
                    Text("30")
                }
                .padding()
                HStack(spacing: 20) {
                    Button {
                        viewModel.toggle()
                    } label: {
                        Text("Start/Stop")
                    }
                    Button {
                        viewModel.clear()
                    } label: {
                        Text("Clear")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct NewTranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        NewTranscribeView()
    }
}
