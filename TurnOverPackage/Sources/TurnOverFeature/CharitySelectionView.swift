import SwiftUI

// MARK: - Charity Selection View

public struct CharitySelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let analysisResult: AIAnalysisResult
    
    @State private var selectedCharity: CharityOrganization?
    @State private var showExport = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: AppTheme.spacingSM) {
                    Text("Choose a charity")
                        .font(.headline)
                    Text("Select where you'd like to donate")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                
                // Charity list
                ScrollView {
                    VStack(spacing: AppTheme.spacingMD) {
                        ForEach(CharityOrganization.defaultCharities) { charity in
                            CharityCard(
                                charity: charity,
                                isSelected: selectedCharity?.id == charity.id,
                                onTap: { selectedCharity = charity }
                            )
                        }
                    }
                    .padding()
                }
                
                // Continue button
                Button(action: { showExport = true }) {
                    Text("Generate Receipt")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedCharity == nil)
                .padding()
            }
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showExport) {
                if let charity = selectedCharity {
                    ExportDonationView(
                        analysisResult: analysisResult,
                        charity: charity
                    )
                    .environmentObject(appState)
                }
            }
        }
    }
}

// MARK: - Charity Card

struct CharityCard: View {
    let charity: CharityOrganization
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.spacingMD) {
                // Icon
                Image(systemName: "heart.circle.fill")
                    .font(.title)
                    .foregroundColor(isSelected ? .white : AppTheme.secondary)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(charity.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    
                    if !charity.ein.isEmpty {
                        Text("EIN: \(charity.ein)")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? AppTheme.secondary : AppTheme.surface)
            .cornerRadius(AppTheme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(isSelected ? AppTheme.secondary : Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}
