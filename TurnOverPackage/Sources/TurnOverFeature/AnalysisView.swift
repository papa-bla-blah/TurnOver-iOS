import SwiftUI

// MARK: - Analysis View (HIG Compliant)

public struct AnalysisView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = StoreManager.shared
    
    @State private var analysisResult: AIAnalysisResult?
    @State private var showDecision = false
    @State private var errorMessage: String?
    @State private var showUpgrade = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingLG) {
                if !store.canUseAI && analysisResult == nil {
                    // Usage limit reached
                    UsageLimitView(showUpgrade: $showUpgrade)
                } else if appState.isAnalyzing {
                    // Loading state
                    AnalyzingView()
                } else if let error = errorMessage {
                    // Error state
                    ErrorView(message: error, onRetry: {
                        errorMessage = nil
                        startAnalysis()
                    })
                } else if let result = analysisResult {
                    // Results
                    AnalysisResultView(
                        result: result,
                        showInsights: preferences.showAnalysisInsights,
                        onContinue: { showDecision = true }
                    )
                } else {
                    // Initial state
                    ProgressView("Preparing...")
                }
            }
            .navigationTitle("Analysis")
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
                if analysisResult == nil && !appState.isAnalyzing && store.canUseAI {
                    startAnalysis()
                }
            }
            .fullScreenCover(isPresented: $showDecision) {
                if let result = analysisResult {
                    DecisionView(analysisResult: result)
                        .environmentObject(appState)
                        .environmentObject(preferences)
                }
            }
            .sheet(isPresented: $showUpgrade) {
                PremiumUpgradeView()
            }
        }
    }
    
    private func startAnalysis() {
        Task {
            do {
                let result = try await appState.analyzePhotos()
                analysisResult = result
                store.recordAnalysisUsage()
                HapticManager.notification(.success)
            } catch {
                errorMessage = error.localizedDescription
                HapticManager.notification(.error)
            }
        }
    }
}

// MARK: - Usage Limit View

struct UsageLimitView: View {
    @Binding var showUpgrade: Bool
    @StateObject private var store = StoreManager.shared
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.warning)
            
            Text("Monthly Limit Reached")
                .font(.title2.bold())
            
            Text("You've used all \(3) free AI analyses this month. Upgrade to Premium for unlimited analyses.")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showUpgrade = true }) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Analyzing View

struct AnalyzingView: View {
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.primary)
            
            Text("Analyzing your item\(dots)")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .animation(.none, value: dots)
            
            Text("This may take a few seconds")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateDots()
        }
    }
    
    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if dots.count >= 3 {
                dots = ""
            } else {
                dots += "."
            }
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.error)
            
            Text("Analysis Failed")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Analysis Result View

struct AnalysisResultView: View {
    let result: AIAnalysisResult
    let showInsights: Bool
    let onContinue: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
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
                        .accessibilityLabel("Photo of \(result.name)")
                }
                
                // Analysis results
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text(result.name)
                        .font(.title2.bold())
                    
                    HStack {
                        Label(result.category, systemImage: "tag")
                        Spacer()
                        Label(result.condition.displayName, systemImage: "star")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    // Value Card
                    HStack {
                        Text("Estimated Value")
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                        Text("$\(String(format: "%.0f", result.estimatedValue))")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.success)
                    }
                    .padding()
                    .background(AppTheme.secondaryBackground)
                    .cornerRadius(AppTheme.radiusSM)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Estimated value: $\(Int(result.estimatedValue))")
                    
                    // Confidence
                    HStack {
                        Text("AI Confidence")
                        Spacer()
                        ConfidenceBadge(score: result.confidenceScore)
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
                    
                    // Insights (conditional)
                    if showInsights && !result.insights.isEmpty {
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
        Button(action: {
            HapticManager.impact()
            onContinue()
        }) {
            HStack {
                Text("Continue")
                Image(systemName: "arrow.right")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding()
    }
}

// MARK: - Confidence Badge

struct ConfidenceBadge: View {
    let score: Double
    
    var color: Color {
        if score >= 0.8 { return AppTheme.success }
        if score >= 0.6 { return AppTheme.warning }
        return AppTheme.error
    }
    
    var body: some View {
        Text("\(Int(score * 100))%")
            .font(.subheadline.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(AppTheme.radiusXS)
    }
}
