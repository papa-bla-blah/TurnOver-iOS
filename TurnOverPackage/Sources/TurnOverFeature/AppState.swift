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
        if capturedPhotos.isEmpty == false && !capturedPhotos.contains(where: { $0.isPrimary }) {
            capturedPhotos[0] = Photo(
                id: capturedPhotos[0].id,
                itemId: capturedPhotos[0].itemId,
                imageData: capturedPhotos[0].imageData,
                isPrimary: true,
                sortOrder: 0
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
        // Create mock photo data (simple colored rectangle)
        let mockPhotoData = createMockImageData(color: .systemBlue)
        
        // Mock items for testing
        let mockItems: [Item] = [
            Item(
                name: "Vintage Leather Jacket",
                description: "Classic brown leather motorcycle jacket from the 1980s. Genuine leather with quilted lining. Minor wear on cuffs adds character. Size Large, fits true to size. Perfect for collectors or everyday wear.",
                category: "Clothing",
                condition: .good,
                estimatedValue: 85,
                confidenceScore: 0.82,
                aiInsights: "Vintage leather jackets are highly sought after. This style sells well on Poshmark and eBay. Consider highlighting the era and authenticity.",
                photos: [Photo(imageData: mockPhotoData, isPrimary: true, sortOrder: 0)]
            ),
            Item(
                name: "Sony WH-1000XM4 Headphones",
                description: "Premium wireless noise-canceling headphones. Includes original case, charging cable, and audio cable. Excellent battery life, comfortable for long use. Minor cosmetic wear on headband.",
                category: "Electronics",
                condition: .excellent,
                estimatedValue: 175,
                confidenceScore: 0.91,
                aiInsights: "High-demand electronics item. Price competitively - these sell quickly on OfferUp and Facebook Marketplace. Include all accessories in photos.",
                photos: [Photo(imageData: createMockImageData(color: .black), isPrimary: true, sortOrder: 0)]
            ),
            Item(
                name: "Mid-Century Modern Chair",
                description: "Authentic Danish-style lounge chair circa 1960s. Walnut frame with original upholstery. Some wear on armrests. Structurally sound and very comfortable.",
                category: "Furniture",
                condition: .good,
                estimatedValue: 350,
                confidenceScore: 0.76,
                aiInsights: "Mid-century furniture commands premium prices. Local pickup recommended due to shipping costs. Etsy and Craigslist are good platforms for furniture.",
                photos: [Photo(imageData: createMockImageData(color: .brown), isPrimary: true, sortOrder: 0)]
            ),
            Item(
                name: "Collection of Classic Novels",
                description: "Set of 12 hardcover classic novels including Hemingway, Fitzgerald, and Steinbeck. Vintage editions from 1950s-1970s. Dust jackets intact with minor wear.",
                category: "Books",
                condition: .fair,
                estimatedValue: 45,
                confidenceScore: 0.68,
                aiInsights: "Book collections sell better as sets. Consider bundling or selling individually for rare editions. Good for donation if quick sale is priority.",
                photos: [Photo(imageData: createMockImageData(color: .systemGreen), isPrimary: true, sortOrder: 0)]
            )
        ]
        
        items = mockItems
        
        // Also add a mock photo to captured photos for testing analysis flow
        capturedPhotos = [Photo(imageData: mockPhotoData, isPrimary: true, sortOrder: 0)]
    }
    
    private func createMockImageData(color: UIColor) -> Data {
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        
        // Fill background
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Add placeholder text
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
            description: "This is a mock analysis result for simulator testing. In production, this would contain AI-generated content describing the photographed item in detail for marketplace listings.",
            insights: "Mock insight: This item would sell well on Facebook Marketplace or OfferUp. Price competitively for quick sale."
        )
    }
}
