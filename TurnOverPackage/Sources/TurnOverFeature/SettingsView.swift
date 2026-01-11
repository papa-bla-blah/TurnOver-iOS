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
            
            // MARK: - About
            Section {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("AI Model", value: "GPT-4o Mini")
                LabeledContent("Platform", value: "iOS \(UIDevice.current.systemVersion)")
            } header: {
                Text("About")
            }
            
            // MARK: - Help & Resources
            Section {
                Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                    Label("Get OpenAI API Key", systemImage: "key")
                }
                
                Link(destination: URL(string: "https://www.irs.gov/charities-non-profits/charitable-organizations/charitable-contribution-deductions")!) {
                    Label("IRS Donation Guidelines", systemImage: "doc.text")
                }
            } header: {
                Text("Help & Resources")
            }
            
            // MARK: - Reset
            Section {
                Button(role: .destructive) {
                    HapticManager.notification(.warning)
                    preferences.resetToDefaults()
                } label: {
                    Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            apiKeyInput = appState.apiKey
        }
    }
    
    private var sensitivityLabel: String {
        switch preferences.levelLockSensitivity {
        case 0.5...1.0: return "Tight"
        case 1.5...2.5: return "Normal"
        case 3.0...4.0: return "Loose"
        default: return "Very Loose"
        }
    }
    
    private func saveAPIKey() {
        appState.saveAPIKey(apiKeyInput)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saved = false
        }
    }
}
