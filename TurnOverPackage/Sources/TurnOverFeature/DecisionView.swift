import SwiftUI

// MARK: - Decision View

public struct DecisionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    let analysisResult: AIAnalysisResult
    
    @State private var showMarketplaceSelection = false
    @State private var showCharitySelection = false
    @State private var selectedAction: ItemAction?
    
    public init(analysisResult: AIAnalysisResult) {
        self.analysisResult = analysisResult
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingLG) {
                // Item Summary Card
                VStack(spacing: AppTheme.spacingMD) {
                    Text(analysisResult.name)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: AppTheme.spacingLG) {
                        VStack {
                            Text("$\(String(format: "%.0f", analysisResult.estimatedValue))")
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.success)
                            Text("Est. Value")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text(analysisResult.condition.displayName)
                                .font(.headline)
                            Text("Condition")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(AppTheme.radiusMD)
                .padding(.horizontal)
                
                // Question
                Text("What would you like to do?")
                    .font(.headline)
                    .padding(.top, AppTheme.spacingMD)
                
                // Action Buttons
                VStack(spacing: AppTheme.spacingMD) {
                    // Sell Option
                    ActionCard(
                        icon: "dollarsign.circle.fill",
                        title: "Sell It",
                        subtitle: "List on marketplaces",
                        color: AppTheme.success,
                        action: {
                            HapticManager.impact()
                            selectedAction = .sell
                            showMarketplaceSelection = true
                        }
                    )
                    
                    // Donate Option
                    ActionCard(
                        icon: "heart.circle.fill",
                        title: "Donate It",
                        subtitle: "Get a tax deduction receipt",
                        color: AppTheme.primary,
                        action: {
                            HapticManager.impact()
                            selectedAction = .donate
                            showCharitySelection = true
                        }
                    )
                    
                    // Keep Option
                    ActionCard(
                        icon: "archivebox.circle.fill",
                        title: "Keep It",
                        subtitle: "Save to inventory for later",
                        color: AppTheme.warning,
                        action: {
                            HapticManager.impact()
                            saveToInventory()
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        HapticManager.impact(.light)
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showMarketplaceSelection) {
                MarketplaceSelectionView(analysisResult: analysisResult)
                    .environmentObject(appState)
                    .environmentObject(preferences)
            }
            .fullScreenCover(isPresented: $showCharitySelection) {
                CharitySelectionView(analysisResult: analysisResult)
                    .environmentObject(appState)
                    .environmentObject(preferences)
            }
        }
    }
    
    private func saveToInventory() {
        let item = appState.createItem(from: analysisResult)
        appState.saveItem(item)
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - Action Card

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.radiusMD)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityHint("Double tap to select")
    }
}

// MARK: - Item Action

enum ItemAction {
    case sell
    case donate
    case keep
}
