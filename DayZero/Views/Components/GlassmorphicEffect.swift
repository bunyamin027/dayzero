import SwiftUI

struct GlassmorphicEffect: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassmorphic(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(GlassmorphicEffect(cornerRadius: cornerRadius))
    }
}
