# TurnOver iOS

AI-powered app to help you decide whether to sell or donate household items.

## Status

| Branch | Purpose | Build |
|--------|---------|-------|
| `ios-free-release` | Free version - No ads | ✅ Ready |
| `ios-monetized-ads-storekit` | Paid version - Ads + StoreKit 2 IAP | ✅ Ready |

**Bundle ID**: `com.ogsaas.turnover`  
**Minimum iOS**: 16.0  
**Swift**: 6.1  

## Features

### Core Features (All Versions)
- 📷 **Multi-Photo Capture** - Take 1-10 photos per item
- 🤖 **AI Analysis** - GPT-4o Mini powered valuation
- 💰 **Sell Flow** - Export listings to 8 marketplaces
- 🎁 **Donate Flow** - IRS-compliant donation receipts
- 📦 **Inventory Management** - Track all your items
- ⚙️ **Persistent Settings** - Remembers your preferences

### iOS-Specific Features
- 📐 **Level Lock Camera** - Optional CoreMotion-based level indicator for straight photos
- 🎨 **HIG Compliant** - Dynamic Type, system colors, dark mode support
- 📳 **Haptic Feedback** - Tactile response on all actions
- 🔄 **Settings Persistence** - All preferences saved automatically

### Monetized Version Only
- 🚫 **Remove Ads** - One-time purchase
- ♾️ **Unlimited Analysis** - No daily limits
- ⭐ **Premium Support** - Priority assistance

## Supported Marketplaces

- eBay
- Facebook Marketplace
- Craigslist
- OfferUp
- Poshmark
- Mercari
- Nextdoor
- Etsy

## Supported Charities

- Goodwill
- Salvation Army
- Habitat for Humanity ReStore
- Local Food Bank
- Red Cross
- Custom charity entry

## Requirements

- iOS 16.0+
- Xcode 15.0+
- OpenAI API key (for AI analysis)
- Apple Developer Account (for device testing)

## Setup

1. Clone the repository
2. Open `TurnOver.xcworkspace` in Xcode
3. Select your development team
4. Build and run

## Project Structure

```
TurnOver-iOS/
├── TurnOver.xcworkspace
├── TurnOver/                    # Main app target
├── TurnOverPackage/             # Swift Package with features
│   └── Sources/TurnOverFeature/
│       ├── AIService.swift
│       ├── AnalysisView.swift
│       ├── AppState.swift
│       ├── CharitySelectionView.swift
│       ├── ContentView.swift
│       ├── DecisionView.swift
│       ├── ExportDonationView.swift
│       ├── ExportListingView.swift
│       ├── ImagePicker.swift
│       ├── InventoryView.swift
│       ├── LevelLockCameraView.swift
│       ├── MarketplaceSelectionView.swift
│       ├── Models.swift
│       ├── SettingsView.swift
│       ├── StoreManager.swift
│       ├── Theme.swift
│       └── UserPreferences.swift
└── README.md
```

## License

Proprietary - OG SaaS
