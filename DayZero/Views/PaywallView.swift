import SwiftUI
import StoreKit

// MARK: - PaywallView (entry point, aliased for ContentView compatibility)
typealias PaywallView = PremiumPaywallView

// MARK: - Premium Paywall View
struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var storeKitManager: StoreKitManager

    // Pricing plan selection
    @State private var selectedPlan: PricingPlan = .annual

    // Animation states
    @State private var backgroundPhase: CGFloat = 0
    @State private var glowPulse: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -300
    @State private var featuresVisible: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var isRestoring: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showManageSubscriptions: Bool = false

    enum PricingPlan: String, CaseIterable {
        case monthly = "Monthly"
        case annual  = "Annual"

        var id: String {
            self == .monthly ? "com.dayzero.pro.monthly" : "com.dayzero.pro.annual"
        }

        func price(from products: [Product]) -> String {
            if let product = products.first(where: { $0.id == id }) {
                return product.displayPrice
            }
            return self == .monthly ? "₺149,99" : "₺899,99"
        }

        func displayName(from products: [Product]) -> String {
            if let product = products.first(where: { $0.id == id }) {
                return product.displayName
            }
            return self.rawValue
        }

        var subLabel: String {
            switch self {
            case .monthly: return "Billed monthly"
            case .annual:  return "Billed annually · Save 50%"
            }
        }

        var badge: String? {
            switch self {
            case .annual:  return "BEST VALUE"
            case .monthly: return nil
            }
        }
    }

    // MARK: - Feature Data
    private let features: [(icon: String, emoji: String, title: String, subtitle: String)] = [
        ("infinity",            "♾️", "Unlimited Countdowns",       "Break the 3-event limit forever"),
        ("textformat.size",     "✨", "Premium Typography & Themes", "Unlock all aesthetic fonts & styles"),
        ("checkmark.seal.fill", "✅", "Milestone Checklists",        "Sub-tasks & progress for every event"),
        ("timer",               "⏱️", "Live Activities",             "Real-time ticking · Lock Screen & Dynamic Island"),
    ]

    // MARK: - Computed Properties
    private var productsLoaded: Bool {
        !storeKitManager.products.isEmpty
    }

    private var trialText: String {
        if let product = storeKitManager.products.first(where: { $0.id == selectedPlan.id }),
           let subscription = product.subscription,
           let introOffer = subscription.introductoryOffer {
            let periodText: String
            switch introOffer.period.unit {
            case .day:
                periodText = "\(introOffer.period.value)-Day"
            case .week:
                periodText = "\(introOffer.period.value * 7)-Day"
            case .month:
                periodText = "\(introOffer.period.value)-Month"
            case .year:
                periodText = "\(introOffer.period.value)-Year"
            @unknown default:
                periodText = "14-Day"
            }
            return "Start \(periodText) Free Trial"
        }
        return "Start 14-Day Free Trial"
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // ── Animated Mesh Background ──────────────────────────────
            meshBackground

            // ── Content ───────────────────────────────────────────────
            VStack(spacing: 0) {
                // Close button row
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // ── Hero ─────────────────────────────────────
                        heroSection

                        // ── Feature Rows ─────────────────────────────
                        featureRows

                        // ── Pricing Cards ────────────────────────────
                        pricingCards

                        // ── CTA Button ───────────────────────────────
                        ctaButton
                        
                        // ── Clear Subscription Terms ─────────────────
                        termsText

                        // ── Footer Links & Disclosures ───────────────
                        footerLinks
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
            }
            
            // ── Loading Overlay ───────────────────────────────────────
            if isPurchasing || isRestoring {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text(isPurchasing ? "Processing..." : "Restoring...")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .ignoresSafeArea()
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        .onAppear {
            startBackgroundAnimation()
            startGlowPulse()
            startShimmer()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                featuresVisible = true
            }
            Task { await storeKitManager.fetchProducts() }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
            if !productsLoaded {
                Button("Retry") {
                    Task { await storeKitManager.fetchProducts() }
                }
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Mesh Background
    private var meshBackground: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12)
                .ignoresSafeArea()

            // Blob 1 – deep violet
            ellipsoid(
                color: Color(red: 0.42, green: 0.16, blue: 0.86),
                width: 380, height: 380,
                offset: CGSize(
                    width: -100 + sin(backgroundPhase * 0.7) * 30,
                    height: -240 + cos(backgroundPhase * 0.5) * 40
                ),
                blur: 90
            )
            // Blob 2 – neon indigo
            ellipsoid(
                color: Color(red: 0.22, green: 0.10, blue: 0.70),
                width: 320, height: 280,
                offset: CGSize(
                    width: 140 + cos(backgroundPhase * 0.6) * 25,
                    height: 100 + sin(backgroundPhase * 0.8) * 35
                ),
                blur: 100
            )
            // Blob 3 – electric teal
            ellipsoid(
                color: Color(red: 0.04, green: 0.65, blue: 0.82),
                width: 260, height: 220,
                offset: CGSize(
                    width: 80 + sin(backgroundPhase * 0.9) * 20,
                    height: 300 + cos(backgroundPhase * 0.55) * 30
                ),
                blur: 110
            )
            // Blob 4 – magenta accent
            ellipsoid(
                color: Color(red: 0.85, green: 0.15, blue: 0.55),
                width: 200, height: 200,
                offset: CGSize(
                    width: -140 + cos(backgroundPhase) * 15,
                    height: 220 + sin(backgroundPhase * 0.75) * 20
                ),
                blur: 80
            )
        }
    }

    private func ellipsoid(color: Color, width: CGFloat, height: CGFloat, offset: CGSize, blur: CGFloat) -> some View {
        Ellipse()
            .fill(color.opacity(0.55))
            .frame(width: width, height: height)
            .offset(offset)
            .blur(radius: blur)
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 10) {
            // Crown badge
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 76, height: 76)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.82, blue: 0.20),
                                        Color(red: 1.0, green: 0.50, blue: 0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(red: 0.42, green: 0.16, blue: 0.86).opacity(0.6 * glowPulse), radius: 18 * glowPulse)

                Image(systemName: "crown.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.85, blue: 0.25), Color(red: 1.0, green: 0.50, blue: 0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("DayZero Pro")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Try full version free for 14 days.\nCancel anytime.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.1)))
        }
        .padding(.top, 6)
    }

    // MARK: - Feature Rows
    private var featureRows: some View {
        VStack(spacing: 10) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                GlassFeatureRow(
                    systemIcon: feature.icon,
                    title: feature.title,
                    subtitle: feature.subtitle
                )
                .offset(x: featuresVisible ? 0 : 40)
                .opacity(featuresVisible ? 1 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.75)
                    .delay(Double(index) * 0.08 + 0.15),
                    value: featuresVisible
                )
            }
        }
    }

    // MARK: - Pricing Cards
    private var pricingCards: some View {
        HStack(spacing: 12) {
            if productsLoaded {
                ForEach(PricingPlan.allCases, id: \.self) { plan in
                    PricingCard(
                        plan: plan,
                        products: storeKitManager.products,
                        isSelected: selectedPlan == plan,
                        glowPulse: glowPulse
                    )
                    .onTapGesture {
                        if selectedPlan == plan {
                            handlePurchase()
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedPlan = plan
                            }
                        }
                    }
                }
            } else {
                // Loading state for pricing cards
                ForEach(PricingPlan.allCases, id: \.self) { plan in
                    PricingCard(
                        plan: plan,
                        products: [],
                        isSelected: selectedPlan == plan,
                        glowPulse: glowPulse
                    )
                }
                .overlay(
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading prices...")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
            }
        }
    }

    private func handlePurchase() {
        guard productsLoaded else {
            errorMessage = "Products are still loading. Please wait a moment and try again."
            showError = true
            // Try to fetch products again
            Task { await storeKitManager.fetchProducts() }
            return
        }

        Task {
            isPurchasing = true
            let productID = selectedPlan.id
            if let product = storeKitManager.products.first(where: { $0.id == productID }) {
                do {
                    let result = try await product.purchase()
                    switch result {
                    case .success(let verification):
                        guard case .verified(let transaction) = verification else {
                            errorMessage = "Purchase could not be verified. Please try again."
                            showError = true
                            isPurchasing = false
                            return
                        }
                        await transaction.finish()
                        await storeKitManager.updateCustomerProductStatus()
                        dismiss()
                    case .userCancelled:
                        break
                    case .pending:
                        errorMessage = "Your purchase is pending approval. You'll get access once it's confirmed."
                        showError = true
                    @unknown default:
                        break
                    }
                } catch {
                    errorMessage = "Purchase failed: \(error.localizedDescription)"
                    showError = true
                }
            } else {
                errorMessage = "This subscription is temporarily unavailable. Please try again later."
                showError = true
                // Try to fetch again
                await storeKitManager.fetchProducts()
            }
            isPurchasing = false
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            handlePurchase()
        } label: {
            ZStack {
                // Base gradient
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: productsLoaded ? [
                                Color(red: 0.55, green: 0.22, blue: 1.0),
                                Color(red: 0.28, green: 0.12, blue: 0.88),
                                Color(red: 0.04, green: 0.60, blue: 0.80)
                            ] : [
                                Color(white: 0.3),
                                Color(white: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 58)

                // Shimmer overlay
                if productsLoaded {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.18),
                                    .clear
                                ],
                                startPoint: .init(x: shimmerOffset / 340, y: 0),
                                endPoint:   .init(x: shimmerOffset / 340 + 0.55, y: 1)
                            )
                        )
                        .frame(height: 58)
                        .clipped()
                }

                VStack(spacing: 2) {
                    if productsLoaded {
                        Text(trialText)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Text("Then \(selectedPlan.price(from: storeKitManager.products)) per \(selectedPlan == .monthly ? "month" : "year") · Auto-renews · Cancel anytime")
                            .font(.system(size: 11, weight: .medium))
                            .opacity(0.8)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Loading subscription options...")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .opacity(0.7)
                    }
                }
                .foregroundColor(.white)
            }
        }
        .scaleEffect(productsLoaded ? glowPulse * 0.012 + 0.988 : 1.0)   // subtle breathing
        .shadow(
            color: productsLoaded
                ? Color(red: 0.42, green: 0.16, blue: 0.86).opacity(0.55 * glowPulse)
                : .clear,
            radius: productsLoaded ? 22 * glowPulse : 0,
            x: 0, y: 8
        )
        .disabled(isPurchasing || isRestoring || !productsLoaded)
    }
    
    // MARK: - Clear Terms Text (Apple Guideline 3.1.2 Compliance)
    private var termsText: some View {
        VStack(spacing: 8) {
            if productsLoaded {
                let price = selectedPlan.price(from: storeKitManager.products)
                let period = selectedPlan == .monthly ? "month" : "year"
                Text("14-day free trial, then \(price) per \(period). Auto-renews. Cancel anytime.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            
            Text("Payment will be charged to your Apple ID account at the confirmation of purchase, or at the end of the free trial period. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your device's Settings > Apple ID > Subscriptions. Any unused portion of a free trial period will be forfeited when you purchase a subscription.")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 10)
        }
    }

    // MARK: - Footer Links & Disclosures
    private var footerLinks: some View {
        VStack(spacing: 14) {
            // Restore Purchases
            Button {
                Task {
                    isRestoring = true
                    await storeKitManager.restorePurchases()
                    if storeKitManager.isPro {
                        dismiss()
                    } else {
                        errorMessage = "No active subscriptions found for this Apple ID."
                        showError = true
                    }
                    isRestoring = false
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Capsule().fill(.white.opacity(0.15)))
            }
            .disabled(isPurchasing || isRestoring)

            // Manage Subscriptions (Apple Required — native sheet)
            Button {
                showManageSubscriptions = true
            } label: {
                Text("Manage Subscriptions")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }

            // Legal Links (All Required by Apple)
            HStack(spacing: 8) {
                Button("Terms of Use") {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                        openURL(url)
                    }
                }
                
                Text("·").foregroundColor(.white.opacity(0.3))
                
                Button("Privacy Policy") {
                    if let url = URL(string: "https://bunyamin027.github.io/Legal/#privacy") {
                        openURL(url)
                    }
                }
                
                Text("·").foregroundColor(.white.opacity(0.3))
                
                Button("Subscription Terms") {
                    if let url = URL(string: "https://bunyamin027.github.io/Legal/#terms") {
                        openURL(url)
                    }
                }
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white.opacity(0.5))
            
            // Developer Contact Info (Guideline 1.5.0)
            Text("Developer: Bunyamin Apps\nContact: bunyamin027@icloud.com")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    // MARK: - Animation Drivers
    private func startBackgroundAnimation() {
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            backgroundPhase = .pi * 2
        }
    }

    private func startGlowPulse() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            glowPulse = 1.35
        }
    }

    private func startShimmer() {
        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false).delay(0.8)) {
            shimmerOffset = 340
        }
    }
}

// MARK: - Glass Feature Row
private struct GlassFeatureRow: View {
    let systemIcon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.22, blue: 1.0).opacity(0.55),
                                Color(red: 0.04, green: 0.60, blue: 0.80).opacity(0.40)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: systemIcon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.50))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.22, blue: 1.0), Color(red: 0.04, green: 0.60, blue: 0.80)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.09), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pricing Card
private struct PricingCard: View {
    let plan: PremiumPaywallView.PricingPlan
    let products: [Product]
    let isSelected: Bool
    let glowPulse: CGFloat

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 5) {
                Text(plan.displayName(from: products))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))

                Text(plan.price(from: products))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.70))

                Text(plan.subLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.75) : .white.opacity(0.38))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected
                          ? AnyShapeStyle(LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.16, blue: 0.86).opacity(0.70),
                                    Color(red: 0.20, green: 0.08, blue: 0.60).opacity(0.60)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                          : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                isSelected
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [
                                        Color(red: 0.70, green: 0.45, blue: 1.0),
                                        Color(red: 0.20, green: 0.80, blue: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color.white.opacity(0.08)),
                                lineWidth: isSelected ? 1.8 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected
                    ? Color(red: 0.42, green: 0.16, blue: 0.86).opacity(0.50 * glowPulse)
                    : .clear,
                radius: isSelected ? 16 * glowPulse : 0,
                x: 0, y: 6
            )
            .scaleEffect(isSelected ? 1.025 : 1.0)

            // Badge
            if let badge = plan.badge {
                Text(badge)
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(red: 1.0, green: 0.82, blue: 0.20), Color(red: 1.0, green: 0.50, blue: 0.10)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .offset(x: -10, y: -10)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PremiumPaywallView()
        .environmentObject(StoreKitManager.shared)
}
