import SwiftUI

// MARK: - Charity Selection View

public struct CharitySelectionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    let analysisResult: AIAnalysisResult
    
    @State private var selectedCharity: CharityOrganization?
    @State private var showExport = false
    @State private var searchText = ""
    
    private var filteredCharities: [CharityOrganization] {
        if searchText.isEmpty {
            return CharityOrganization.commonCharities
        }
        return CharityOrganization.commonCharities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public init(analysisResult: AIAnalysisResult) {
        self.analysisResult = analysisResult
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textSecondary)
                    TextField("Search charities...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(AppTheme.secondaryBackground)
                .cornerRadius(AppTheme.radiusSM)
                .padding()
                
                // Charity List
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingMD) {
                        ForEach(filteredCharities) { charity in
                            CharityCard(
                                charity: charity,
                                isSelected: selectedCharity?.id == charity.id,
                                onTap: {
                                    HapticManager.selection()
                                    selectedCharity = charity
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Continue Button
                VStack(spacing: AppTheme.spacingSM) {
                    if let charity = selectedCharity {
                        Text("Selected: \(charity.name)")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Button(action: {
                        HapticManager.impact()
                        // Remember selection
                        if let charity = selectedCharity {
                            preferences.lastUsedCharityId = charity.id
                        }
                        showExport = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Create Receipt")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedCharity == nil)
                }
                .padding()
                .background(AppTheme.surface)
            }
            .navigationTitle("Donate")
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
                // Load last used charity
                if let lastId = preferences.lastUsedCharityId,
                   let charity = CharityOrganization.commonCharities.first(where: { $0.id == lastId }) {
                    selectedCharity = charity
                }
            }
            .fullScreenCover(isPresented: $showExport) {
                if let charity = selectedCharity {
                    ExportDonationView(
                        analysisResult: analysisResult,
                        charity: charity
                    )
                    .environmentObject(appState)
                    .environmentObject(preferences)
                }
            }
        }
    }
}

// MARK: - Charity Card

struct CharityCard: View {
    let charity: CharityOrganization
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: charity.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppTheme.primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? AppTheme.primary : AppTheme.secondaryBackground)
                    .cornerRadius(AppTheme.radiusSM)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(charity.name)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(charity.category)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                }
            }
            .padding()
            .background(isSelected ? AppTheme.primary.opacity(0.1) : AppTheme.surface)
            .cornerRadius(AppTheme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(isSelected ? AppTheme.primary : AppTheme.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(charity.name), \(charity.category), \(isSelected ? "selected" : "not selected")")
    }
}

// MARK: - Charity Organization

public struct CharityOrganization: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let category: String
    public let ein: String
    public let phoneNumber: String
    public let website: String
    public let icon: String
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        category: String,
        ein: String = "",
        phoneNumber: String = "",
        website: String = "",
        icon: String = "heart.fill"
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.ein = ein
        self.phoneNumber = phoneNumber
        self.website = website
        self.icon = icon
    }
    
    public static let commonCharities: [CharityOrganization] = [
        CharityOrganization(
            id: "goodwill",
            name: "Goodwill Industries",
            category: "Thrift & Employment",
            ein: "53-0196517",
            website: "goodwill.org",
            icon: "briefcase.fill"
        ),
        CharityOrganization(
            id: "salvation-army",
            name: "Salvation Army",
            category: "Human Services",
            ein: "58-0660607",
            website: "salvationarmyusa.org",
            icon: "shield.fill"
        ),
        CharityOrganization(
            id: "habitat",
            name: "Habitat for Humanity",
            category: "Housing",
            ein: "91-1914868",
            website: "habitat.org",
            icon: "house.fill"
        ),
        CharityOrganization(
            id: "red-cross",
            name: "American Red Cross",
            category: "Disaster Relief",
            ein: "53-0196605",
            website: "redcross.org",
            icon: "cross.fill"
        ),
        CharityOrganization(
            id: "vietnam-vets",
            name: "Vietnam Veterans of America",
            category: "Veterans",
            ein: "52-1149668",
            website: "vva.org",
            icon: "star.fill"
        ),
        CharityOrganization(
            id: "amvets",
            name: "AMVETS",
            category: "Veterans",
            ein: "54-0802270",
            website: "amvets.org",
            icon: "flag.fill"
        ),
        CharityOrganization(
            id: "big-brothers",
            name: "Big Brothers Big Sisters",
            category: "Youth Mentoring",
            ein: "23-1271730",
            website: "bbbs.org",
            icon: "person.2.fill"
        ),
        CharityOrganization(
            id: "local",
            name: "Local Charity",
            category: "Community",
            ein: "",
            website: "",
            icon: "mappin.circle.fill"
        )
    ]
}
