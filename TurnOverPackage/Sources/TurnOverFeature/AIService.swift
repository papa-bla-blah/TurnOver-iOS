import Foundation
import UIKit

// MARK: - AI Service

public actor AIService {
    public static let shared = AIService()
    
    private var apiKey: String?
    private let timeoutSeconds: TimeInterval = 10
    private let maxRetries = 2
    
    private init() {}
    
    public func setAPIKey(_ key: String) {
        self.apiKey = key
    }
    
    public func getAPIKey() -> String? {
        return apiKey
    }
    
    public func analyzeImage(_ imageData: Data) async throws -> AIAnalysisResult {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIServiceError.apiKeyNotConfigured
        }
        
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await performAnalysis(imageData: imageData, apiKey: apiKey)
            } catch {
                lastError = error
                if attempt < maxRetries - 1 {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                }
            }
        }
        
        throw lastError ?? AIServiceError.unknownError
    }
    
    private func performAnalysis(imageData: Data, apiKey: String) async throws -> AIAnalysisResult {
        let base64 = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this item and return ONLY valid JSON in this exact format:
        {
          "name": "brief item name (max 50 chars)",
          "category": "one of: Furniture, Electronics, Clothing, Books, Home & Garden, Toys & Games, Sports & Outdoors, Tools, Other",
          "condition": "one of: new, likeNew, excellent, good, fair, poor",
          "estimatedValue": 25.00,
          "confidenceScore": 0.85,
          "description": "detailed description for marketplace listings (100-200 words)",
          "insights": "brief analysis of value and condition (50 words max)"
        }
        Use realistic resale values (not retail). Be conservative with estimates.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = timeoutSeconds
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw AIServiceError.invalidAPIKey
        case 429:
            throw AIServiceError.rateLimitExceeded
        default:
            throw AIServiceError.apiError(statusCode: httpResponse.statusCode)
        }
        
        return try parseResponse(data)
    }
    
    private func parseResponse(_ data: Data) throws -> AIAnalysisResult {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIServiceError.invalidResponseFormat
        }
        
        // Extract JSON from response
        guard let jsonStart = content.firstIndex(of: "{"),
              let jsonEnd = content.lastIndex(of: "}") else {
            throw AIServiceError.invalidResponseFormat
        }
        
        let jsonString = String(content[jsonStart...jsonEnd])
        guard let jsonData = jsonString.data(using: .utf8),
              let result = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.invalidResponseFormat
        }
        
        guard let name = result["name"] as? String,
              let category = result["category"] as? String,
              let conditionStr = result["condition"] as? String else {
            throw AIServiceError.incompleteResponse
        }
        
        let condition = ItemCondition(rawValue: conditionStr) ?? .good
        let estimatedValue = (result["estimatedValue"] as? Double) ?? 0
        let confidenceScore = (result["confidenceScore"] as? Double) ?? 0.5
        let description = (result["description"] as? String) ?? ""
        let insights = (result["insights"] as? String) ?? ""
        
        return AIAnalysisResult(
            name: name,
            category: category,
            condition: condition,
            estimatedValue: estimatedValue,
            confidenceScore: confidenceScore,
            description: description,
            insights: insights
        )
    }
    
    public func getMockAnalysis() -> AIAnalysisResult {
        AIAnalysisResult(
            name: "Vintage Chair",
            category: "Furniture",
            condition: .good,
            estimatedValue: 45,
            confidenceScore: 0.75,
            description: "Classic wooden chair with minor wear. Sturdy construction. Good for dining or accent piece.",
            insights: "Comparable items sell for $40-60. Condition affects value. Local pickup recommended."
        )
    }
}

// MARK: - AI Service Errors

public enum AIServiceError: LocalizedError {
    case apiKeyNotConfigured
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case rateLimitExceeded
    case apiError(statusCode: Int)
    case invalidResponseFormat
    case incompleteResponse
    case networkError
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "API key not configured. Please add your OpenAI API key in Settings."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again in a moment."
        case .apiError(let code):
            return "API error: \(code)"
        case .invalidResponseFormat:
            return "Invalid AI response format."
        case .incompleteResponse:
            return "Incomplete AI response."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
