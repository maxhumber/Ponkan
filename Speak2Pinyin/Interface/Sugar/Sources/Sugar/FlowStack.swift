//  Inspired by: https://gist.github.com/vanwagonet/8fb54066b29a9c700e446dde62a9eb73

import SwiftUI

public struct FlowStack<Content: View>: View {
    private let viewModel: ViewModel
    private let content: () -> Content
    
    public init(spacing: CGSize = .zero, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = .init(spacing: spacing)
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .frame(height: 0)
                .alignmentGuide(.top) { viewModel.alignSpanner($0) }
            content()
                .alignmentGuide(.leading) { viewModel.alignLeading($0) }
                .alignmentGuide(.top) { viewModel.alignTop($0) }
        }
    }
    
    final class ViewModel {
        private var spacing: CGSize
        private var available: CGFloat
        private var x: CGFloat
        private var y: CGFloat
        
        init(spacing: CGSize, available: CGFloat = .zero, x: CGFloat = .zero, y: CGFloat = .zero) {
            self.spacing = spacing
            self.available = available
            self.x = x
            self.y = y
        }
        
        func alignSpanner(_ item: ViewDimensions) -> CGFloat {
            available = item.width
            x = 0
            y = 0
            return 0
        }
        
        func alignLeading(_ item: ViewDimensions) -> CGFloat {
            if x + item.width > available {
                x = 0
                y += item.height + spacing.height
            }
            let result = x
            x += item.width + spacing.width
            return -result
        }
        
        func alignTop(_ item: ViewDimensions) -> CGFloat {
            -y
        }
    }
}

struct FlowStack_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(showsIndicators: false) {
            FlowStack {
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
