import SwiftUI

struct EventCardView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    var event: DayEvent
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: event.targetDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }
    
    var isCompleted: Bool {
        event.targetDate < Date()
    }
    
    var displayColor: Color {
        isCompleted ? .black : event.themeColor
    }
    
    private func getFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if event.fontName == "System" {
            return .system(size: size, weight: weight, design: .rounded)
        } else {
            return .custom(event.fontName, size: size)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(displayColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : event.iconName)
                    .font(.title2)
                    .foregroundColor(displayColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(getFont(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(event.targetDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(abs(daysRemaining))")
                    .font(getFont(size: 28, weight: .black))
                    .foregroundColor(displayColor)
                
                Text(daysRemaining >= 0 ? "DAYS LEFT" : "DAYS AGO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .continuousCorner(radius: 24)
        .antigravityShadow(color: displayColor)
        .padding(.vertical, 4)
    }
}
