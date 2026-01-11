import SwiftUI

// MARK: - Decision View

public struct DecisionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let analysisResult: AIAnalysisResult
    
    @State private var showMarketplace = false
    @State private var showCharity = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.spacingXL) {
                Spacer()
                
                // Item summary
                VStack(spacing: AppTheme.spacingSM) {
                    Text(analysisResult.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("$\(String(format: "%.0f", analysisResult.estimatedValue))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.success)
                }
                
                Text("What would you like to do?")
                    .font(.headline)
                    .foregroundColor(AppTheme.textSecondary)
                
                // Decision buttons
                VStack(spacing: AppTheme.spacingMD) {
                    // Sell button
                    Button(action: { showMarketplace = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.title2)
                                    Text("Sell It")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                Text("List on marketplace platforms")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.primary)
                        .cornerRadius(AppTheme.radiusMD)
                    }
                    
                    // Donate button
                    Button(action: { showCharity = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.title2)
                                    Text("Donate It")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                Text("Get a tax-deductible receipt")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(AppTheme.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                                .stroke(AppTheme.secondary, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save for later
                Button("Save to Inventory") {
                    let item = appState.createItem(from: analysisResult)
                    appState.saveItem(item)
                    dismissAll()
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.bottom)
            }
            .navigationTitle("Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showMarketplace) {
                MarketplaceSelectionView(analysisResult: analysisResult)
                    .environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showCharity) {
                CharitySelectionView(analysisResult: analysisResult)
                    .environmentObject(appState)
            }
        }
    }
    
    private func dismissAll() {
        // This will dismiss back to root
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.dismiss(animated: true)
        }
    }
}
