import SwiftUI
import EventKit
import SwiftData

struct SmartImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @StateObject private var manager = CalendarImportManager.shared
    
    @State private var isScanning = false
    @State private var showResults = false
    @State private var addAllEvents: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("SMART IMPORT")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                        .foregroundColor(.secondary)
                    
                    Text("Sync your life for the year.")
                        .font(.title2.bold())
                }
                .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Keyword Filter Card
                        ConfigCard(title: "KEYWORD FILTER", icon: "magnifyingglass") {
                            TextField("e.g. Flight, Exam, Deadline", text: $manager.filterKeyword)
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.5))
                                .continuousCorner(radius: 12)
                        }
                        
                        // 2. Cleanup Section
                        ConfigCard(title: "CLEANUP", icon: "sparkles") {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Exclude Public Holidays")
                                        .font(.headline)
                                    Spacer()
                                    PremiumToggle(isOn: $manager.excludeHolidays)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Add All Found Events")
                                        .font(.headline)
                                    Spacer()
                                    PremiumToggle(isOn: $addAllEvents)
                                }
                            }
                        }
                        
                        // 3. Calendar Selection (Vertical)
                        ConfigCard(title: "SELECT CALENDARS", icon: "calendar") {
                            VStack(spacing: 12) {
                                ForEach(manager.availableCalendars, id: \.calendarIdentifier) { cal in
                                    let isSelected = manager.selectedCalendarIDs.contains(cal.calendarIdentifier)
                                    Button {
                                        if isSelected {
                                            manager.selectedCalendarIDs.remove(cal.calendarIdentifier)
                                        } else {
                                            manager.selectedCalendarIDs.insert(cal.calendarIdentifier)
                                        }
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(Color(cgColor: cal.cgColor))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(cal.title)
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(isSelected ? .blue : .secondary)
                                                .font(.title3)
                                        }
                                        .padding()
                                        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                        .continuousCorner(radius: 12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // 4. Results Section (Conditional)
                        if showResults && !addAllEvents {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("FOUND EVENTS (\(manager.filteredEvents.count))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(manager.filteredEvents, id: \.eventIdentifier) { event in
                                            ImportEventCard(event: event) {
                                                importToDayZero(event)
                                            }
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Magic Import Button
                Button {
                    startMagicImport()
                } label: {
                    ZStack {
                        if isScanning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text(addAllEvents ? "IMPORT ALL & GO" : "MAGIC IMPORT")
                            }
                            .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .continuousCorner(radius: 20)
                    .antigravityShadow(color: .blue)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .tactile()
            }
            
            // PREMIUM PAYWALL GUARD
            if !storeKitManager.isPro {
                PaywallLockScreen()
            }
        }
        .onAppear {
            Task {
                await manager.requestAccess()
            }
        }
    }
    
    private func startMagicImport() {
        isScanning = true
        withAnimation(.spring()) { showResults = false }
        
        // Simulate scanning animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            Task {
                await manager.fetchSmartEvents()
                isScanning = false
                
                if addAllEvents {
                    // Import everything and dismiss
                    for event in manager.filteredEvents {
                        importToDayZero(event)
                    }
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showResults = true
                    }
                }
            }
        }
    }
    
    private func importToDayZero(_ ekEvent: EKEvent) {
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
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Reuse Components from Previous Step
struct ConfigCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.secondary)
            
            content
        }
        .padding()
        .background(.white)
        .continuousCorner(radius: 20)
        .antigravityShadow(radius: 10, y: 5)
    }
}

struct PremiumToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
            }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 28)
                
                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .padding(2)
                    .shadow(radius: 2)
            }
        }
    }
}

struct ImportEventCard: View {
    let event: EKEvent
    let onImport: () -> Void
    @State private var isImported = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(event.startDate, style: .date)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                withAnimation {
                    isImported = true
                    onImport()
                }
            } label: {
                Text(isImported ? "ADDED" : "IMPORT")
                    .font(.system(size: 10, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isImported ? Color.green : Color.primary)
                    .foregroundColor(.white)
                    .continuousCorner(radius: 8)
            }
            .disabled(isImported)
        }
        .padding()
        .frame(width: 140, height: 160)
        .background(Color.white)
        .continuousCorner(radius: 20)
        .antigravityShadow(radius: 5, y: 3)
    }
}

struct PaywallLockScreen: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .antigravityShadow()
                    
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("PRO FEATURE")
                        .font(.system(size: 12, weight: .black))
                        .tracking(2)
                        .foregroundColor(.blue)
                    
                    Text("Smart Calendar Import")
                        .font(.title2.bold())
                    
                    Text("Automatically turn your calendar into\naesthetic countdowns.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                } label: {
                    Text("Upgrade to Pro")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .continuousCorner(radius: 20)
                        .antigravityShadow(color: .blue)
                }
            }
            .padding(40)
            .background(.white.opacity(0.8))
            .continuousCorner(radius: 40)
            .padding()
        }
    }
}
