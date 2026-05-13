import WidgetKit
import SwiftUI
import SwiftData
import ActivityKit

// MARK: - Models
struct WidgetEventData {
    let title: String
    let targetDate: Date
    let themeColorHex: String
    let iconName: String
    let tasks: [String]
}

struct DayEventEntry: TimelineEntry {
    let date: Date
    let currentEvent: WidgetEventData?
    let nextEvent: WidgetEventData?
}

// MARK: - Provider
struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> DayEventEntry {
        DayEventEntry(
            date: Date(),
            currentEvent: nil,
            nextEvent: WidgetEventData(title: "Flight to Tokyo", targetDate: Date().addingTimeInterval(86400*2), themeColorHex: "#818CF8", iconName: "airplane", tasks: ["Pack bags", "Passport"])
        )
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (DayEventEntry) -> ()) {
        let (current, next) = fetchWidgetData()
        let entry = DayEventEntry(date: Date(), currentEvent: current, nextEvent: next)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEventEntry>) -> ()) {
        let (current, next) = fetchWidgetData()
        let entry = DayEventEntry(date: Date(), currentEvent: current, nextEvent: next)
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)))
        completion(timeline)
    }
    
    @MainActor
    private func fetchWidgetData() -> (current: WidgetEventData?, next: WidgetEventData?) {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dayzero.shared")?.appendingPathComponent("DayZero.sqlite") else { return (nil, nil) }
        do {
            let schema = Schema([DayEvent.self, EventTask.self])
            let container = try ModelContainer(for: schema, configurations: ModelConfiguration(url: url))
            let descriptor = FetchDescriptor<DayEvent>(sortBy: [SortDescriptor(\.targetDate)])
            let events = try container.mainContext.fetch(descriptor)
            let now = Date()
            let calendar = Calendar.current
            let current = events.first { calendar.isDate($0.targetDate, inSameDayAs: now) }
            let next = events.first { calendar.startOfDay(for: $0.targetDate) > calendar.startOfDay(for: now) }
            func summarize(_ event: DayEvent?) -> WidgetEventData? {
                guard let event = event else { return nil }
                let pendingTasks = (event.tasks ?? []).filter { !$0.isCompleted }.sorted { $0.createdAt < $1.createdAt }.prefix(4).map { $0.title }
                return WidgetEventData(title: event.title, targetDate: event.targetDate, themeColorHex: event.themeColorHex, iconName: event.iconName, tasks: Array(pendingTasks))
            }
            return (summarize(current), summarize(next))
        } catch { return (nil, nil) }
    }
}

// MARK: - UI Components
struct DayZeroWidgetEntryView : View {
    var entry: DayEventEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            if let current = entry.currentEvent {
                ActiveTodayView(event: current, family: family)
            } else {
                DashboardFallbackView(nextEvent: entry.nextEvent, family: family)
            }
        }
    }
}

struct ActiveTodayView: View {
    let event: WidgetEventData
    let family: WidgetFamily
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Column
            VStack(alignment: .leading, spacing: 1) {
                // More prominent Date
                Text(Date().formatted(.dateTime.day().month()))
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                
                Text(event.title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.white.opacity(0.7))
                
                Spacer()
                
                // Countdown - Main Focus
                VStack(alignment: .leading, spacing: 0) {
                    Text("KALAN ZAMAN")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    if event.targetDate > Date() {
                        Text(event.targetDate, style: .timer)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.5)
                    } else {
                        Text("BUGÜN")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if family == .systemMedium {
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 0.5)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("MILESTONES")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        if !event.tasks.isEmpty {
                            ForEach(event.tasks.prefix(3), id: \.self) { task in
                                HStack(alignment: .top, spacing: 4) {
                                    Circle().fill(.white).frame(width: 3, height: 3).padding(.top, 4)
                                    Text(task).font(.system(size: 9, weight: .medium)).lineLimit(1)
                                }
                            }
                        } else {
                            Text("Görev yok").font(.system(size: 9)).opacity(0.4)
                        }
                    }
                    .foregroundStyle(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 12)
    }
}

struct DashboardFallbackView: View {
    let nextEvent: WidgetEventData?
    let family: WidgetFamily
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Date().formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(Date().formatted(.dateTime.day().month()))
                        .font(.system(size: 14, weight: .bold))
                }
                Spacer()
                Text("✨")
            }
            .foregroundStyle(.white)
            
            VStack(spacing: 2) {
                Text("Harika gidiyorsun!")
                    .font(.system(size: 12, weight: .bold))
                Text("Bugünlük bu kadar.").font(.system(size: 8)).opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
            
            if let next = nextEvent {
                let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: next.targetDate)).day ?? 0
                Spacer(minLength: 0)
                HStack {
                    Text(next.title).font(.system(size: 9, weight: .bold)).lineLimit(1)
                    Spacer()
                    Text("\(days) gün").font(.system(size: 9, weight: .black)).opacity(0.6)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.black.opacity(0.15))
                .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Widget Configurations
struct DayZeroWidget: Widget {
    let kind: String = "DayZeroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DayZeroWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    ZStack {
                        let baseColor = Color(hex: entry.currentEvent?.themeColorHex ?? "#4F46E5") ?? .indigo
                        baseColor.opacity(0.8)
                        LinearGradient(colors: [baseColor, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing).blendMode(.overlay)
                        Circle().fill(baseColor.opacity(0.5)).frame(width: 200).blur(radius: 50).offset(x: -50, y: -50)
                    }
                    .background(Color.black)
                }
        }
        .configurationDisplayName("DayZero")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DayZeroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DayZeroAttributes.self) { context in
            ZStack {
                Color(hex: context.attributes.themeColorHex) ?? Color.blue
                HStack {
                    Image(systemName: context.attributes.eventIcon).foregroundColor(.white)
                    VStack(alignment: .leading) {
                        Text(context.attributes.eventTitle).foregroundColor(.white)
                        Text(context.attributes.targetDate, style: .timer).foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: context.attributes.targetDate).day ?? 0
                    Text("\(max(0, daysLeft))").font(.title).foregroundColor(.white)
                }
                .padding()
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) { Text(context.attributes.eventTitle) }
            } compactLeading: {
                Image(systemName: context.attributes.eventIcon)
            } compactTrailing: {
                Text("\(context.state.daysRemaining)d")
            } minimal: {
                Text("\(context.state.daysRemaining)")
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
