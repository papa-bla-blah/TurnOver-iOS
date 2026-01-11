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

public enum MarketplacePlatform: String, Codable, CaseIterable, Identifiable, Sendable {
    case craigslist
    case facebook
    case nextdoor
    case offerUp
    case poshmark
    case mercari
    case etsy
    case whatnot
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .craigslist: return "Craigslist"
        case .facebook: return "Facebook Marketplace"
        case .nextdoor: return "Nextdoor"
        case .offerUp: return "OfferUp"
        case .poshmark: return "Poshmark"
        case .mercari: return "Mercari"
        case .etsy: return "Etsy"
        case .whatnot: return "Whatnot"
        }
    }
    
    public var icon: String {
        switch self {
        case .craigslist: return "list.bullet"
        case .facebook: return "person.2"
        case .nextdoor: return "house"
        case .offerUp: return "tag"
        case .poshmark: return "bag"
        case .mercari: return "cart"
        case .etsy: return "paintbrush"
        case .whatnot: return "video"
        }
    }
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
    public var selectedPlatforms: [MarketplacePlatform]
    public var createdAt: Date
    public var updatedAt: Date
    
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
        selectedPlatforms: [MarketplacePlatform] = [],
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
        self.selectedPlatforms = selectedPlatforms
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Charity Model

public struct CharityOrganization: Identifiable, Codable, Sendable {
    public let id: String
    public var name: String
    public var ein: String
    public var phoneNumber: String
    public var website: String
    
    public init(id: String = UUID().uuidString, name: String, ein: String, phoneNumber: String = "", website: String = "") {
        self.id = id
        self.name = name
        self.ein = ein
        self.phoneNumber = phoneNumber
        self.website = website
    }
    
    nonisolated(unsafe) public static let defaultCharities: [CharityOrganization] = [
        CharityOrganization(name: "Goodwill Industries", ein: "53-0196517", phoneNumber: "1-800-466-3945", website: "goodwill.org"),
        CharityOrganization(name: "Salvation Army", ein: "58-0660607", phoneNumber: "1-800-728-7825", website: "salvationarmyusa.org"),
        CharityOrganization(name: "Habitat for Humanity", ein: "91-1914868", phoneNumber: "1-800-422-4828", website: "habitat.org"),
        CharityOrganization(name: "Vietnam Veterans of America", ein: "23-7363034", phoneNumber: "1-800-882-1316", website: "vva.org"),
        CharityOrganization(name: "Local Church/Shelter", ein: "", phoneNumber: "", website: "")
    ]
}

// MARK: - Donation Model

public struct Donation: Identifiable, Codable, Sendable {
    public let id: String
    public var itemId: String
    public var charity: CharityOrganization
    public var donationDate: Date
    public var donationValue: Double
    public var acquisitionDate: Date?
    public var acquisitionMethod: String?
    public var acquisitionCost: Double?
    public var requiresAppraisal: Bool
    
    public init(
        id: String = UUID().uuidString,
        itemId: String,
        charity: CharityOrganization,
        donationDate: Date = Date(),
        donationValue: Double,
        acquisitionDate: Date? = nil,
        acquisitionMethod: String? = nil,
        acquisitionCost: Double? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.charity = charity
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
