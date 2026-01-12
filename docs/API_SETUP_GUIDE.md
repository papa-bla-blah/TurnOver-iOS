# TurnOver API Setup Guide
**Date Created:** January 11, 2026  
**For:** Liam + Friend Setup Session

---

## What You Need

TurnOver uses **OpenAI's GPT-4o** to analyze photos and estimate values. You need an OpenAI API key.

**Cost:** Pay-as-you-go, typically $1-5/month for casual use (each analysis ~$0.01-0.03)

---

## Step 1: Get OpenAI API Key

1. Go to: **https://platform.openai.com**
2. Sign up or log in (can use Google account)
3. Click your profile icon → **"View API keys"**
4. Click **"Create new secret key"**
5. Name it something like "TurnOver App"
6. **COPY THE KEY IMMEDIATELY** - you can't see it again!
   - Key looks like: `sk-proj-xxxxxxxxxxxxxxxxxxxx`

---

## Step 2: Add Payment Method (Required)

1. Go to: **https://platform.openai.com/account/billing**
2. Click **"Add payment method"**
3. Add credit card
4. Set a usage limit (recommend $10-20/month cap to start)

---

## Step 3: Enter Key in TurnOver App

### On iOS (iPhone/Simulator):
1. Open TurnOver app
2. Tap **Settings** (gear icon)
3. Find **"API Key"** field
4. Paste your `sk-proj-...` key
5. Done!

### On Android:
1. Open TurnOver app
2. Tap **Settings**
3. Find **"OpenAI API Key"** field
4. Paste your key
5. Done!

---

## Verify It Works

1. Go to Capture screen
2. Take a photo of any item (book, shoe, mug, etc.)
3. Tap **"Analyze with AI"**
4. Should see results in 5-15 seconds:
   - Item name
   - Category
   - Condition
   - Estimated value

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Invalid API key" | Typo or old key | Re-copy from OpenAI dashboard |
| "Insufficient quota" | No payment method | Add card at platform.openai.com/billing |
| "Rate limit exceeded" | Too many requests | Wait 1 minute, try again |
| Analysis fails | Network issue | Check internet connection |

---

## Security Notes

- **Never share your API key publicly**
- Key is stored locally on device only
- TurnOver does NOT store your key on any server
- You can delete/regenerate keys anytime at OpenAI

---

## Quick Links

- OpenAI Platform: https://platform.openai.com
- API Keys: https://platform.openai.com/api-keys
- Billing: https://platform.openai.com/account/billing
- Usage: https://platform.openai.com/usage

---

## Project Status (For Reference)

**GitHub Repos:**
- Android: https://github.com/papa-bla-blah/TurnOver
- iOS: https://github.com/papa-bla-blah/TurnOver-iOS

**Working APK (Android):**
https://expo.dev/artifacts/eas/8bwcopSdASGCMFs84AdTob.apk

**Apple Developer Account:** Roger Grubb (Team ID: Q3A9W7L832) ✅

---

## Questions for Friend

If your friend has existing OpenAI access:
1. Can we use their organization's API key? (might have higher limits)
2. Do they have GPT-4 API access enabled? (needed for vision/image analysis)
3. Any existing projects we should know about?
