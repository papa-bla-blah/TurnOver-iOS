import SwiftUI

// MARK: - Inventory View

public struct InventoryView: View {
    @EnvironmentObject var appState: AppState
    
    public var body: some View {
        Group {
            if appState.items.isEmpty {
                // Empty state
                VStack(spacing: AppTheme.spacingMD) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    
                    Text("No items yet")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Capture your first item to get started")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(appState.items) { item in
                        InventoryRow(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Inventory")
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            appState.deleteItem(appState.items[index])
        }
    }
}

// MARK: - Inventory Row

struct InventoryRow: View {
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
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
            } else {
                RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                    .fill(AppTheme.background)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.textSecondary)
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("•")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(item.condition.displayName)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                StatusBadge(status: item.status)
            }
            
            Spacer()
            
            // Value
            Text("$\(String(format: "%.0f", item.estimatedValue))")
                .font(.headline)
                .foregroundColor(AppTheme.success)
        }
        .padding(.vertical, AppTheme.spacingSM)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: ItemStatus
    
    private var color: Color {
        switch status {
        case .draft: return AppTheme.textSecondary
        case .readyToList: return AppTheme.accent
        case .listed: return AppTheme.primary
        case .sold: return AppTheme.success
        case .donated: return AppTheme.secondary
        }
    }
    
    private var text: String {
        switch status {
        case .draft: return "Draft"
        case .readyToList: return "Ready to List"
        case .listed: return "Listed"
        case .sold: return "Sold"
        case .donated: return "Donated"
        }
    }
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}
