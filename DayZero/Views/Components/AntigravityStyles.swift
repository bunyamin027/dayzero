import SwiftUI

struct AntigravityShadow: ViewModifier {
    var color: Color
    var radius: CGFloat = 20
    var y: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.15), radius: radius, x: 0, y: y)
            .shadow(color: color.opacity(0.1), radius: radius/2, x: 0, y: y/2)
    }
}

struct TactileInteraction: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func antigravityShadow(color: Color = .black, radius: CGFloat = 20, y: CGFloat = 10) -> some View {
        self.modifier(AntigravityShadow(color: color, radius: radius, y: y))
    }
    
    func tactile() -> some View {
        self.modifier(TactileInteraction())
    }
    
    func continuousCorner(radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
