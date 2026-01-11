import SwiftUI
import Combine

// MARK: - User Preferences (Persistent Settings)

@MainActor
public class UserPreferences: ObservableObject {
    public static let shared = UserPreferences()
    
    // MARK: - Keys
    private enum Keys {
        static let levelLockEnabled = "pref_level_lock_enabled"
        static let levelLockSensitivity = "pref_level_lock_sensitivity"
        static let hapticFeedbackEnabled = "pref_haptic_feedback"
        static let autoSavePhotos = "pref_auto_save_photos"
        static let preferredExportFormat = "pref_export_format"
        static let lastUsedCharityId = "pref_last_charity_id"
        static let lastUsedPlatforms = "pref_last_platforms"
        static let showAnalysisInsights = "pref_show_insights"
        static let compressionQuality = "pref_compression_quality"
        static let onboardingCompleted = "pref_onboarding_done"
        static let premiumUnlocked = "pref_premium_unlocked"
        static let adsRemoved = "pref_ads_removed"
    }
    
    // MARK: - Published Properties
    
    /// Level Lock Camera (Optional Feature)
    @Published public var levelLockEnabled: Bool {
        didSet { UserDefaults.standard.set(levelLockEnabled, forKey: Keys.levelLockEnabled) }
    }
    
    /// Sensitivity for level lock (0.5 = tight, 5.0 = loose)
    @Published public var levelLockSensitivity: Double {
        didSet { UserDefaults.standard.set(levelLockSensitivity, forKey: Keys.levelLockSensitivity) }
    }
    
    /// Haptic feedback on actions
    @Published public var hapticFeedbackEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedbackEnabled) }
    }
    
    /// Auto-save photos to library
    @Published public var autoSavePhotos: Bool {
        didSet { UserDefaults.standard.set(autoSavePhotos, forKey: Keys.autoSavePhotos) }
    }
    
    /// Preferred export format (text, pdf, share)
    @Published public var preferredExportFormat: String {
        didSet { UserDefaults.standard.set(preferredExportFormat, forKey: Keys.preferredExportFormat) }
    }
    
    /// Remember last used charity
    @Published public var lastUsedCharityId: String? {
        didSet { UserDefaults.standard.set(lastUsedCharityId, forKey: Keys.lastUsedCharityId) }
    }
    
    /// Remember last used platforms
    @Published public var lastUsedPlatforms: [String] {
        didSet { UserDefaults.standard.set(lastUsedPlatforms, forKey: Keys.lastUsedPlatforms) }
    }
    
    /// Show AI insights panel
    @Published public var showAnalysisInsights: Bool {
        didSet { UserDefaults.standard.set(showAnalysisInsights, forKey: Keys.showAnalysisInsights) }
    }
    
    /// Photo compression quality (0.5 - 1.0)
    @Published public var compressionQuality: Double {
        didSet { UserDefaults.standard.set(compressionQuality, forKey: Keys.compressionQuality) }
    }
    
    /// Onboarding completed
    @Published public var onboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(onboardingCompleted, forKey: Keys.onboardingCompleted) }
    }
    
    // MARK: - Monetization State
    
    @Published public var premiumUnlocked: Bool {
        didSet { UserDefaults.standard.set(premiumUnlocked, forKey: Keys.premiumUnlocked) }
    }
    
    @Published public var adsRemoved: Bool {
        didSet { UserDefaults.standard.set(adsRemoved, forKey: Keys.adsRemoved) }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved preferences with defaults
        let defaults = UserDefaults.standard
        
        self.levelLockEnabled = defaults.object(forKey: Keys.levelLockEnabled) as? Bool ?? false
        self.levelLockSensitivity = defaults.object(forKey: Keys.levelLockSensitivity) as? Double ?? 2.0
        self.hapticFeedbackEnabled = defaults.object(forKey: Keys.hapticFeedbackEnabled) as? Bool ?? true
        self.autoSavePhotos = defaults.object(forKey: Keys.autoSavePhotos) as? Bool ?? false
        self.preferredExportFormat = defaults.string(forKey: Keys.preferredExportFormat) ?? "share"
        self.lastUsedCharityId = defaults.string(forKey: Keys.lastUsedCharityId)
        self.lastUsedPlatforms = defaults.stringArray(forKey: Keys.lastUsedPlatforms) ?? []
        self.showAnalysisInsights = defaults.object(forKey: Keys.showAnalysisInsights) as? Bool ?? true
        self.compressionQuality = defaults.object(forKey: Keys.compressionQuality) as? Double ?? 0.8
        self.onboardingCompleted = defaults.bool(forKey: Keys.onboardingCompleted)
        self.premiumUnlocked = defaults.bool(forKey: Keys.premiumUnlocked)
        self.adsRemoved = defaults.bool(forKey: Keys.adsRemoved)
    }
    
    // MARK: - Helpers
    
    public func resetToDefaults() {
        levelLockEnabled = false
        levelLockSensitivity = 2.0
        hapticFeedbackEnabled = true
        autoSavePhotos = false
        preferredExportFormat = "share"
        lastUsedCharityId = nil
        lastUsedPlatforms = []
        showAnalysisInsights = true
        compressionQuality = 0.8
    }
    
    public func rememberPlatforms(_ platforms: [MarketplacePlatform]) {
        lastUsedPlatforms = platforms.map { $0.rawValue }
    }
    
    public func getRememberedPlatforms() -> [MarketplacePlatform] {
        lastUsedPlatforms.compactMap { MarketplacePlatform(rawValue: $0) }
    }
}

// MARK: - Haptic Feedback Helper (MainActor)

@MainActor
public struct HapticManager {
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard UserPreferences.shared.hapticFeedbackEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserPreferences.shared.hapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    public static func selection() {
        guard UserPreferences.shared.hapticFeedbackEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
