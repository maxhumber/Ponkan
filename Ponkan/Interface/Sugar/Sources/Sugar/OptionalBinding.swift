import SwiftUI

public func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct OptionalBinding_Previews: PreviewProvider {
    static var previews: some View {
        OptionalBindingView()
    }
    
    struct OptionalBindingView: View {
        @State var text: String? = nil
        
        var body: some View {
            TextField("Input here", text: $text ?? "")
        }
    }
}
