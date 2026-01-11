import Foundation

// MARK: - Enums

public enum ItemCondition: String, Codable, CaseIterable, Sendable {
    case new = "new"
    case likeNew = "likeNew"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    public var displayName: String {
        switch self {
        case .new: return "New"
        case .likeNew: return "Like New"
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }
}

public enum ItemStatus: String, Codable, Sendable {
    case draft
    case readyToList
    case listed
    case sold
    case donated
}

// MARK: - Photo Model

public struct Photo: Identifiable, Codable, Sendable {
    public let id: String
    public var itemId: String
    public var imageData: Data?
    public var isPrimary: Bool
    public var sortOrder: Int
    
    public init(id: String = UUID().uuidString, itemId: String = "", imageData: Data? = nil, isPrimary: Bool = false, sortOrder: Int = 0) {
        self.id = id
        self.itemId = itemId
        self.imageData = imageData
        self.isPrimary = isPrimary
        self.sortOrder = sortOrder
    }
}

// MARK: - Item Model

public struct Item: Identifiable, Codable, Sendable {
    public let id: String
    public var name: String
    public var description: String
    public var category: String
    public var condition: ItemCondition
    public var estimatedValue: Double
    public var confidenceScore: Double
    public var aiInsights: String
    public var isVerified: Bool
    public var status: ItemStatus
    public var photos: [Photo]
    public var createdAt: Date
    public var updatedAt: Date
    
    // Computed property for compatibility
    public var dateAdded: Date { createdAt }
    
    public init(
        id: String = UUID().uuidString,
        name: String = "",
        description: String = "",
        category: String = "Other",
        condition: ItemCondition = .good,
        estimatedValue: Double = 0,
        confidenceScore: Double = 0,
        aiInsights: String = "",
        isVerified: Bool = false,
        status: ItemStatus = .draft,
        photos: [Photo] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.condition = condition
        self.estimatedValue = estimatedValue
        self.confidenceScore = confidenceScore
        self.aiInsights = aiInsights
        self.isVerified = isVerified
        self.status = status
        self.photos = photos
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Donation Model

public struct Donation: Identifiable, Codable, Sendable {
    public let id: String
    public var itemId: String
    public var charityId: String
    public var charityName: String
    public var donationDate: Date
    public var donationValue: Double
    public var acquisitionDate: Date?
    public var acquisitionMethod: String?
    public var acquisitionCost: Double?
    public var requiresAppraisal: Bool
    
    public init(
        id: String = UUID().uuidString,
        itemId: String,
        charityId: String,
        charityName: String,
        donationDate: Date = Date(),
        donationValue: Double,
        acquisitionDate: Date? = nil,
        acquisitionMethod: String? = nil,
        acquisitionCost: Double? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.charityId = charityId
        self.charityName = charityName
        self.donationDate = donationDate
        self.donationValue = donationValue
        self.acquisitionDate = acquisitionDate
        self.acquisitionMethod = acquisitionMethod
        self.acquisitionCost = acquisitionCost
        self.requiresAppraisal = donationValue > 5000
    }
}

// MARK: - AI Analysis Result

public struct AIAnalysisResult: Codable, Sendable {
    public var name: String
    public var category: String
    public var condition: ItemCondition
    public var estimatedValue: Double
    public var confidenceScore: Double
    public var description: String
    public var insights: String
    
    public init(name: String, category: String, condition: ItemCondition, estimatedValue: Double, confidenceScore: Double, description: String, insights: String) {
        self.name = name
        self.category = category
        self.condition = condition
        self.estimatedValue = estimatedValue
        self.confidenceScore = confidenceScore
        self.description = description
        self.insights = insights
    }
}
