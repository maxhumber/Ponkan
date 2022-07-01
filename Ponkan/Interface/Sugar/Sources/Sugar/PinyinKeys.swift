import SwiftUI

public struct PinyinKeys: View {
    @State private var accent: Accent? = nil
    @Binding var text: String
    
    public init(_ text: Binding<String>) {
        self._text = text
    }
    
    public var body: some View {
        content
            .onChange(of: text) { modify($0) }
    }
    
    private var content: some View {
        HStack(spacing: 5) {
            ForEach(Accent.allCases) { accent in
                button(accent)
            }
        }
    }
    
    private func button(_ accent: Accent) -> some View {
        Button {
            toggle(accent)
        } label: {
            ZStack {
                Text("XX").opacity(0)
                Text(accent.rawValue)
            }
            .font(.title)
            .foregroundColor(.primary)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(.secondary)
                        .offset(y: 1.5)
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(
                            self.accent == accent ? Color("keycap-selected", bundle: .module) : Color("keycap", bundle: .module)
                        )
                }
                .compositingGroup()
                .animation(nil, value: UUID())
            )
        }
    }
    
    private func toggle(_ accent: Accent) {
        if self.accent == accent {
            self.accent = nil
        } else {
            self.accent = accent
        }
    }
    
    private func modify(_ newValue: String) {
        var string = newValue
        guard let accent = accent, let character = string.popLast() else { return }
        let modifiedCharacter = accent.modify(character)
        self.text = "\(string)\(modifiedCharacter)"
        self.accent = nil
    }
    
    private enum Accent: String, CaseIterable, Identifiable {
        case macron = "ˉ"
        case acute = "ˊ"
        case caron = "ˇ"
        case grave = "ˋ"
        
        var id: String {
            rawValue
        }
        
        func modify(_ character: Character) -> Character {
            switch (self, character) {
            case (.macron, "a"): return "ā"
            case (.macron, "e"): return "ē"
            case (.macron, "i"): return "ī"
            case (.macron, "o"): return "ō"
            case (.macron, "u"): return "ū"
            case (.acute, "a"): return "á"
            case (.acute, "e"): return "é"
            case (.acute, "i"): return "í"
            case (.acute, "o"): return "ó"
            case (.acute, "u"): return "ú"
            case (.caron, "a"): return "ǎ"
            case (.caron, "e"): return "ě"
            case (.caron, "i"): return "ǐ"
            case (.caron, "o"): return "ǒ"
            case (.caron, "u"): return "ǔ"
            case (.grave, "a"): return "à"
            case (.grave, "e"): return "è"
            case (.grave, "i"): return "ì"
            case (.grave, "o"): return "ò"
            case (.grave, "u"): return "ù"
            default: return character
            }
        }
    }
}

struct PinyinKeys_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var text = ""
        
        var body: some View {
            VStack {
                TextField("correction", text: $text)
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                PinyinKeys($text)
            }
        }
    }
}
