import SwiftUI

// MARK: - Analysis View

public struct AnalysisView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var analysisResult: AIAnalysisResult?
    @State private var showDecision = false
    @State private var errorMessage: String?
    
    public var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.spacingLG) {
                if appState.isAnalyzing {
                    // Loading state
                    VStack(spacing: AppTheme.spacingMD) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing your item...")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("This may take a few seconds")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    // Error state
                    VStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.error)
                        Text("Analysis Failed")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            errorMessage = nil
                            startAnalysis()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                    }
                } else if let result = analysisResult {
                    // Results
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            // Item preview
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
                            
                            // Analysis results
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text(result.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Label(result.category, systemImage: "tag")
                                    Spacer()
                                    Label(result.condition.displayName, systemImage: "star")
                                }
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                
                                // Value
                                HStack {
                                    Text("Estimated Value")
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text("$\(String(format: "%.0f", result.estimatedValue))")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.success)
                                }
                                .padding()
                                .background(AppTheme.background)
                                .cornerRadius(AppTheme.radiusSM)
                                
                                // Confidence
                                HStack {
                                    Text("AI Confidence")
                                    Spacer()
                                    Text("\(Int(result.confidenceScore * 100))%")
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                
                                Divider()
                                
                                // Description
                                Text("Description")
                                    .font(.headline)
                                Text(result.description)
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                // Insights
                                if !result.insights.isEmpty {
                                    Text("AI Insights")
                                        .font(.headline)
                                        .padding(.top, AppTheme.spacingSM)
                                    Text(result.insights)
                                        .font(.body)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding()
                                        .background(AppTheme.accent.opacity(0.1))
                                        .cornerRadius(AppTheme.radiusSM)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Continue button
                    Button(action: { showDecision = true }) {
                        HStack {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                if analysisResult == nil && !appState.isAnalyzing {
                    startAnalysis()
                }
            }
            .fullScreenCover(isPresented: $showDecision) {
                if let result = analysisResult {
                    DecisionView(analysisResult: result)
                        .environmentObject(appState)
                }
            }
        }
    }
    
    private func startAnalysis() {
        Task {
            do {
                let result = try await appState.analyzePhotos()
                analysisResult = result
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
