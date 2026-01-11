import SwiftUI

// MARK: - Export Donation View

public struct ExportDonationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let analysisResult: AIAnalysisResult
    let charity: CharityOrganization
    
    @State private var copied = false
    
    private var receiptText: String {
        let item = Item(
            name: analysisResult.name,
            description: analysisResult.description,
            category: analysisResult.category,
            condition: analysisResult.condition,
            estimatedValue: analysisResult.estimatedValue,
            confidenceScore: analysisResult.confidenceScore,
            aiInsights: analysisResult.insights
        )
        return appState.generateDonationReceipt(for: item, charity: charity)
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        // Success header
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(AppTheme.secondary)
                                .font(.title)
                            Text("Receipt Ready!")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        // Charity info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Donating to:")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(charity.name)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        // Value reminder
                        if analysisResult.estimatedValue > 5000 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.accent)
                                Text("Items over $5,000 require a qualified appraisal for tax deduction.")
                                    .font(.caption)
                            }
                            .padding()
                            .background(AppTheme.accent.opacity(0.1))
                            .cornerRadius(AppTheme.radiusSM)
                            .padding(.horizontal)
                        }
                        
                        // Receipt text
                        Text(receiptText)
                            .font(.system(.body, design: .monospaced))
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
                            Text(copied ? "Copied!" : "Copy Receipt")
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
            .navigationTitle("Donation Receipt")
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
        UIPasteboard.general.string = receiptText
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
    
    private func shareText() {
        let activityVC = UIActivityViewController(
            activityItems: [receiptText],
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
        item.status = .donated
        appState.saveItem(item)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.dismiss(animated: true)
        }
    }
}
