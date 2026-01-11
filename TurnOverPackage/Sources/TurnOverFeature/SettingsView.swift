import SwiftUI

// MARK: - Settings View

public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKeyInput: String = ""
    @State private var showAPIKey = false
    @State private var saved = false
    
    public var body: some View {
        Form {
            // API Key Section
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("OpenAI API Key")
                        .font(.headline)
                    
                    Text("Required for AI image analysis")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    HStack {
                        if showAPIKey {
                            TextField("sk-...", text: $apiKeyInput)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("sk-...", text: $apiKeyInput)
                                .textContentType(.password)
                        }
                        
                        Button(action: { showAPIKey.toggle() }) {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .background(AppTheme.background)
                    .cornerRadius(AppTheme.radiusSM)
                    
                    Button(action: saveAPIKey) {
                        HStack {
                            Image(systemName: saved ? "checkmark" : "square.and.arrow.down")
                            Text(saved ? "Saved!" : "Save API Key")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(apiKeyInput.isEmpty)
                }
            } header: {
                Text("AI Configuration")
            } footer: {
                Text("Get your API key from platform.openai.com")
            }
            
            // About Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack {
                    Text("AI Model")
                    Spacer()
                    Text("GPT-4o Mini")
                        .foregroundColor(AppTheme.textSecondary)
                }
            } header: {
                Text("About")
            }
            
            // Help Section
            Section {
                Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                    HStack {
                        Image(systemName: "key")
                            .foregroundColor(AppTheme.primary)
                        Text("Get OpenAI API Key")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Link(destination: URL(string: "https://www.irs.gov/charities-non-profits/charitable-organizations/charitable-contribution-deductions")!) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppTheme.primary)
                        Text("IRS Donation Guidelines")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            } header: {
                Text("Help & Resources")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            apiKeyInput = appState.apiKey
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
