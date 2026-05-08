import WidgetKit
import SwiftUI
import SwiftData

struct WidgetEventData {
    let title: String
    let targetDate: Date
    let themeColorHex: String
    let iconName: String
    let tasks: [String]
}

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> DayEventEntry {
        DayEventEntry(date: Date(), event: WidgetEventData(title: "Sample Event", targetDate: Date().addingTimeInterval(86400*5), themeColorHex: "#818CF8", iconName: "star.fill", tasks: ["Buy tickets", "Pack bags", "Book hotel"]))
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
    private func fetchNextEvent() -> WidgetEventData? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dayzero.shared")?.appendingPathComponent("DayZero.sqlite") else { 
            return nil
        }
        do {
            let schema = Schema([DayEvent.self, EventTask.self])
            let container = try ModelContainer(for: schema, configurations: ModelConfiguration(url: url))
            let descriptor = FetchDescriptor<DayEvent>(sortBy: [SortDescriptor(\.targetDate)])
            let events = try container.mainContext.fetch(descriptor)
            
            if events.isEmpty {
                return nil
            }
            
            // Gelecekteki ilk etkinliği bul (yaklaşan), yoksa en sonuncuyu göster
            let event = events.first(where: { $0.targetDate >= Date() }) ?? events.first!
            
            // Taskleri al (sadece tamamlanmamış olanları)
            let pendingTasks = (event.tasks ?? [])
                .filter { !$0.isCompleted }
                .sorted { $0.createdAt < $1.createdAt }
                .prefix(3)
                .map { $0.title }
                
            return WidgetEventData(
                title: event.title,
                targetDate: event.targetDate,
                themeColorHex: event.themeColorHex,
                iconName: event.iconName,
                tasks: Array(pendingTasks)
            )
        } catch {
            print("Widget DB Error: \(error)")
            return nil
        }
    }
}

struct DayEventEntry: TimelineEntry {
    let date: Date
    let event: WidgetEventData?
}

struct DayZeroWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.event {
            let daysRemaining = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: event.targetDate)).day ?? 0
            
            ZStack {
                Color(hex: event.themeColorHex) ?? Color.blue
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Image(systemName: event.iconName)
                            .font(.title3)
                            .padding(.top, 4)
                        Spacer()
                        VStack(alignment: .trailing, spacing: -2) {
                            Text("\(abs(daysRemaining))")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            Text(daysRemaining >= 0 ? "DAYS LEFT" : "DAYS AGO")
                                .font(.system(size: 9, weight: .bold))
                                .opacity(0.8)
                        }
                    }
                    
                    Text(event.title)
                        .font(.system(size: 15, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        
                    if family == .systemMedium || family == .systemLarge {
                        if !event.tasks.isEmpty {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(event.tasks, id: \.self) { task in
                                    HStack(alignment: .top, spacing: 6) {
                                        Circle()
                                            .fill(.white.opacity(0.6))
                                            .frame(width: 4, height: 4)
                                            .padding(.top, 4)
                                        Text(task)
                                            .font(.system(size: 11, weight: .medium))
                                            .lineLimit(1)
                                            .opacity(0.9)
                                    }
                                }
                            }
                            .padding(.top, 4)
                            Spacer(minLength: 0)
                        } else {
                            Spacer()
                            Text("No pending tasks")
                                .font(.caption2)
                                .opacity(0.6)
                        }
                    } else {
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .padding(14)
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
