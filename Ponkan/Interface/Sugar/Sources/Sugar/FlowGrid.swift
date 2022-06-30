import SwiftUI

public struct FlowGrid<Content: View>: View {
    private let viewModel = ViewModel()
    private let content: () -> Content
    
    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .frame(height: 0)
                .alignmentGuide(.top) { viewModel.measure($0) }
            content()
                .alignmentGuide(.leading) { viewModel.postition($0) }
                .alignmentGuide(.top) { viewModel.offset($0) }
        }
    }
    
    final class ViewModel {
        private var spacing: CGSize = .zero
        private var available: CGFloat = .zero
        private var x: CGFloat = .zero
        private var y: CGFloat = .zero
        
        func measure(_ item: ViewDimensions) -> CGFloat {
            available = item.width
            x = 0
            y = 0
            return 0
        }
        
        func postition(_ item: ViewDimensions) -> CGFloat {
            if x + item.width > available {
                x = 0
                y += item.height + spacing.height
            }
            let result = x
            x += item.width + spacing.width
            return -result
        }
        
        func offset(_ item: ViewDimensions) -> CGFloat {
            -y
        }
    }
}

struct FlowGrid_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(showsIndicators: false) {
            FlowGrid {
                ForEach(1..<52+1) { num in
                    ZStack {
                        Text("99").opacity(0)
                        Text(String(num))
                    }
                    .font(.title.monospacedDigit())
                    .padding(10)
                    .background(
                        Circle()
                            .foregroundColor(.blue)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
