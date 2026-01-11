import SwiftUI

// MARK: - Marketplace Selection View

public struct MarketplaceSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let analysisResult: AIAnalysisResult
    
    @State private var selectedPlatforms: Set<MarketplacePlatform> = []
    @State private var showExport = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: AppTheme.spacingSM) {
                    Text("Where do you want to sell?")
                        .font(.headline)
                    Text("Select one or more platforms")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                
                // Platform grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.spacingMD) {
                        ForEach(MarketplacePlatform.allCases) { platform in
                            PlatformCard(
                                platform: platform,
                                isSelected: selectedPlatforms.contains(platform),
                                onTap: {
                                    if selectedPlatforms.contains(platform) {
                                        selectedPlatforms.remove(platform)
                                    } else {
                                        selectedPlatforms.insert(platform)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Continue button
                Button(action: { showExport = true }) {
                    HStack {
                        Text("Generate Listing")
                        Text("(\(selectedPlatforms.count))")
                            .opacity(0.8)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedPlatforms.isEmpty)
                .padding()
            }
            .navigationTitle("Sell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showExport) {
                ExportListingView(
                    analysisResult: analysisResult,
                    platforms: Array(selectedPlatforms)
                )
                .environmentObject(appState)
            }
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
                    .font(.title)
                    .foregroundColor(isSelected ? .white : AppTheme.primary)
                
                Text(platform.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? AppTheme.primary : AppTheme.surface)
            .cornerRadius(AppTheme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(isSelected ? AppTheme.primary : Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? AppTheme.primary.opacity(0.3) : Color.clear, radius: 4)
        }
    }
}
