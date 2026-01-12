# Agent Memory – TurnOver

**Last Updated**: 2026-01-11 (Opus 4.5 session)  
**Next Backup Due**: 2026-01-14 (v1)

---

## 1. Project Overview

- **What**: AI-powered sell/donate decision app for household items
- **How**: User photographs item → OpenAI GPT-4o analyzes → Returns value estimate + sell/donate recommendation
- **Users**: People decluttering, selling items, making charitable donations
- **Non-goals**: Not a marketplace itself, not an auction platform

**Physical Resources**:
- iPhone 14 (Liam's device, UDID: D7C71A30-E03E-5A04-BBFC-F766BBECFEE7)
- M1 Mac 16GB RAM, macOS 26.2 (25C56)
- Backup schedule: Every 3 days with version notation (v1, v2, v3)

**Team**:
- Roger Grubb: Apple Developer Account holder (Team ID: Q3A9W7L832)
- Liam: Project owner, iPhone tester, Google Play account holder

---

## 2. GitHub Repository Structure

### TurnOver (Android - React Native/Expo)
- **Repository**: https://github.com/papa-bla-blah/TurnOver
- **Local Path**: N/A (Expo cloud builds)
- **Tech Stack**: React Native, Expo, TypeScript

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Default/development | ✅ Active |
| `android-free-release` | Free APK - No monetization | ✅ Ready |
| `android-monetized-ads-iap` | Paid APK - AdMob + Play Store IAP | 🔧 Needs IAP config |

**Working APK**: https://expo.dev/artifacts/eas/8bwcopSdASGCMFs84AdTob.apk

---

### TurnOver-iOS (Swift/SwiftUI)
- **Repository**: https://github.com/papa-bla-blah/TurnOver-iOS
- **Local Path**: /Users/celtic57/projects/TurnOverX/TurnOver-iOS/
- **Tech Stack**: Swift, SwiftUI, iOS 16+

| Branch | Purpose | Status | Last Commit |
|--------|---------|--------|-------------|
| `main` | Default/production ready | ✅ Stable | README + docs |
| `ios-free-release` | Free app - No monetization | ✅ Ready | Merged from main |
| `ios-monetized-ads-storekit` | Paid - AdMob + StoreKit 2 | ✅ Ready | StoreManager added |
| `ios-dev-2026-01` | Active development | 🔧 Current | Privacy permissions fix |

**Bundle ID**: com.ogsaas.turnover  
**Min iOS**: 16.0  
**Xcode Workspace**: TurnOver.xcworkspace

---

## 3. Current State (2026-01-11)

### Build Status
| Platform | Status | Notes |
|----------|--------|-------|
| Android APK | ✅ Built | Ready for Play Store upload |
| iOS Simulator | ✅ Working | Tested on iPhone 14 (iOS 16.0) |
| iOS Device | ⚠️ Blocked | Install hangs - Xcode GUI recommended |

### What Was Done Today
1. ✅ Privacy permissions added (camera, photos, motion)
2. ✅ iOS 16 simulator installed and tested
3. ✅ App runs successfully in simulator
4. ✅ API Setup Guide created
5. ✅ GitHub documentation added (README, USER_GUIDE)
6. ✅ Branch `ios-dev-2026-01` created and pushed
7. ⚠️ iPhone 14 device install hung (use Xcode GUI instead)

### iOS Swift Files (18 total in TurnOverFeature)
- AIService.swift - OpenAI GPT-4o integration
- AnalysisView.swift - Photo analysis results display
- AppState.swift - Global state management
- ContentView.swift - Main tab navigation
- DecisionView.swift - Keep/Sell/Donate decision
- Models.swift - Data structures
- CharitySelectionView.swift
- MarketplaceSelectionView.swift
- ExportDonationView.swift
- ExportListingView.swift
- InventoryView.swift
- SettingsView.swift - API key entry, preferences
- ImagePicker.swift - Camera/photo library
- LevelLockCameraView.swift - HIG camera with level
- OnboardingView.swift - 5-page intro + tips
- StoreManager.swift - StoreKit 2 IAP
- Theme.swift - Colors, fonts, styling
- UserPreferences.swift - Persisted settings

---

## 4. Developer Accounts

### Apple Developer ✅ ACTIVE
- **Holder**: Roger Grubb
- **Team ID**: Q3A9W7L832
- **Certificate**: Apple Development: Roger Grubb (68XWSKK3UN)
- **Status**: Can deploy to devices NOW
- **Signing**: Automatic, configured in Xcode

### Google Play 🔧 PENDING (Liam action required)
- **Holder**: Liam (lbarkster@gmail.com)
- **Status**: Identity verification required
- **Fee**: $25 one-time (not yet paid)

### OpenAI API 🔧 PENDING (Friend meeting tomorrow)
- **Required for**: Item photo analysis
- **Key format**: sk-proj-xxxxxxxxx
- **Entry point**: Settings → API Key field
- **Guide**: docs/API_SETUP_GUIDE.md

---

## 5. Architecture & Design Decisions

### Why Swift/SwiftUI (not React Native)
- Native performance for camera features
- StoreKit 2 requires native
- HIG compliance easier
- Level-lock camera needs CoreMotion

### iOS HIG Compliance
- NavigationStack (iOS 16+)
- @Environment(\.dismiss)
- System colors (auto dark mode)
- Dynamic Type support
- Haptic feedback
- 44pt minimum tap targets

### Branch Strategy
- `main` = stable, production-ready
- `*-free-release` = no monetization
- `*-monetized-*` = ads + IAP
- `*-dev-YYYY-MM` = active development

---

## 6. Known Issues & Landmines

| Issue | Severity | Status | Workaround |
|-------|----------|--------|------------|
| Device install hangs | Medium | ⚠️ | Use Xcode GUI (Cmd+R) |
| Simulator no camera | Low | ✅ Known | PHPicker fallback works |
| StoreKit products | Low | 🔧 | Need App Store Connect setup |
| Main actor warnings | Low | ⚠️ | Non-blocking, cosmetic |

### Platform Pitfalls
- iOS 15 NOT supported (NavigationStack)
- Simulator has no camera hardware
- CoreMotion unavailable in simulator
- xcrun devicectl hangs on iOS 26.1

---

## 7. Debug History

### 2026-01-11: Privacy Permissions Crash
- **Symptom**: App crashed on iPhone 14 with "privacy sensitive data without usage description"
- **Cause**: Missing NSCameraUsageDescription and related keys
- **Fix**: Added INFOPLIST_KEY_* entries to project.pbxproj (both Debug and Release)
- **Commit**: 9528e82 on ios-dev-2026-01

### 2026-01-11: Device Install Hang
- **Symptom**: xcrun devicectl device install app hangs at "Acquired usage assertion"
- **Cause**: Unknown - possibly iOS 26.1 beta issue with CLI tools
- **Workaround**: Use Xcode GUI (Product → Run or Cmd+R)
- **Status**: Not resolved, documented

### 2026-01-11: ImagePicker Simulator Crash (prior session)
- **Symptom**: EXC_CRASH on "Add Photo" in simulator
- **Cause**: UIImagePickerController.camera fails without hardware
- **Fix**: Triple fallback (camera → photoLibrary → PHPicker)

---

## 8. Proven Patterns

- @available(iOS 16.0, *) for NavigationStack
- UserDefaults for preferences via @AppStorage
- @StateObject for shared managers
- Haptic feedback on buttons
- Context menus for secondary actions

---

## 9. Failed Approaches (Do Not Retry)

| Approach | Why Failed |
|----------|------------|
| Creating separate Info.plist | Conflicts with GENERATE_INFOPLIST_FILE=YES |
| xcrun devicectl on iOS 26.1 | Hangs indefinitely |
| UIImagePickerController.camera on sim | No camera hardware |
| NavigationView in iOS 16+ | Deprecated, use NavigationStack |

---

## 10. Open Questions / Unknowns

- [ ] Why does device install hang? (iOS 26.1 beta issue?)
- [ ] StoreKit product IDs for App Store Connect
- [ ] AdMob unit IDs for production
- [ ] OpenAI API key (Liam meeting friend tomorrow)

---

## 11. Next Actions

### Immediate (Liam)
1. 🔧 Click "Perform Changes" in Xcode dialog
2. 🔧 Try Xcode GUI install: Select iPhone 14 → Cmd+R
3. ⏳ Get OpenAI API key tomorrow with friend
4. ⏳ Complete Google Play identity verification

### Future (Next Claude Session)
1. Test app on physical iPhone 14
2. Configure StoreKit products in App Store Connect
3. Set up AdMob for monetized branches
4. Submit to TestFlight

---

## 12. Files & Links Reference

### GitHub
- Android: https://github.com/papa-bla-blah/TurnOver
- iOS: https://github.com/papa-bla-blah/TurnOver-iOS

### Local Paths
- iOS Project: /Users/celtic57/projects/TurnOverX/TurnOver-iOS/
- Agent Memory: /Users/celtic57/projects/TurnOverX/agent.md
- API Guide: /Users/celtic57/projects/TurnOverX/API_SETUP_GUIDE.md

### Documentation (on GitHub)
- iOS README: https://github.com/papa-bla-blah/TurnOver-iOS/blob/main/README.md
- User Guide: https://github.com/papa-bla-blah/TurnOver-iOS/blob/main/docs/USER_GUIDE.md
- API Setup: https://github.com/papa-bla-blah/TurnOver-iOS/blob/main/docs/API_SETUP_GUIDE.md

### Build Artifacts
- Android APK: https://expo.dev/artifacts/eas/8bwcopSdASGCMFs84AdTob.apk

---

*This document is the single source of truth for TurnOver project state.*
