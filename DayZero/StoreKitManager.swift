import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var isPro: Bool = false {
        didSet {
            // Sync with AppStorage so other views can access without EnvironmentObject
            UserDefaults.standard.set(isPro, forKey: "isPro")
        }
    }
    @Published var products: [Product] = []
    @Published var purchaseError: String? = nil
    
    private let proMonthlyID = "com.dayzero.pro.monthly"
    private let proAnnualID = "com.dayzero.pro.annual"
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        // Restore cached pro status from UserDefaults
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
        updatesTask = listenForTransactions()
        // Check entitlements on launch
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: [proMonthlyID, proAnnualID])
            self.products = storeProducts.sorted(by: { $0.price < $1.price })
            self.purchaseError = nil
        } catch {
            print("Failed to fetch products: \(error)")
            self.purchaseError = "Unable to load subscription options. Please check your internet connection."
            // Retry after a short delay if products are empty
            if products.isEmpty {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                do {
                    let retryProducts = try await Product.products(for: [proMonthlyID, proAnnualID])
                    self.products = retryProducts.sorted(by: { $0.price < $1.price })
                    self.purchaseError = nil
                } catch {
                    print("Retry fetch also failed: \(error)")
                }
            }
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCustomerProductStatus()
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func updateCustomerProductStatus() async {
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == proMonthlyID || transaction.productID == proAnnualID {
                    hasPro = true
                }
            } catch {
                print("Transaction failed verification")
            }
        }
        self.isPro = hasPro
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
