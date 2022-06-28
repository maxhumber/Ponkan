import SwiftUI
import SwiftUIFlow

struct Container: Identifiable {
    var id = UUID()
    var original: String
    var corrected: String
    var random: String = "\(Int.random(in: 100...9999))"
    
    internal init(_ number: Int) {
        self.original = "\(number)"
        self.corrected = original
    }
    
    var flag: Bool {
        original != corrected
    }
}

struct FlowTestView: View {
    @State var numbers: [Container] = (1...100).map { Container($0) }
    
    
    var body: some View {
        ScrollView(.vertical) {
            VFlow(alignment: .leading, spacing: 0) {
                ForEach($numbers) { $number in
                    ContainerView(container: $number)
                }
            }
        }
    }
    
    struct ContainerView: View {
        @Binding var container: Container
        
        var body: some View {
            VStack {
                TextField(container.original, text: $container.corrected)
                    .font(.title3.monospacedDigit())
                    .multilineTextAlignment(.center)
                Text(container.random)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(container.flag ? .red : .blue.opacity(0.6))
            )
            .padding(3)
        }
    }
}

struct FlowTestView_Previews: PreviewProvider {
    static var previews: some View {
        FlowTestView()
    }
}
