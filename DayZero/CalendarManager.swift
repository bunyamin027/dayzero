import Foundation
import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    let eventStore = EKEventStore()
    
    @Published var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    @Published var upcomingEvents: [EKEvent] = []
    
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            } else {
                let granted = try await eventStore.requestAccess(to: .event)
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            }
        } catch {
            print("Failed to request calendar access: \(error)")
            return false
        }
    }
    
    func fetchUpcomingEvents() {
        guard authorizationStatus == .authorized || authorizationStatus == .fullAccess else { return }
        
        let calendars = eventStore.calendars(for: .event)
        let now = Date()
        
        // Fetch events for the next 1 year
        guard let endDate = Calendar.current.date(byAdding: .year, value: 1, to: now) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        // Filter out all-day events or keep them depending on preference, and sort
        self.upcomingEvents = events.sorted { $0.startDate < $1.startDate }
    }
}
