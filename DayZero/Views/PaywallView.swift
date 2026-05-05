import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    var body: some View {
        ZStack {
            // Premium dark background
            Color(hex: "#1A1A24")?.ignoresSafeArea()
            
            // Abstract subtle gradient
            RadialGradient(
                colors: [Color.blue.opacity(0.3), Color.clear],
                center: .topLeading,
                startRadius: 100,
                endRadius: 500
            ).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700")!, Color(hex: "#FFA500")!],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#FFD700")!.opacity(0.5), radius: 20, x: 0, y: 10)
                    .padding(.bottom, 10)
                
                Text("DayZero Pro")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Unlock unlimited events, exclusive themes, and premium icons.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "infinity", text: "Unlimited Events")
                    FeatureRow(icon: "calendar.badge.plus", text: "Sync Apple/Google Calendar")
                    FeatureRow(icon: "timer", text: "High-Precision Live Timers")
                    FeatureRow(icon: "paintpalette.fill", text: "Premium Themes & Icons")
                    FeatureRow(icon: "faceid", text: "Face ID App Lock")
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                if let product = storeKitManager.products.first {
                    Button {
                        Task {
                            try? await storeKitManager.purchase(product)
                            if storeKitManager.isPro {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Text("Upgrade for \(product.displayPrice)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FFD700")!, Color(hex: "#FFA500")!],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(hex: "#FFD700")!.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .onAppear {
                            Task {
                                await storeKitManager.fetchProducts()
                            }
                        }
                }
                
                Button("Restore Purchases") {
                    Task {
                        await storeKitManager.restorePurchases()
                        if storeKitManager.isPro {
                            dismiss()
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .overlay(
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(),
            alignment: .topTrailing
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: "#FFD700"))
                .frame(width: 30)
            
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}
