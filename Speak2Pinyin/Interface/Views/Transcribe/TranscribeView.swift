import SwiftUI
import Sugar

struct TranscriptedUnit: Identifiable, Equatable {
    var id = UUID()
    var original: String
    var corrected: String
    var flag: Bool = false
    
    init(_ character: Character) {
        self.original = String(character)
        self.corrected = String(character)
    }
    
//    var flag: Bool {
//        original != corrected
//    }
}

extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

struct TranscribeView: View {
    @StateObject var viewModel: TranscribeViewModel
    
    init(transcription: String = "", active: Bool = false) {
        self._viewModel = StateObject(wrappedValue: .init(transcription: transcription, active: active))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle")
                .opacity(0)
            ScrollView(showsIndicators: false) {
                FlowStack {
                    ForEach(viewModel.units) { unit in
                        VStack {
                            Text(unit.corrected.pinyin())
                                .font(.caption)
                                .opacity(0)
                            Group {
                                if unit.flag {
                                    Text("~\(unit.corrected.pinyin())~")
                                        .foregroundColor(.red)
                                } else {
                                    Text(unit.corrected.pinyin()) {
                                        $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .red)
                                    }
                                }
                            }
                            .font(.title)
                        }
                        .padding(10)
                    }
                }
                .padding(.horizontal)
            }
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
