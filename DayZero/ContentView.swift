import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DayEvent.targetDate) private var events: [DayEvent]
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    @State private var showingAddSheet = false
    @State private var showingPaywall = false
    @State private var showingSmartImport = false
    @State private var selectedEvent: DayEvent? = nil
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                MeshGradientBackground()
                
                if events.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(events) { event in
                                let isToday = Calendar.current.isDateInToday(event.targetDate)
                                EventCardView(event: event, isHero: isToday)
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                    .contextMenu {
                                        if #available(iOS 16.1, *) {
                                            Button {
                                                LiveActivityManager.shared.startLiveActivity(for: event)
                                            } label: {
                                                Label("Pin to Lock Screen", systemImage: "pin")
                                            }
                                        }
                                        
                                        Button(role: .destructive) {
                                            deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("DayZero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSmartImport = true
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }

                        Button {
                            if events.count >= 3 && !storeKitManager.isPro {
                                showingPaywall = true
                            } else {
                                showingAddSheet = true
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showingAddSheet) {
                AddEventSheet()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(item: $selectedEvent) { event in
                AddEventSheet(eventToEdit: event)
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSmartImport) {
                SmartImportSheet()
            }
        }
        .onReceive(timer) { _ in
            deleteExpiredEvents()
        }
        .onAppear {
            deleteExpiredEvents()
        }
    }

    private func deleteExpiredEvents() {
        let now = Date()
        var didDelete = false
        for event in events {
            if event.targetDate <= now {
                modelContext.delete(event)
                didDelete = true
            }
        }
        if didDelete {
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            Text("No countdowns yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start tracking the moments that matter.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddSheet = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .continuousCorner(radius: 16)
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
    }
    
    private func deleteEvent(_ event: DayEvent) {
        withAnimation {
            modelContext.delete(event)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
