import Foundation
import EventKit
import SwiftUI

class CalendarImportManager: ObservableObject {
    static let shared = CalendarImportManager()
    private let eventStore = EKEventStore()
    
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIDs: Set<String> = []
    @Published var filteredEvents: [EKEvent] = []
    @Published var filterKeyword: String = ""
    @Published var excludeHolidays: Bool = true
    
    private init() {
        // Request access initially if possible, or wait for explicit call
    }
    
    func requestAccess() async {
        do {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestAccess(to: .event) { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
            
            if granted {
                await fetchCalendars()
            }
        } catch {
            print("Calendar access denied: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchCalendars() async {
        let calendars = eventStore.calendars(for: .event)
        self.availableCalendars = calendars.sorted { $0.title < $1.title }
        
        // Select all by default if none selected
        if selectedCalendarIDs.isEmpty {
            selectedCalendarIDs = Set(calendars.map { $0.calendarIdentifier })
        }
    }
    
    @MainActor
    func fetchSmartEvents() async {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let calendars = eventStore.calendars(for: .event).filter { selectedCalendarIDs.contains($0.calendarIdentifier) }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        var events = eventStore.events(matching: predicate)
        
        // Filtering
        if excludeHolidays {
            events = events.filter { $0.calendar.type != .birthday && $0.calendar.title != "Holidays" }
        }
        
        if !filterKeyword.isEmpty {
            let keyword = filterKeyword.lowercased()
            events = events.filter { $0.title.lowercased().contains(keyword) }
        }
        
        // Remove duplicates and very short/past events
        self.filteredEvents = events.sorted { $0.startDate < $1.startDate }
    }
}
