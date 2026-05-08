import SwiftUI

struct EventCardView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    var event: DayEvent

    private func getFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch event.fontStyle {
        case "Serif":       return .system(size: size, weight: weight, design: .serif)
        case "Rounded":     return .system(size: size, weight: weight, design: .rounded)
        case "Retro":       return .custom("Courier", size: size).weight(weight)
        case "Typewriter":  return .custom("AmericanTypewriter", size: size).weight(weight)
        default:            return .system(size: size, weight: weight)
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let now = context.date
            let diff = event.targetDate.timeIntervalSince(now)
            let isCompleted = diff < 0
            let displayColor: Color = isCompleted ? .black : event.themeColor

            let totalSeconds = Int(abs(diff))
            let days    = totalSeconds / 86400
            let hours   = (totalSeconds % 86400) / 3600
            let minutes = (totalSeconds % 3600) / 60

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(displayColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : event.iconName)
                        .font(.title2)
                        .foregroundColor(displayColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(getFont(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(event.targetDate, format: .dateTime.day().month().year().hour().minute())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if days > 0 {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(days)")
                                .font(getFont(size: 30, weight: .black))
                                .foregroundColor(displayColor)
                            Text("d")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(displayColor.opacity(0.7))
                        }
                        Text(String(format: "%02d:%02d", hours, minutes))
                            .font(getFont(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    } else {
                        Text(String(format: "%02d:%02d", hours, minutes))
                            .font(getFont(size: 28, weight: .black))
                            .foregroundColor(displayColor)
                    }
                    Text(isCompleted ? "AGO" : "LEFT")
                        .font(.system(size: 9, weight: .black))
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
}
