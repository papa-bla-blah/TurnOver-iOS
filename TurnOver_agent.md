# TurnOver - Project Memory

**Status**: 🔨 In Development  
**Last Updated**: 2026-01-14  
**Location**: ProtonDrive ClaudeProjectsDev/TurnOver/

---

## 1. What It Does

AI-powered photo analysis app for sell/donate recommendations
- Take photo → GPT-4o analyzes → Recommends sell or donate
- Value estimates for resale items
- 8 marketplace integrations (eBay, Facebook, Craigslist, etc.)
- Charity selection with EIN validation
- Export listings & donation receipts
- Inventory management

**Platforms**: iOS (Swift/SwiftUI 16+) | Android (React Native/Expo)  
**Bundle IDs**: com.ogsaas.turnover (iOS) | com.turnover (Android)

---

## 2. Current Status

| Platform | Build | Store Ready | Blocker |
|----------|-------|-------------|---------|
| iOS | ✅ Runs on sim | 80% | API key, legal pages |
| Android | ✅ APK built | 70% | API key, Play verification |

**Android APK**: https://expo.dev/artifacts/eas/8bwcopSdASGCMFs84AdTob.apk

### Human Actions Required (Liam):
- [ ] **OpenAI API key** ← BLOCKS CORE FEATURE
- [ ] Host Privacy Policy: ogsaas.com/turnover/privacy
- [ ] Host Terms of Service: ogsaas.com/turnover/terms
- [ ] Google Play ID verification (sendliamemail@gmail.com)
- [ ] Test iOS on iPhone 14 (Xcode Cmd+R)

### Next Claude Session:
- [ ] App Store Connect listing
- [ ] TestFlight submission
- [ ] Google Play Console upload
- [ ] StoreKit product IDs
- [ ] AdMob production IDs

---

## 3. Definition of Done

**Functional Requirements**:
- ✅ Camera + compression working
- ✅ GPT-4o analysis integrated
- ✅ Sell/Donate flow complete
- ✅ 8 marketplaces configured
- ✅ Charity selection w/ EIN
- ✅ Export listings & donation receipts
- ✅ Inventory management
- ✅ Settings (API, prefs, legal, about)
- [ ] App Store submission
- [ ] Google Play submission
- [ ] Production API keys configured

**Non-Functional Constraints**:
- Performance: Image analysis < 10s
- Cost: API calls optimized
- Security: API keys in secure storage
- UX: Intuitive, 3-tap max to analyze

**Platforms**:
- iOS: iPhone 14+, iOS 16+
- Android: API 24+, React Native/Expo

**Out-of-Scope**:
- Web version
- Batch processing
- Offline mode

---

## 4. Architecture

**Project Structure**:
```
TurnOver/
├── TurnOver-iOS/          (Swift/SwiftUI)
│   └── GitHub: papa-bla-blah/TurnOver-iOS
├── turnover-android/      (React Native/Expo)
│   └── GitHub: papa-bla-blah/TurnOver
├── turnover-android-native-ARCHIVE/  (Old Kotlin - reference only)
└── docs/
    ├── API_SETUP_GUIDE.md
    └── credentials.md
```

**Key Technical Decisions**:

| Decision | Rationale |
|----------|-----------|
| React Native/Expo (Android) | Cross-platform capability, faster dev |
| Swift/SwiftUI (iOS) | Native performance, camera access |
| GPT-4o Vision | Best accuracy for item analysis |
| Separate repos per platform | Different release cycles |
| Keychain/SecureStore | Secure API key storage |

**Why Alternatives Rejected**:
- Flutter → React Native has better Expo ecosystem
- Native Android → RN faster for feature parity
- Single monorepo → Complicates CI/CD per platform
- GPT-3.5 → Not accurate enough for items

---

## 5. Known Issues & Solutions

| Issue | Workaround |
|-------|------------|
| iOS device install hangs via CLI | Use Xcode GUI (Cmd+R) |
| Simulator has no camera | Photo picker fallback works |
| Large images slow API | Compress to <2MB before sending |
| `xcrun devicectl` hangs on iOS 26.1 | Use Xcode instead |
| `UIImagePickerController.camera` on sim | Crashes - needs real device |

---

## 6. Proven Patterns

**Image Processing**:
- Compress images to <2MB before API call
- Use JPEG format with 0.8 quality
- Resize to max 1024x1024 maintaining aspect ratio

**API Integration**:
- Store keys in secure storage (Keychain iOS, SecureStore Android)
- Validate key on settings save
- Graceful degradation if no key

**Navigation**:
- iOS: NavigationStack (not deprecated NavigationView)
- Android: React Navigation bottom tabs

---

## 7. Failed Approaches (Do Not Retry)

- `xcrun devicectl` on iOS 26.1 → hangs, use Xcode
- `UIImagePickerController.camera` on simulator → crashes, needs device
- `NavigationView` on iOS 16+ → deprecated, use NavigationStack
- Separate Info.plist → conflicts with GENERATE_INFOPLIST_FILE
- Native Kotlin Android → switched to React Native for speed

---

## 8. Debug History

**2026-01-14**: Project consolidation
- Renamed local TurnOverX → TurnOver for consistency
- All git repos clean and synced
- ProtonDrive backup established

**2026-01-11**: iOS privacy crash fix
- Added privacy strings to Info.plist
- Tested on iPhone 14 simulator successfully

**2025-12**: Initial builds
- iOS project created with SwiftUI
- Android switched from native to React Native/Expo

---

## 9. Next Actions

**Immediate (Liam)**:
1. Get OpenAI API key
2. Host privacy/terms pages
3. Test APK on Android device
4. Verify Google Play Console access

**Next Session (Claude)**:
1. App Store Connect listing
2. TestFlight submission prep
3. Google Play Console upload prep
4. Configure StoreKit/AdMob IDs

---

## 10. Accounts & Access

**Apple Developer**:
- Account: Roger Grubb
- Team: Q3A9W7L832 ✅

**Google Play**:
- Account: sendliamemail@gmail.com
- Status: 🔧 Verification pending

**OpenAI**:
- Status: 🔧 API key needed

**GitHub Repos**:
- iOS: https://github.com/papa-bla-blah/TurnOver-iOS
- Android: https://github.com/papa-bla-blah/TurnOver

**Branches**:
- iOS: `main` (production), `ios-dev-2026-01` (development)
- Android: `main` (production)

---

*For environment setup, see ~/agent.md*  
*For detailed progress, see progress_sum.md*
