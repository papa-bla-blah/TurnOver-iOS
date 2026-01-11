import SwiftUI

// MARK: - Export Listing View

public struct ExportListingView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let analysisResult: AIAnalysisResult
    let platforms: [MarketplacePlatform]
    
    @State private var copied = false
    
    private var listingText: String {
        let item = Item(
            name: analysisResult.name,
            description: analysisResult.description,
            category: analysisResult.category,
            condition: analysisResult.condition,
            estimatedValue: analysisResult.estimatedValue,
            confidenceScore: analysisResult.confidenceScore,
            aiInsights: analysisResult.insights
        )
        return appState.generateListingText(for: item, platforms: platforms)
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        // Success header
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.success)
                                .font(.title)
                            Text("Listing Ready!")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        // Platforms
                        Text("Platforms: \(platforms.map { $0.displayName }.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal)
                        
                        // Listing text
                        Text(listingText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.background)
                            .cornerRadius(AppTheme.radiusMD)
                            .padding(.horizontal)
                    }
                }
                
                // Action buttons
                VStack(spacing: AppTheme.spacingMD) {
                    Button(action: copyToClipboard) {
                        HStack {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            Text(copied ? "Copied!" : "Copy to Clipboard")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(action: shareText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = listingText
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
    
    private func shareText() {
        let activityVC = UIActivityViewController(
            activityItems: [listingText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func saveAndDismiss() {
        var item = appState.createItem(from: analysisResult)
        item.selectedPlatforms = platforms
        item.status = .readyToList
        appState.saveItem(item)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.dismiss(animated: true)
        }
    }
}
