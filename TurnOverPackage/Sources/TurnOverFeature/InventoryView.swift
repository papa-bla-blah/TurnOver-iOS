import SwiftUI

// MARK: - Inventory View (HIG Compliant)

public struct InventoryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateNewest
    @State private var showSortOptions = false
    
    private var filteredItems: [Item] {
        var items = appState.items
        
        // Filter
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortOption {
        case .dateNewest:
            items.sort { $0.dateAdded > $1.dateAdded }
        case .dateOldest:
            items.sort { $0.dateAdded < $1.dateAdded }
        case .valueHighest:
            items.sort { $0.estimatedValue > $1.estimatedValue }
        case .valueLowest:
            items.sort { $0.estimatedValue < $1.estimatedValue }
        case .nameAZ:
            items.sort { $0.name < $1.name }
        }
        
        return items
    }
    
    private var totalValue: Double {
        appState.items.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if appState.items.isEmpty {
                // Empty State
                EmptyInventoryView()
            } else {
                // Summary Header
                InventorySummaryHeader(
                    itemCount: appState.items.count,
                    totalValue: totalValue
                )
                
                // Search and Sort
                HStack {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textSecondary)
                        TextField("Search items...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(AppTheme.spacingSM)
                    .background(AppTheme.secondaryBackground)
                    .cornerRadius(AppTheme.radiusSM)
                    
                    // Sort Button
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                HapticManager.selection()
                                sortOption = option
                            }) {
                                HStack {
                                    Text(option.displayName)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                    .accessibilityLabel("Sort options")
                }
                .padding()
                
                // Item List
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingMD) {
                        ForEach(filteredItems) { item in
                            InventoryItemCard(item: item)
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        HapticManager.notification(.warning)
                                        appState.deleteItem(item)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, AppTheme.spacingXL)
                }
            }
        }
        .navigationTitle("Inventory")
    }
}

// MARK: - Empty Inventory View

struct EmptyInventoryView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textTertiary)
            
            Text("No Items Yet")
                .font(.title2.bold())
            
            Text("Items you save will appear here.\nStart by capturing a photo of something to sell or donate.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingXL)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Inventory Summary Header

struct InventorySummaryHeader: View {
    let itemCount: Int
    let totalValue: Double
    
    var body: some View {
        HStack(spacing: AppTheme.spacingLG) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(itemCount)")
                    .font(.title.bold())
                Text("Items")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("$\(String(format: "%.0f", totalValue))")
                    .font(.title.bold())
                    .foregroundColor(AppTheme.success)
                Text("Total Value")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(itemCount) items, total value $\(Int(totalValue))")
    }
}

// MARK: - Inventory Item Card

struct InventoryItemCard: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            // Thumbnail
            if let photo = item.photos.first,
               let data = photo.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
            } else {
                RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                    .fill(AppTheme.secondaryBackground)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("•")
                        .foregroundColor(AppTheme.textTertiary)
                    Text(item.condition.displayName)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Text(item.dateAdded, style: .date)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            Spacer()
            
            // Value
            Text("$\(String(format: "%.0f", item.estimatedValue))")
                .font(.headline)
                .foregroundColor(AppTheme.success)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.radiusMD)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name), \(item.category), $\(Int(item.estimatedValue))")
    }
}

// MARK: - Sort Option

enum SortOption: CaseIterable {
    case dateNewest
    case dateOldest
    case valueHighest
    case valueLowest
    case nameAZ
    
    var displayName: String {
        switch self {
        case .dateNewest: return "Newest First"
        case .dateOldest: return "Oldest First"
        case .valueHighest: return "Highest Value"
        case .valueLowest: return "Lowest Value"
        case .nameAZ: return "Name (A-Z)"
        }
    }
}
