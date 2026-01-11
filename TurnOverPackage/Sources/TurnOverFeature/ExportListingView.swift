import SwiftUI

// MARK: - Export Listing View

public struct ExportListingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    let analysisResult: AIAnalysisResult
    let platforms: [MarketplacePlatform]
    
    @State private var listingText: String = ""
    @State private var showShareSheet = false
    @State private var showCopiedAlert = false
    
    public init(analysisResult: AIAnalysisResult, platforms: [MarketplacePlatform]) {
        self.analysisResult = analysisResult
        self.platforms = platforms
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Platform Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingSM) {
                        ForEach(platforms, id: \.self) { platform in
                            Text(platform.displayName)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primary.opacity(0.1))
                                .foregroundColor(AppTheme.primary)
                                .cornerRadius(AppTheme.radiusXS)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, AppTheme.spacingSM)
                
                // Listing Preview
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        // Photo
                        if let photo = appState.capturedPhotos.first,
                           let data = photo.imageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(AppTheme.radiusMD)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Generated Listing
                        Text("Generated Listing")
                            .font(.headline)
                        
                        TextEditor(text: $listingText)
                            .font(.body)
                            .frame(minHeight: 200)
                            .padding(AppTheme.spacingSM)
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(AppTheme.radiusSM)
                            .accessibilityLabel("Listing text editor")
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
                            Text("Share Listing")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    // Copy
                    Button(action: {
                        HapticManager.notification(.success)
                        UIPasteboard.general.string = listingText
                        showCopiedAlert = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    // Save & Finish
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
            .navigationTitle("Listing")
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
                generateListing()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [listingText])
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Listing copied to clipboard")
            }
        }
    }
    
    private func generateListing() {
        let item = appState.createItem(from: analysisResult)
        listingText = appState.generateListingText(for: item, platforms: platforms)
    }
    
    private func saveAndFinish() {
        let item = appState.createItem(from: analysisResult)
        appState.saveItem(item)
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
