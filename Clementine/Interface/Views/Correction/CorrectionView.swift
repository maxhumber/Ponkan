import SwiftUI
import Core
import Sugar

struct CorrectionView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Binding var fragment: TranscriptFragment
    @FocusState var focused: Bool
    
    var body: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            Text(fragment.pinyin) {
                $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .red)
            }
            .font(.largeTitle)
            TextField("correction", text: $fragment.correction ?? "")
//                .submitLabel(.done)
                .focused($focused)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
//                        Button {
//
//                        } label: {
//                            Text("hey!")
//                        }
//                        Button {
//
//                        } label: {
//                            Text("hey!")
//                        }

                        PinyinKeys($fragment.correction ?? "")
                    }
                }
        }
        .font(.title)
        .onAppear { focused = true }
    }
}

struct CorrectionView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var fragment = TranscriptFragment("柑桔")
        
        var body: some View {
            CorrectionView(fragment: $fragment)
        }
    }
}
