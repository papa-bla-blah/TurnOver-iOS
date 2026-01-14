import SwiftUI

// MARK: - HIG Compliant Settings View

@available(iOS 15.0, *)
public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    @State private var apiKeyInput: String = ""
    @State private var showAPIKey = false
    @State private var saved = false
    @State private var showResetAlert = false
    
    // App Store URLs
    private let privacyURL = URL(string: "https://www.ogsaas.com/turnover/privacy")!
    private let termsURL = URL(string: "https://www.ogsaas.com/turnover/terms")!
    private let supportEmail = "support@ogsaas.com"
    private let openAIURL = URL(string: "https://platform.openai.com/api-keys")!
    private let irsURL = URL(string: "https://www.irs.gov/charities-non-profits/charitable-organizations/charitable-contribution-deductions")!
    
    public var body: some View {
        Form {
            // MARK: - Camera Settings
            Section {
                Toggle(isOn: $preferences.levelLockEnabled) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Level Lock Camera")
                            Text("Helps capture straight photos")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "level")
                            .foregroundColor(AppTheme.primary)
                    }
                }
                .accessibilityHint("When enabled, shows a level indicator to help take straight photos")
                
                if preferences.levelLockEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sensitivity")
                            Spacer()
                            Text(sensitivityLabel)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Slider(value: $preferences.levelLockSensitivity, in: 0.5...5.0, step: 0.5)
                            .tint(AppTheme.primary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Level lock sensitivity: \(sensitivityLabel)")
                }
                
                Toggle(isOn: $preferences.hapticFeedbackEnabled) {
                    Label("Haptic Feedback", systemImage: "hand.tap")
                }
                
                Toggle(isOn: $preferences.autoSavePhotos) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-Save to Photos")
                            Text("Saves captured photos to library")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "photo.on.rectangle")
                    }
                }
            } header: {
                Text("Camera")
            }
            
            // MARK: - AI Configuration
            Section {
                // Status indicator
                HStack {
                    Text("Status")
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: appState.hasAPIKey ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(appState.hasAPIKey ? AppTheme.success : AppTheme.error)
                        Text(appState.hasAPIKey ? "Connected" : "Mock Data")
                            .foregroundColor(appState.hasAPIKey ? AppTheme.success : AppTheme.error)
                            .font(.subheadline.weight(.medium))
                    }
                }
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    HStack {
                        if showAPIKey {
                            TextField("sk-...", text: $apiKeyInput)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("sk-...", text: $apiKeyInput)
                                .textContentType(.password)
                        }
                        
                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .accessibleTapTarget()
                        .accessibilityLabel(showAPIKey ? "Hide API key" : "Show API key")
                    }
                    
                    Button {
                        saveAPIKey()
                        HapticManager.notification(.success)
                    } label: {
                        Label(saved ? "Saved!" : "Save API Key", systemImage: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(apiKeyInput.isEmpty)
                }
                
                if appState.hasAPIKey {
                    Button(role: .destructive) {
                        appState.clearAPIKey()
                        apiKeyInput = ""
                        HapticManager.notification(.warning)
                    } label: {
                        Label("Remove API Key", systemImage: "trash")
                    }
                }
                
                Toggle(isOn: $preferences.showAnalysisInsights) {
                    Label("Show AI Insights", systemImage: "lightbulb")
                }
            } header: {
                Text("AI Configuration")
            } footer: {
                Text("Get your API key from platform.openai.com")
            }
            
            // MARK: - Export Preferences
            Section {
                Picker("Default Format", selection: $preferences.preferredExportFormat) {
                    Text("Share Sheet").tag("share")
                    Text("Copy Text").tag("text")
                    Text("PDF Document").tag("pdf")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Photo Quality")
                    HStack {
                        Text("Smaller")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Slider(value: $preferences.compressionQuality, in: 0.5...1.0, step: 0.1)
                            .tint(AppTheme.primary)
                        Text("Better")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Photo quality: \(Int(preferences.compressionQuality * 100))%")
            } header: {
                Text("Export Settings")
            } footer: {
                Text("These settings are remembered for next time")
            }
            
            // MARK: - Help & Resources
            Section {
                Link(destination: openAIURL) {
                    Label("Get OpenAI API Key", systemImage: "key")
                }
                
                Link(destination: irsURL) {
                    Label("IRS Donation Guidelines", systemImage: "doc.text")
                }
                
                Button {
                    sendSupportEmail()
                } label: {
                    Label("Contact Support", systemImage: "envelope")
                }
            } header: {
                Text("Help & Resources")
            }
            
            // MARK: - Legal (Required for App Store)
            Section {
                Link(destination: privacyURL) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Link(destination: termsURL) {
                    HStack {
                        Label("Terms of Service", systemImage: "doc.plaintext")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            } header: {
                Text("Legal")
            }
            
            // MARK: - About
            Section {
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build", value: buildNumber)
                LabeledContent("AI Model", value: "GPT-4o Mini")
                LabeledContent("Platform", value: "iOS \(UIDevice.current.systemVersion)")
            } header: {
                Text("About")
            }
            
            // MARK: - Data Management
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                }
                
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("This will remove all saved items and preferences")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            apiKeyInput = appState.apiKey
        }
        .alert("Clear All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                preferences.resetToDefaults()
                appState.clearAllData()
                HapticManager.notification(.warning)
            }
        } message: {
            Text("This will remove all items, donations, and preferences. This cannot be undone.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var sensitivityLabel: String {
        switch preferences.levelLockSensitivity {
        case 0.5...1.0: return "Tight"
        case 1.5...2.5: return "Normal"
        case 3.0...4.0: return "Loose"
        default: return "Very Loose"
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Actions
    
    private func saveAPIKey() {
        appState.saveAPIKey(apiKeyInput)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saved = false
        }
    }
    
    private func sendSupportEmail() {
        let subject = "TurnOver App Support - v\(appVersion)"
        let urlString = "mailto:\(supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 15.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AppState.shared)
                .environmentObject(UserPreferences.shared)
        }
    }
}
#endif
