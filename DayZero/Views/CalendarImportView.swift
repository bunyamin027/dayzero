import SwiftUI
import EventKit
import SwiftData

struct CalendarImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var calendarManager = CalendarManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if calendarManager.authorizationStatus == .authorized || calendarManager.authorizationStatus == .fullAccess {
                    if calendarManager.upcomingEvents.isEmpty {
                        ContentUnavailableView("No Events Found", systemImage: "calendar.badge.exclamationmark", description: Text("You don't have any upcoming events in your calendars."))
                    } else {
                        List {
                            ForEach(calendarManager.upcomingEvents, id: \.eventIdentifier) { event in
                                Button {
                                    importEvent(event)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(event.startDate, style: .date)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.accentColor)
                                            .font(.title3)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Calendar Access Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("To import events automatically, please grant DayZero access to your calendars.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Grant Access") {
                            Task {
                                let granted = await calendarManager.requestAccess()
                                if granted {
                                    calendarManager.fetchUpcomingEvents()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Import from Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if calendarManager.authorizationStatus == .authorized || calendarManager.authorizationStatus == .fullAccess {
                    calendarManager.fetchUpcomingEvents()
                }
            }
        }
    }
    
    private func importEvent(_ ekEvent: EKEvent) {
        // Find a random beautiful theme
        let randomTheme = Theme.modernPastels.randomElement() ?? Theme.modernPastels[0]
        
        let newEvent = DayEvent(
            title: ekEvent.title,
            targetDate: ekEvent.startDate,
            themeColorHex: randomTheme,
            iconName: "calendar",
            isPremium: true
        )
        modelContext.insert(newEvent)
        try? modelContext.save()
        dismiss()
    }
}
