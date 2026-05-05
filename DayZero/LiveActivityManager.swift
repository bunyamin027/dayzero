import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    func startLiveActivity(for event: DayEvent) {
        // Ensure Live Activities are supported and enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        // Stop existing activities first (only allow one at a time for simplicity)
        stopAllActivities()
        
        let daysRemaining = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: event.targetDate)).day ?? 0
        
        let attributes = DayZeroAttributes(
            eventTitle: event.title,
            eventIcon: event.iconName,
            themeColorHex: event.themeColorHex
        )
        
        let contentState = DayZeroAttributes.ContentState(daysRemaining: abs(daysRemaining))
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("Live Activity started successfully")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func stopAllActivities() {
        for activity in Activity<DayZeroAttributes>.activities {
            Task {
                let state = activity.content.state
                let content = ActivityContent(state: state, staleDate: nil)
                await activity.end(content, dismissalPolicy: .immediate)
            }
        }
    }
}
