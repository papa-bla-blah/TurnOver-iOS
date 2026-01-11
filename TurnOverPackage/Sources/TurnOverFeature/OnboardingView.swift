import SwiftUI

// MARK: - Onboarding View (First-Time User Experience)

@available(iOS 16.0, *)
public struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var preferences = UserPreferences.shared
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.fill",
            title: "Capture Your Items",
            description: "Take 1-10 photos of anything you want to sell or donate. More angles mean better AI analysis.",
            color: .blue
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Valuation",
            description: "Our AI analyzes your photos to identify the item, assess condition, and estimate fair market value.",
            color: .purple
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            title: "Sell on Marketplaces",
            description: "Generate ready-to-post listings for eBay, Facebook Marketplace, Poshmark, and 5 more platforms.",
            color: .green
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Donate for Tax Benefits",
            description: "Create IRS-compliant donation receipts for Goodwill, Salvation Army, and other charities.",
            color: .red
        ),
        OnboardingPage(
            icon: "level.fill",
            title: "Level Lock Camera",
            description: "Optional feature: Use the built-in level indicator to take perfectly straight photos every time.",
            color: .orange
        )
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundColor(AppTheme.textSecondary)
                .padding()
            }
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            .padding(.vertical)
            
            // Navigation buttons
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button {
                        HapticManager.selection()
                        withAnimation {
                            currentPage -= 1
                        }
                    } label: {
                        Text("Back")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Button {
                    HapticManager.impact(.medium)
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background)
    }
    
    private func completeOnboarding() {
        HapticManager.notification(.success)
        preferences.onboardingCompleted = true
        dismiss()
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            
            // Title
            Text(page.title)
                .font(.title.bold())
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Quick Tips Sheet

@available(iOS 16.0, *)
public struct QuickTipsView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Taking Great Photos") {
                    TipRow(icon: "sun.max", tip: "Use natural lighting when possible")
                    TipRow(icon: "square.dashed", tip: "Keep backgrounds clean and uncluttered")
                    TipRow(icon: "camera.rotate", tip: "Capture multiple angles (front, back, sides)")
                    TipRow(icon: "magnifyingglass", tip: "Include close-ups of labels and details")
                    TipRow(icon: "level", tip: "Try Level Lock for furniture and art")
                }
                
                Section("Better Valuations") {
                    TipRow(icon: "tag", tip: "Show brand names and labels clearly")
                    TipRow(icon: "exclamationmark.triangle", tip: "Document any damage or wear")
                    TipRow(icon: "shippingbox", tip: "Include original packaging if available")
                    TipRow(icon: "number", tip: "Photograph serial numbers for electronics")
                }
                
                Section("Tax Deductions") {
                    TipRow(icon: "doc.text", tip: "Keep all donation receipts")
                    TipRow(icon: "dollarsign.circle", tip: "Items over $500 need detailed records")
                    TipRow(icon: "person.badge.shield.checkmark", tip: "Items over $5,000 require appraisal")
                    TipRow(icon: "building.columns", tip: "Consult a tax professional")
                }
            }
            .navigationTitle("Quick Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            Text(tip)
                .font(.subheadline)
        }
    }
}

// MARK: - API Key Setup Sheet

@available(iOS 16.0, *)
public struct APIKeySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var apiKey = ""
    @State private var showKey = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                VStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("OpenAI API Key Required")
                        .font(.title2.bold())
                    
                    Text("To analyze your items, you need an OpenAI API key. Get one free at platform.openai.com")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.headline)
                    
                    HStack {
                        Group {
                            if showKey {
                                TextField("sk-...", text: $apiKey)
                            } else {
                                SecureField("sk-...", text: $apiKey)
                            }
                        }
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .background(AppTheme.secondaryBackground)
                    .cornerRadius(AppTheme.radiusSM)
                }
                .padding(.horizontal)
                
                // Get Key Link
                Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Get API Key from OpenAI")
                    }
                }
                .font(.subheadline)
                
                Spacer()
                
                // Save Button
                Button {
                    HapticManager.notification(.success)
                    appState.saveAPIKey(apiKey)
                    dismiss()
                } label: {
                    Text("Save & Continue")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(apiKey.isEmpty || !apiKey.hasPrefix("sk-"))
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}
