import StoreKit
import SwiftUI

// MARK: - StoreKit 2 Manager for iOS Monetization

@available(iOS 15.0, *)
@MainActor
public class StoreManager: ObservableObject {
    public static let shared = StoreManager()
    
    // MARK: - Product IDs (Configure in App Store Connect)
    public enum ProductID: String, CaseIterable {
        case removeAds = "com.ogsaas.turnover.removeads"
        case premiumMonthly = "com.ogsaas.turnover.premium.monthly"
        case premiumYearly = "com.ogsaas.turnover.premium.yearly"
        case unlimitedAnalysis = "com.ogsaas.turnover.unlimited"
    }
    
    // MARK: - Published State
    @Published public var products: [Product] = []
    @Published public var purchasedProductIDs: Set<String> = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // MARK: - Computed Properties
    public var hasRemoveAds: Bool {
        purchasedProductIDs.contains(ProductID.removeAds.rawValue)
    }
    
    public var hasPremium: Bool {
        purchasedProductIDs.contains(ProductID.premiumMonthly.rawValue) ||
        purchasedProductIDs.contains(ProductID.premiumYearly.rawValue)
    }
    
    public var hasUnlimitedAnalysis: Bool {
        purchasedProductIDs.contains(ProductID.unlimitedAnalysis.rawValue) || hasPremium
    }
    
    // MARK: - Transaction Listener
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    public func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    
    public func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            
            // Update UserPreferences
            if product.id == ProductID.removeAds.rawValue {
                UserPreferences.shared.adsRemoved = true
            }
            if product.id.contains("premium") {
                UserPreferences.shared.premiumUnlocked = true
            }
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            errorMessage = "Purchase pending approval"
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Restore Purchases
    
    public func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Check Entitlements
    
    public func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
        
        // Sync with UserPreferences
        UserPreferences.shared.adsRemoved = hasRemoveAds
        UserPreferences.shared.premiumUnlocked = hasPremium
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors

public enum StoreError: LocalizedError {
    case verificationFailed
    case purchaseFailed
    case productNotFound
    
    public var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Purchase verification failed"
        case .purchaseFailed:
            return "Purchase could not be completed"
        case .productNotFound:
            return "Product not found"
        }
    }
}

// MARK: - Purchase Button View

@available(iOS 15.0, *)
public struct PurchaseButton: View {
    let product: Product
    let action: () async -> Void
    
    @State private var isPurchasing = false
    
    public init(product: Product, action: @escaping () async -> Void) {
        self.product = product
        self.action = action
    }
    
    public var body: some View {
        Button {
            Task {
                isPurchasing = true
                await action()
                isPurchasing = false
            }
        } label: {
            if isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(product.displayPrice)
                    .font(.headline)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 8)
        .background(AppTheme.primary)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .disabled(isPurchasing)
    }
}

// MARK: - Premium Upsell View

@available(iOS 15.0, *)
public struct PremiumUpsellView: View {
    @StateObject private var store = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    // Header
                    VStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.accent)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle.bold())
                        
                        Text("Get the most out of TurnOver")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, AppTheme.spacingXL)
                    
                    // Features
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        FeatureRow(icon: "xmark.circle", title: "Remove Ads", description: "Clean, distraction-free experience")
                        FeatureRow(icon: "infinity", title: "Unlimited Analysis", description: "No daily limits on AI valuations")
                        FeatureRow(icon: "star.fill", title: "Priority Support", description: "Get help when you need it")
                        FeatureRow(icon: "arrow.up.circle", title: "Early Features", description: "Access new features first")
                    }
                    .padding()
                    .background(AppTheme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                    
                    // Products
                    if store.isLoading {
                        ProgressView("Loading options...")
                    } else if let error = store.errorMessage {
                        Text(error)
                            .foregroundColor(AppTheme.error)
                    } else {
                        ForEach(store.products, id: \.id) { product in
                            ProductRow(product: product)
                        }
                    }
                    
                    // Restore
                    Button("Restore Purchases") {
                        Task {
                            await store.restorePurchases()
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    // Legal
                    Text("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

@available(iOS 15.0, *)
struct ProductRow: View {
    let product: Product
    @StateObject private var store = StoreManager.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            if store.purchasedProductIDs.contains(product.id) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.success)
                    .font(.title2)
            } else {
                PurchaseButton(product: product) {
                    _ = try? await store.purchase(product)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
