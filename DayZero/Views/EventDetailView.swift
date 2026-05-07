import SwiftUI
import SwiftData

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKitManager: StoreKitManager
    var event: DayEvent
    
    @State private var newTaskTitle = ""
    @State private var showingPaywall = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // TOP: Floating Live Preview (Antigravity)
                    VStack {
                        EventCardView(event: event)
                            .scaleEffect(1.05)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal)
                    
                    // MIDDLE: Standard Event Settings & Calendar Entry
                    VStack(spacing: 20) {
                        ConfigSummaryRow(icon: "tag.fill", title: "Title", value: event.title)
                        ConfigSummaryRow(icon: "calendar", title: "Target Date", value: event.targetDate.formatted(date: .long, time: .omitted))
                        
                        // Calendar Import Entry Point
                        Button {
                            // SmartImportSheet'i tetikleyen mantık
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Sync with Apple Calendar")
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.white)
                            .continuousCorner(radius: 16)
                            .antigravityShadow(radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // BOTTOM: Milestones / Tasks (Premium Section)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("MILESTONES")
                                .font(.system(size: 12, weight: .black)).tracking(2).foregroundColor(.secondary)
                            Spacer()
                            if !storeKitManager.isPro {
                                Image(systemName: "lock.fill").foregroundColor(.orange).font(.caption)
                            }
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            VStack(spacing: 12) {
                                // Inline Task Input
                                HStack {
                                    TextField("Add a milestone...", text: $newTaskTitle)
                                        .textFieldStyle(.plain)
                                    Button { addMilestone() } label: {
                                        Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(event.themeColor)
                                    }
                                    .disabled(newTaskTitle.isEmpty)
                                }
                                .padding()
                                .background(Color.white)
                                .continuousCorner(radius: 16)
                                .antigravityShadow(radius: 8, y: 4)
                                
                                // Floating Pill Task Rows
                                let sortedTasks = (event.tasks ?? []).sorted { $0.createdAt < $1.createdAt }
                                ForEach(sortedTasks) { task in
                                    MilestonePill(task: task)
                                }
                            }
                            
                            // Pro-Only Blur Overlay
                            if !storeKitManager.isPro {
                                Rectangle()
                                    .fill(.ultraThinMaterial.opacity(0.8))
                                    .continuousCorner(radius: 20)
                                    .overlay(
                                        Button("Unlock Milestones with Pro") { showingPaywall = true }
                                            .font(.headline).foregroundColor(.primary)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }.fontWeight(.bold)
            }
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
    
    private func addMilestone() {
        guard storeKitManager.isPro else { showingPaywall = true; return }
        let task = EventTask(title: newTaskTitle)
        task.event = event
        modelContext.insert(task)
        newTaskTitle = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct ConfigSummaryRow: View {
    let icon: String; let title: String; let value: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.secondary).frame(width: 24)
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.bold)
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .continuousCorner(radius: 12)
    }
}


