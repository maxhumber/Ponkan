import SwiftUI

public struct FlowStack<Content: View>: View {
    //  Inspired by: https://gist.github.com/vanwagonet/8fb54066b29a9c700e446dde62a9eb73
    let content: () -> Content
    let spacing: CGSize
    
    public init(spacing: CGSize = .zero, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.spacing = spacing
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            var available: CGFloat = 0
            var x: CGFloat = 0
            var y: CGFloat = 0
            Color.clear
                .frame(height: 0)
                .alignmentGuide(.top) { item in
                    available = item.width
                    x = 0
                    y = 0
                    return 0
                }
            content()
                .alignmentGuide(.leading) { item in
                    if x + item.width > available {
                        x = 0
                        y += item.height + spacing.height
                    }
                    let result = x
                    x += item.width + spacing.width
                    return -result
                }
                .alignmentGuide(.top) { _ in
                    -y
                }
        }
    }
}

struct FlowStack_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FlowStack {
                ForEach(1..<100) { num in
                    Text(String(num))
                        .frame(minWidth: 30, minHeight: 30)
                        .background(Circle().fill(Color.red))
                }
            }
            .padding(.horizontal)
        }
    }
}
