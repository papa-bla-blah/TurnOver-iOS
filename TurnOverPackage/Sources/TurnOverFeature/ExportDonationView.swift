import SwiftUI

// MARK: - Export Donation View

public struct ExportDonationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    let analysisResult: AIAnalysisResult
    let charity: CharityOrganization
    
    @State private var receiptText: String = ""
    @State private var showShareSheet = false
    @State private var showCopiedAlert = false
    
    public init(analysisResult: AIAnalysisResult, charity: CharityOrganization) {
        self.analysisResult = analysisResult
        self.charity = charity
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Charity Header
                HStack(spacing: AppTheme.spacingMD) {
                    Image(systemName: charity.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(AppTheme.primary)
                        .cornerRadius(AppTheme.radiusSM)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(charity.name)
                            .font(.headline)
                        Text(charity.category)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(AppTheme.secondaryBackground)
                
                // Receipt Preview
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        // Tax Info Banner
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(AppTheme.info)
                            Text("This receipt is for your tax records")
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.info.opacity(0.1))
                        .cornerRadius(AppTheme.radiusSM)
                        
                        // Item Summary
                        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                            Text("Donated Item")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(analysisResult.name)
                                        .font(.subheadline.weight(.medium))
                                    Text(analysisResult.condition.displayName)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                Text("$\(String(format: "%.2f", analysisResult.estimatedValue))")
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.success)
                            }
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(AppTheme.radiusSM)
                        }
                        
                        // High Value Warning
                        if analysisResult.estimatedValue > 5000 {
                            HStack(spacing: AppTheme.spacingSM) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.warning)
                                Text("Items over $5,000 require a qualified appraisal for tax deduction")
                                    .font(.caption)
                            }
                            .padding()
                            .background(AppTheme.warning.opacity(0.1))
                            .cornerRadius(AppTheme.radiusSM)
                        }
                        
                        // Receipt Text
                        Text("Receipt")
                            .font(.headline)
                            .padding(.top, AppTheme.spacingSM)
                        
                        Text(receiptText)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(AppTheme.radiusSM)
                    }
                    .padding()
                }
                
                // Action Buttons
                VStack(spacing: AppTheme.spacingMD) {
                    // Share
                    Button(action: {
                        HapticManager.impact()
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Receipt")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    // Copy
                    Button(action: {
                        HapticManager.notification(.success)
                        UIPasteboard.general.string = receiptText
                        showCopiedAlert = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    // Done
                    Button(action: {
                        HapticManager.impact()
                        saveAndFinish()
                    }) {
                        Text("Save to Inventory & Done")
                            .font(.subheadline)
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.surface)
            }
            .navigationTitle("Donation Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.impact(.light)
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateReceipt()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [receiptText])
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Receipt copied to clipboard")
            }
        }
    }
    
    private func generateReceipt() {
        let item = appState.createItem(from: analysisResult)
        receiptText = appState.generateDonationReceipt(for: item, charity: charity)
    }
    
    private func saveAndFinish() {
        let item = appState.createItem(from: analysisResult)
        appState.saveItem(item)
        HapticManager.notification(.success)
        dismiss()
    }
}
