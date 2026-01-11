import SwiftUI
import Combine

// MARK: - App State

@MainActor
public class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published public var items: [Item] = []
    @Published public var currentItem: Item?
    @Published public var capturedPhotos: [Photo] = []
    @Published public var isAnalyzing: Bool = false
    @Published public var analysisError: String?
    @Published public var apiKey: String = ""
    
    private let userDefaultsAPIKeyKey = "openai_api_key"
    
    private init() {
        loadAPIKey()
    }
    
    // MARK: - API Key Management
    
    public func loadAPIKey() {
        if let key = UserDefaults.standard.string(forKey: userDefaultsAPIKeyKey) {
            apiKey = key
            Task {
                await AIService.shared.setAPIKey(key)
            }
        }
    }
    
    public func saveAPIKey(_ key: String) {
        apiKey = key
        UserDefaults.standard.set(key, forKey: userDefaultsAPIKeyKey)
        Task {
            await AIService.shared.setAPIKey(key)
        }
    }
    
    // MARK: - Photo Management
    
    public func addPhoto(_ imageData: Data) {
        let photo = Photo(
            id: UUID().uuidString,
            itemId: currentItem?.id ?? "",
            imageData: imageData,
            isPrimary: capturedPhotos.isEmpty,
            sortOrder: capturedPhotos.count
        )
        capturedPhotos.append(photo)
    }
    
    public func removePhoto(at index: Int) {
        guard index < capturedPhotos.count else { return }
        capturedPhotos.remove(at: index)
        // Update primary if needed
        if !capturedPhotos.isEmpty && !capturedPhotos.contains(where: { $0.isPrimary }) {
            setPrimaryPhoto(at: 0)
        }
    }
    
    public func setPrimaryPhoto(at index: Int) {
        guard index < capturedPhotos.count else { return }
        for i in 0..<capturedPhotos.count {
            capturedPhotos[i] = Photo(
                id: capturedPhotos[i].id,
                itemId: capturedPhotos[i].itemId,
                imageData: capturedPhotos[i].imageData,
                isPrimary: i == index,
                sortOrder: capturedPhotos[i].sortOrder
            )
        }
    }
    
    public func clearPhotos() {
        capturedPhotos = []
    }
    
    // MARK: - AI Analysis
    
    public func analyzePhotos() async throws -> AIAnalysisResult {
        guard let firstPhoto = capturedPhotos.first,
              let imageData = firstPhoto.imageData else {
            throw AIServiceError.invalidResponse
        }
        
        isAnalyzing = true
        analysisError = nil
        
        defer { isAnalyzing = false }
        
        do {
            let result = try await AIService.shared.analyzeImage(imageData)
            return result
        } catch {
            analysisError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Item Management
    
    public func createItem(from analysis: AIAnalysisResult) -> Item {
        let item = Item(
            name: analysis.name,
            description: analysis.description,
            category: analysis.category,
            condition: analysis.condition,
            estimatedValue: analysis.estimatedValue,
            confidenceScore: analysis.confidenceScore,
            aiInsights: analysis.insights,
            photos: capturedPhotos
        )
        currentItem = item
        return item
    }
    
    public func saveItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        currentItem = nil
        clearPhotos()
    }
    
    public func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
    
    // MARK: - Export Helpers
    
    public func generateListingText(for item: Item, platforms: [MarketplacePlatform]) -> String {
        let platformNames = platforms.map { $0.displayName }.joined(separator: ", ")
        
        return """
        📦 \(item.name)
        
        💰 $\(String(format: "%.0f", item.estimatedValue))
        
        📋 \(item.description)
        
        ✨ Condition: \(item.condition.displayName)
        🏷️ Category: \(item.category)
        
        ---
        Listing for: \(platformNames)
        """
    }
    
    public func generateDonationReceipt(for item: Item, charity: CharityOrganization) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        return """
        ═══════════════════════════════════
        DONATION RECEIPT
        For Tax Purposes
        ═══════════════════════════════════
        
        DATE: \(dateFormatter.string(from: Date()))
        
        DONOR INFORMATION:
        [Your Name]
        [Your Address]
        
        CHARITY INFORMATION:
        \(charity.name)
        EIN: \(charity.ein.isEmpty ? "Contact charity for EIN" : charity.ein)
        \(charity.phoneNumber.isEmpty ? "" : "Phone: \(charity.phoneNumber)")
        \(charity.website.isEmpty ? "" : "Website: \(charity.website)")
        
        ITEM DONATED:
        \(item.name)
        Category: \(item.category)
        Condition: \(item.condition.displayName)
        
        FAIR MARKET VALUE: $\(String(format: "%.2f", item.estimatedValue))
        
        \(item.estimatedValue > 5000 ? "⚠️ Items over $5,000 require qualified appraisal" : "")
        
        ═══════════════════════════════════
        Keep this receipt for your tax records.
        Consult a tax professional for deduction eligibility.
        ═══════════════════════════════════
        """
    }
    
    // MARK: - Mock Data (For Simulator Testing)
    
    public func loadMockData() {
        let mockPhotoData = createMockImageData(color: .systemBlue)
        
        let mockItems: [Item] = [
            Item(
                name: "Vintage Leather Jacket",
                description: "Classic brown leather motorcycle jacket from the 1980s. Genuine leather with quilted lining.",
                category: "Clothing",
                condition: .good,
                estimatedValue: 85,
                confidenceScore: 0.82,
                aiInsights: "Vintage leather jackets are highly sought after.",
                photos: [Photo(imageData: mockPhotoData, isPrimary: true, sortOrder: 0)]
            ),
            Item(
                name: "Sony WH-1000XM4 Headphones",
                description: "Premium wireless noise-canceling headphones. Includes case and cables.",
                category: "Electronics",
                condition: .excellent,
                estimatedValue: 175,
                confidenceScore: 0.91,
                aiInsights: "High-demand electronics item.",
                photos: [Photo(imageData: createMockImageData(color: .black), isPrimary: true, sortOrder: 0)]
            )
        ]
        
        items = mockItems
        capturedPhotos = [Photo(imageData: mockPhotoData, isPrimary: true, sortOrder: 0)]
    }
    
    private func createMockImageData(color: UIColor) -> Data {
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let text = "Mock Image"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attrs)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attrs)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.jpegData(compressionQuality: 0.8) ?? Data()
    }
    
    public func getMockAnalysisResult() -> AIAnalysisResult {
        AIAnalysisResult(
            name: "Test Item - Mock Analysis",
            category: "Electronics",
            condition: .good,
            estimatedValue: 75,
            confidenceScore: 0.85,
            description: "Mock analysis result for simulator testing.",
            insights: "Mock insight: This item would sell well on Facebook Marketplace."
        )
    }
}
