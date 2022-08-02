import SwiftUI

struct NewTranscribeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: NewTranscribeViewModel
    
    init(_ text: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(text, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .foregroundColor(.red)
                .opacity(viewModel.listening ? 1 : 0)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.history, id: \.self) { text in
                        Text(text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text(viewModel.current)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
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

struct NewTranscribeView_Previews: PreviewProvider {
    static var previews: some View {
        NewTranscribeView()
    }
}
