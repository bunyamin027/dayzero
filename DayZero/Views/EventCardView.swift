import SwiftUI

struct EventCardView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    var event: DayEvent
    var isHero: Bool = false

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

            HStack(spacing: isHero ? 20 : 16) {
                ZStack {
                    Circle()
                        .fill(displayColor.opacity(0.15))
                        .frame(width: isHero ? 64 : 52, height: isHero ? 64 : 52)
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : event.iconName)
                        .font(isHero ? .title : .title2)
                        .foregroundColor(displayColor)
                }

                VStack(alignment: .leading, spacing: isHero ? 6 : 4) {
                    Text(event.title)
                        .font(getFont(size: isHero ? 20 : 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(event.targetDate, format: .dateTime.day().month().year().hour().minute())
                        .font(isHero ? .subheadline.weight(.medium) : .subheadline)
                        .foregroundColor(isHero ? displayColor.opacity(0.8) : .secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if days > 0 {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(days)")
                                .font(getFont(size: isHero ? 36 : 30, weight: .black))
                                .foregroundColor(displayColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                            Text("d")
                                .font(.system(size: isHero ? 14 : 11, weight: .bold))
                                .foregroundColor(displayColor.opacity(0.7))
                        }
                        Text(String(format: "%02d:%02d", hours, minutes))
                            .font(getFont(size: isHero ? 15 : 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    } else {
                        Text(String(format: "%02d:%02d", hours, minutes))
                            .font(getFont(size: isHero ? 34 : 28, weight: .black))
                            .foregroundColor(displayColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    Text(isCompleted ? "AGO" : "LEFT")
                        .font(.system(size: isHero ? 11 : 9, weight: .black))
                        .foregroundColor(.secondary)
                }
            }
            .padding(isHero ? 20 : 16)
            .background(.ultraThinMaterial)
            .continuousCorner(radius: isHero ? 32 : 24)
            .antigravityShadow(color: displayColor)
            .padding(.vertical, isHero ? 8 : 4)
            .overlay(
                Group {
                    if isHero {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [displayColor.opacity(0.6), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                }
            )
        }
    }
}
