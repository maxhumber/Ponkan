import SwiftUI

extension View {
    public func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    
    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
    
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var error: Swift.Error?
        
        var body: some View {
            VStack {
                Text("blah blah")
                Button {
                    error = Error.titleEmpty
                } label: {
                    Text("Publish")
                }
            }.errorAlert(error: $error)
        }
    }
    
    enum Error: LocalizedError {
        case titleEmpty
        
        var errorDescription: String? {
            switch self {
            case .titleEmpty:
                return "Missing title"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .titleEmpty:
                return "Article publishing failed due to missing title"
            }
        }
    }
}
