import SwiftUI
import SwiftData
import WidgetKit

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    var eventToEdit: DayEvent?
    
    // State Management
    @State private var title: String
    @State private var targetDate: Date
    @State private var notes: String
    @State private var selectedThemeHex: String
    @State private var newTaskTitle = ""
    @State private var showingPaywall = false
    @State private var showingCalendarSync = false
    
    init(eventToEdit: DayEvent? = nil) {
        self.eventToEdit = eventToEdit
        _title = State(initialValue: eventToEdit?.title ?? "")
        _targetDate = State(initialValue: eventToEdit?.targetDate ?? Date().addingTimeInterval(86400))
        _notes = State(initialValue: eventToEdit?.notes ?? "")
        _selectedThemeHex = State(initialValue: eventToEdit?.themeColorHex ?? Theme.modernPastels[0])
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Antigravity Background
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // 1. TOP: Floating Live Preview
                        VStack {
                            let previewEvent = DayEvent(title: title.isEmpty ? "Event Preview" : title, targetDate: targetDate)
                            let _ = { previewEvent.themeColorHex = selectedThemeHex }()
                            EventCardView(event: previewEvent)
                                .scaleEffect(1.05)
                                .padding(.top, 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: title)
                        }
                        .padding(.horizontal)
                        
                        // 2. MIDDLE 1: Core Settings (Title & Date)
                        VStack(spacing: 16) {
                            TextField("What are we counting to?", text: $title)
                                .font(.title3.bold())
                                .padding()
                                .background(Color.white)
                                .continuousCorner(radius: 16)
                                .antigravityShadow(radius: 8, y: 4)
                            
                            DatePicker("Target Date", selection: $targetDate)
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .continuousCorner(radius: 16)
                        }
                        .padding(.horizontal)
                        
                        // 3. MIDDLE 2: Notes Editor
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NOTES").font(.system(size: 10, weight: .black)).foregroundColor(.secondary).padding(.horizontal)
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.white)
                                .continuousCorner(radius: 20)
                                .antigravityShadow(radius: 5, y: 2)
                                .overlay(
                                    Text(notes.isEmpty ? "Add some personal context..." : "")
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .padding(.leading, 18).padding(.top, 22),
                                    alignment: .topLeading
                                )
                        }
                        .padding(.horizontal)
                        
                        // 4. MIDDLE 3: Smart Calendar Sync (Premium)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INTEGRATION").font(.system(size: 10, weight: .black)).foregroundColor(.secondary).padding(.horizontal)
                            Button {
                                if storeKitManager.isPro { showingCalendarSync = true }
                                else { showingPaywall = true }
                            } label: {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Smart Calendar Sync")
                                    Spacer()
                                    if !storeKitManager.isPro { Image(systemName: "lock.fill").foregroundColor(.orange) }
                                    Image(systemName: "chevron.right").font(.caption)
                                }
                                .font(.headline)
                                .padding()
                                .background(.ultraThinMaterial)
                                .continuousCorner(radius: 16)
                                .antigravityShadow(radius: 5)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 5. BOTTOM: Milestones Section (Premium)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("MILESTONES").font(.system(size: 10, weight: .black)).foregroundColor(.secondary)
                                Spacer()
                                if !storeKitManager.isPro { Image(systemName: "lock.fill").foregroundColor(.orange) }
                            }
                            .padding(.horizontal)
                            
                            ZStack {
                                VStack(spacing: 12) {
                                    // New Task Input
                                    HStack {
                                        TextField("Add milestone...", text: $newTaskTitle)
                                            .textFieldStyle(.plain)
                                        Button { addMilestone() } label: {
                                            Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.accentColor)
                                        }
                                        .disabled(newTaskTitle.isEmpty)
                                    }
                                    .padding().background(Color.white).continuousCorner(radius: 16).antigravityShadow(radius: 5)
                                    
                                    // Tasks List
                                    if let event = eventToEdit {
                                        let sortedTasks = (event.tasks ?? []).sorted { $0.createdAt < $1.createdAt }
                                        ForEach(sortedTasks) { task in
                                            MilestonePill(task: task)
                                        }
                                    }
                                }
                                
                                if !storeKitManager.isPro {
                                    Rectangle()
                                        .fill(.ultraThinMaterial.opacity(0.8))
                                        .continuousCorner(radius: 24)
                                        .overlay(Button("Unlock Milestones with Pro") { showingPaywall = true }.font(.headline))
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { 
                    Button("Save") { saveEvent() }.fontWeight(.bold).disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .sheet(isPresented: $showingCalendarSync) { SmartImportSheet() }
        }
    }
    
    private func addMilestone() {
        guard storeKitManager.isPro else { showingPaywall = true; return }
        if let event = eventToEdit {
            let task = EventTask(title: newTaskTitle)
            task.event = event
            modelContext.insert(task)
            newTaskTitle = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func saveEvent() {
        if let event = eventToEdit {
            event.title = title; event.targetDate = targetDate; event.notes = notes; event.themeColorHex = selectedThemeHex
        } else {
            let newEvent = DayEvent(title: title, targetDate: targetDate, themeColorHex: selectedThemeHex)
            newEvent.notes = notes
            modelContext.insert(newEvent)
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

struct MilestonePill: View {
    @Bindable var task: EventTask
    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { task.isCompleted.toggle() }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .continuousCorner(radius: 16)
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .antigravityShadow(radius: task.isCompleted ? 2 : 5)
    }
}
