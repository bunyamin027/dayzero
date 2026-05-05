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
    
    var hoursRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date(), to: event.targetDate)
        return components.hour ?? 0
    }
    
    var shouldShowTimer: Bool {
        if isCompleted { return false }
        if !storeKitManager.isPro { return false }
        if event.timerPreference == 2 { return true }
        if event.timerPreference == 1 { return false }
        return hoursRemaining < 24 && hoursRemaining >= 0
    }
    
    var isCompleted: Bool {
        event.targetDate < Date()
    }
    
    var displayColor: Color {
        isCompleted ? .black : event.themeColor
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
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(event.targetDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if isCompleted {
                    Text("DONE")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                } else if shouldShowTimer {
                    Text(event.targetDate, style: .timer)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(displayColor)
                        .multilineTextAlignment(.trailing)
                    Text("REMAINING")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(abs(daysRemaining))")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(displayColor)
                    
                    Text(daysRemaining >= 0 ? "DAYS LEFT" : "DAYS AGO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .glassmorphic()
    }
}
