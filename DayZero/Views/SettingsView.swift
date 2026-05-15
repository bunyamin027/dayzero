import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var showManageSubscriptions = false

    // Dynamic version from Bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Using the same theme as the rest of the app
                MeshGradientBackground()
                
                List {
                    // MARK: - Subscription Status
                    Section {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(storeKitManager.isPro ? 
                                          LinearGradient(colors: [Color(hex: "#4F46E5")!, Color(hex: "#7C3AED")!], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                          LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: storeKitManager.isPro ? "crown.fill" : "person.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(storeKitManager.isPro ? "DayZero Pro Active" : "DayZero Free")
                                    .font(.headline)
                                
                                Text(storeKitManager.isPro ? "All premium features unlocked" : "Limit: 3 countdowns & basic themes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if !storeKitManager.isPro {
                            Button {
                                // This will trigger the paywall if called from ContentView, 
                                // but here we can just show a link or dismiss and show paywall.
                                dismiss()
                                NotificationCenter.default.post(name: NSNotification.Name("ShowPaywall"), object: nil)
                            } label: {
                                Text("Upgrade to Pro")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#4F46E5"))
                            }
                        }
                    } header: {
                        Text("Account Status")
                    }
                    
                    // MARK: - Support & Feedback
                    Section {
                        Button {
                            if let url = URL(string: "mailto:bunyamin027@icloud.com?subject=DayZero%20Support") {
                                openURL(url)
                            }
                        } label: {
                            Label("Contact Support", systemImage: "envelope.fill")
                        }
                        
                        Button {
                            if let url = URL(string: "https://bunyamin027.github.io/Legal/#contact") {
                                openURL(url)
                            }
                        } label: {
                            Label("Visit Website", systemImage: "safari.fill")
                        }
                    } header: {
                        Text("Support")
                    }
                    
                    // MARK: - Purchases
                    Section {
                        Button {
                            Task {
                                isRestoring = true
                                await storeKitManager.restorePurchases()
                                isRestoring = false
                                restoreMessage = storeKitManager.isPro ? "Purchases successfully restored!" : "No active subscriptions found."
                                showRestoreAlert = true
                            }
                        } label: {
                            if isRestoring {
                                ProgressView()
                            } else {
                                Label("Restore Purchases", systemImage: "arrow.clockwise")
                            }
                        }
                        .disabled(isRestoring)
                        
                        Button {
                            showManageSubscriptions = true
                        } label: {
                            Label("Manage Subscriptions", systemImage: "creditcard.fill")
                        }
                    } header: {
                        Text("Purchases")
                    }
                    
                    // MARK: - Subscription Terms (Apple Guideline 3.1.2 Compliance)
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DayZero Pro is available as an auto-renewable subscription with two plan options:")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            subscriptionTermRow(
                                title: "Monthly Plan",
                                detail: storeKitManager.products.first(where: { $0.id == "com.dayzero.pro.monthly" })?.displayPrice ?? "$4.99",
                                period: "per month"
                            )
                            
                            subscriptionTermRow(
                                title: "Annual Plan",
                                detail: storeKitManager.products.first(where: { $0.id == "com.dayzero.pro.annual" })?.displayPrice ?? "$29.99",
                                period: "per year"
                            )
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 6) {
                                termBullet("New subscribers are eligible for a 14-day free trial.")
                                termBullet("Payment will be charged to your Apple ID account at the confirmation of purchase, or at the end of the free trial period.")
                                termBullet("Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                                termBullet("Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                                termBullet("You can manage and cancel your subscriptions in your device's Settings > Apple ID > Subscriptions.")
                                termBullet("Any unused portion of a free trial period will be forfeited when you purchase a subscription.")
                            }
                        }
                        .padding(.vertical, 6)
                    } header: {
                        Text("Subscription Terms")
                    }
                    
                    // MARK: - Legal
                    Section {
                        Button {
                            if let url = URL(string: "https://bunyamin027.github.io/Legal/#privacy") {
                                openURL(url)
                            }
                        } label: {
                            Label("Privacy Policy", systemImage: "shield.lefthalf.filled")
                        }
                        
                        Button {
                            if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                openURL(url)
                            }
                        } label: {
                            Label("Terms of Use (EULA)", systemImage: "doc.text.fill")
                        }
                        
                        Button {
                            if let url = URL(string: "https://bunyamin027.github.io/Legal/#terms") {
                                openURL(url)
                            }
                        } label: {
                            Label("Subscription Terms (Web)", systemImage: "doc.plaintext.fill")
                        }
                    } header: {
                        Text("Legal")
                    }
                    
                    // MARK: - App Info
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("© 2026 Bunyamin Apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Restore", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        }
    }
    
    // MARK: - Subscription Term Helpers
    
    private func subscriptionTermRow(title: String, detail: String, period: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Auto-renews. Cancel anytime.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(detail) / \(period)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#4F46E5"))
        }
        .padding(.vertical, 2)
    }
    
    private func termBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(StoreKitManager.shared)
}
