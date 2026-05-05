import SwiftUI
import SwiftData
import StoreKit

@main
struct DayZeroApp: App {
    @StateObject private var storeKitManager = StoreKitManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DayEvent.self,
        ])
        
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dayzero.shared")?.appendingPathComponent("DayZero.sqlite") else {
            fatalError("App Group container not found. Please enable App Groups in Xcode.")
        }
        
        let modelConfiguration = ModelConfiguration(url: url)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKitManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
