import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> DayEventEntry {
        DayEventEntry(date: Date(), event: fetchNextEvent())
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (DayEventEntry) -> ()) {
        let entry = DayEventEntry(date: Date(), event: fetchNextEvent())
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let event = fetchNextEvent()
        let entry = DayEventEntry(date: Date(), event: event)

        // Update at midnight
        let calendar = Calendar.current
        let nextMidnight = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
    
    @MainActor
    private func fetchNextEvent() -> DayEvent? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dayzero.shared")?.appendingPathComponent("DayZero.sqlite") else { 
            return DayEvent(title: "Err: No App Group", targetDate: Date(), themeColorHex: "#FF0000", iconName: "exclamationmark.triangle", isPremium: false) 
        }
        do {
            let container = try ModelContainer(for: DayEvent.self, configurations: ModelConfiguration(url: url))
            let descriptor = FetchDescriptor<DayEvent>(sortBy: [SortDescriptor(\.targetDate)])
            let events = try container.mainContext.fetch(descriptor)
            
            if events.isEmpty {
                return DayEvent(title: "Empty DB", targetDate: Date(), themeColorHex: "#FFA500", iconName: "tray", isPremium: false)
            }
            
            // Gelecekteki ilk etkinliği bul (yaklaşan), yoksa en sonuncuyu göster
            return events.first(where: { $0.targetDate >= Date() }) ?? events.first
        } catch {
            return DayEvent(title: "Err: \(error.localizedDescription.prefix(15))", targetDate: Date(), themeColorHex: "#FF0000", iconName: "exclamationmark.triangle", isPremium: false)
        }
    }
}

struct DayEventEntry: TimelineEntry {
    let date: Date
    let event: DayEvent?
}

struct DayZeroWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.event {
            let daysRemaining = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: event.targetDate)).day ?? 0
            
            ZStack {
                Color(hex: event.themeColorHex) ?? Color.blue
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: event.iconName)
                            .font(.title3)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text("\(abs(daysRemaining))")
                        .font(.system(size: family == .systemSmall ? 40 : 50, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.5)
                    
                    Text(daysRemaining >= 0 ? "DAYS LEFT" : "DAYS AGO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .opacity(0.8)
                    
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(.white)
                .padding()
            }
        } else {
            VStack {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
                Text("Add an event")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
    }
}

struct DayZeroWidget: Widget {
    let kind: String = "DayZeroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DayZeroWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DayZeroWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("DayZero Countdown")
        .description("Track your most important events on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DayZeroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DayZeroAttributes.self) { context in
            // Lock screen / Banner UI
            ZStack {
                Color(hex: context.attributes.themeColorHex) ?? Color.blue
                
                HStack {
                    Image(systemName: context.attributes.eventIcon)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading) {
                        Text(context.attributes.eventTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if context.attributes.targetDate > Date() {
                            Text(timerInterval: Date()...context.attributes.targetDate, countsDown: true)
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text("Event Passed")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: context.attributes.targetDate).day ?? 0
                    Text("\(max(0, daysLeft))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
            }
            .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.eventIcon)
                        .foregroundColor(Color(hex: context.attributes.themeColorHex) ?? .blue)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.daysRemaining)d")
                        .font(.headline)
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.eventTitle)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.attributes.targetDate > Date() {
                        Text(timerInterval: Date()...context.attributes.targetDate, countsDown: true)
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    } else {
                        Text("Event Passed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.eventIcon)
                    .foregroundColor(Color(hex: context.attributes.themeColorHex) ?? .blue)
            } compactTrailing: {
                Text("\(context.state.daysRemaining)d")
                    .font(.caption2)
            } minimal: {
                Text("\(context.state.daysRemaining)")
                    .font(.caption2)
            }
        }
    }
}

@main
struct DayZeroWidgetBundle: WidgetBundle {
    var body: some Widget {
        DayZeroWidget()
        if #available(iOS 16.1, *) {
            DayZeroLiveActivity()
        }
    }
}
