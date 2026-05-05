import SwiftUI

@MainActor
class ShareHelper {
    static func renderEventCard(for event: DayEvent, title: String? = nil, targetDate: Date? = nil, themeColorHex: String? = nil, iconName: String? = nil) -> UIImage? {
        // Use provided values or fallback to event values
        let displayTitle = title ?? event.title
        let displayDate = targetDate ?? event.targetDate
        let displayHex = themeColorHex ?? event.themeColorHex
        let displayIcon = iconName ?? event.iconName
        
        // Create a temporary event for rendering purposes
        let tempEvent = DayEvent(title: displayTitle, targetDate: displayDate, themeColorHex: displayHex, iconName: displayIcon)
        
        let viewToRender = VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(tempEvent.themeColor)
            
            EventCardView(event: tempEvent)
                .frame(width: 350)
            
            Text("Created with DayZero")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(
            LinearGradient(
                colors: [tempEvent.themeColor.opacity(0.2), Color(uiColor: .systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .environmentObject(StoreKitManager.shared)
        
        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
