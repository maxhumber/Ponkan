import SwiftUI
import Core
import Sugar

struct CorrectionView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Binding var fragment: Fragment
    @FocusState var focused: Bool
    
    var body: some View {
        content
            .onAppear { focused = true }
            .ignoresSafeArea(.keyboard)
    }
    
    private var content: some View {
        GeometryReader { geo in
            VStack {
                header
                Spacer()
                    .frame(height: geo.size.height * 0.10)
                original
                correctionField
            }
        }
    }
    
    private var header: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var original: some View {
        Text(fragment.pinyin) {
            $0.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .red)
            $0.backgroundColor = .red.opacity(0.15)
        }
        .font(.largeTitle)
    }
    
    private var correctionField: some View {
        TextField("correction", text: $fragment.correction ?? "")
            .font(.title)
            .submitLabel(.done)
            .focused($focused)
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    PinyinKeys($fragment.correction ?? "")
                }
            }
    }
}

struct CorrectionView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var fragment = Fragment("柑桔")
        
        var body: some View {
            CorrectionView(fragment: $fragment)
        }
    }
}
