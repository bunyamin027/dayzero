import SwiftUI
import SwiftData
import StoreKit

@main
struct DayZeroApp: App {
    @StateObject private var storeKitManager = StoreKitManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DayEvent.self,
            EventTask.self
        ])
        
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dayzero.shared")?.appendingPathComponent("DayZero.sqlite") else {
            fatalError("App Group container not found. Please enable App Groups in Xcode.")
        }
        
        let modelConfiguration = ModelConfiguration(url: url)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Migration failed. Clearing store. Error: \(error)")
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-shm"))
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("sqlite-wal"))
            return try! ModelContainer(for: schema, configurations: [modelConfiguration])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKitManager)
                .task {
                    // Ensure products are loaded and entitlements checked on launch
                    await storeKitManager.fetchProducts()
                    await storeKitManager.updateCustomerProductStatus()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
