import SwiftUI

// MARK: - Marketplace Selection View

public struct MarketplaceSelectionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    let analysisResult: AIAnalysisResult
    
    @State private var selectedPlatforms: Set<MarketplacePlatform> = []
    @State private var showExport = false
    
    public init(analysisResult: AIAnalysisResult) {
        self.analysisResult = analysisResult
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header info
                VStack(spacing: AppTheme.spacingSM) {
                    Text("Select where to sell")
                        .font(.headline)
                    Text("Choose one or more platforms")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                
                // Platform Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppTheme.spacingMD) {
                        ForEach(MarketplacePlatform.allCases, id: \.self) { platform in
                            PlatformCard(
                                platform: platform,
                                isSelected: selectedPlatforms.contains(platform),
                                onTap: {
                                    HapticManager.selection()
                                    togglePlatform(platform)
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Continue Button
                VStack(spacing: AppTheme.spacingSM) {
                    if !selectedPlatforms.isEmpty {
                        Text("\(selectedPlatforms.count) platform\(selectedPlatforms.count > 1 ? "s" : "") selected")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Button(action: {
                        HapticManager.impact()
                        // Remember selection for next time
                        preferences.rememberPlatforms(Array(selectedPlatforms))
                        showExport = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Create Listing")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedPlatforms.isEmpty)
                }
                .padding()
                .background(AppTheme.surface)
            }
            .navigationTitle("Sell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.impact(.light)
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Load last used platforms
                let remembered = preferences.getRememberedPlatforms()
                if !remembered.isEmpty {
                    selectedPlatforms = Set(remembered)
                }
            }
            .fullScreenCover(isPresented: $showExport) {
                ExportListingView(
                    analysisResult: analysisResult,
                    platforms: Array(selectedPlatforms)
                )
                .environmentObject(appState)
                .environmentObject(preferences)
            }
        }
    }
    
    private func togglePlatform(_ platform: MarketplacePlatform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }
}

// MARK: - Platform Card

struct PlatformCard: View {
    let platform: MarketplacePlatform
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: platform.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : AppTheme.primary)
                
                Text(platform.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? AppTheme.primary : AppTheme.secondaryBackground)
            .cornerRadius(AppTheme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(platform.displayName), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Marketplace Platform

public enum MarketplacePlatform: String, CaseIterable {
    case ebay
    case facebook
    case offerup
    case craigslist
    case poshmark
    case mercari
    case nextdoor
    case etsy
    
    public var displayName: String {
        switch self {
        case .ebay: return "eBay"
        case .facebook: return "Facebook Marketplace"
        case .offerup: return "OfferUp"
        case .craigslist: return "Craigslist"
        case .poshmark: return "Poshmark"
        case .mercari: return "Mercari"
        case .nextdoor: return "Nextdoor"
        case .etsy: return "Etsy"
        }
    }
    
    var icon: String {
        switch self {
        case .ebay: return "cart.fill"
        case .facebook: return "person.2.fill"
        case .offerup: return "tag.fill"
        case .craigslist: return "list.bullet"
        case .poshmark: return "bag.fill"
        case .mercari: return "shippingbox.fill"
        case .nextdoor: return "house.fill"
        case .etsy: return "paintbrush.fill"
        }
    }
}
