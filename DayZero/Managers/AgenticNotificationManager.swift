import Foundation
import UserNotifications

final class AgenticNotificationManager {
    static let shared = AgenticNotificationManager()
    
    func scheduleMorningBriefings(events: [DayEvent]) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            let calendar = Calendar.current
            let now = Date()
            
            for dayOffset in 0..<7 {
                guard let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: now),
                      let triggerDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: targetDay),
                      triggerDate > now else { continue }
                
                let happeningToday = events.filter { calendar.isDate($0.targetDate, inSameDayAs: targetDay) }
                let imminentEvents = events.filter { 
                    let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: targetDay), to: calendar.startOfDay(for: $0.targetDate)).day ?? -1
                    return diff > 0 && diff <= 7
                }.sorted(by: { $0.targetDate < $1.targetDate })
                
                let pendingTasksCount = events.reduce(0) { $0 + ($1.tasks?.filter { !$0.isCompleted }.count ?? 0) }
                
                if happeningToday.isEmpty && imminentEvents.isEmpty && pendingTasksCount == 0 {
                    continue
                }
                
                let content = UNMutableNotificationContent()
                content.title = "Günaydın ✨"
                
                var bodyParts: [String] = []
                
                if let today = happeningToday.first {
                    bodyParts.append("Bugün \(today.title) günü!")
                } else if let imminent = imminentEvents.first {
                    let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: targetDay), to: calendar.startOfDay(for: imminent.targetDate)).day ?? 0
                    bodyParts.append("\(imminent.title) etkinliğine \(diff) gün kaldı")
                }
                
                if pendingTasksCount > 0 {
                    bodyParts.append("bekleyen \(pendingTasksCount) görevin var")
                }
                
                let summary = bodyParts.joined(separator: " ve ")
                content.body = "Bugün için planlananları senin için özetledim: \(summary)."
                
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "morning_briefing_\(dayOffset)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
