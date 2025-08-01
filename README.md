# Chaos Dare

The Most Controversial Live Dare App on the Internet

## 🎯 Core Concept

A live, unscripted, high-stakes dare platform where:
- Users pay to submit dares (or vote on them)
- Dare Doers perform LIVE (1v1, solo, or group)
- The app takes a cut (20% on submissions, 50% on tips)
- Fails go viral (auto-posted to TikTok/Reels)

## 🚀 Tech Stack

- **Flutter** - Cross-platform mobile & web app
- **Firebase** - Backend, auth, database, storage
- **Agora.io** - Live video streaming
- **Stripe** - Payment processing
- **FFmpeg** - Video processing for viral clips

## 📱 Features

### Core Mechanics
- **Dare Submission System** - Pay $1-25 based on difficulty
- **Live Streaming** - Real-time video with Agora.io
- **Audience Interaction** - Live chat, tips, pressure meter
- **Viral Clip Generation** - Auto-create TikTok/Reels content

### Monetization
- 20% platform cut on dare submissions
- 50% cut on tips and escalations
- Sponsored dares from brands
- Premium memberships

### Safety & Compliance
- Strict 18+ age verification
- AI content moderation
- No gambling mechanics
- RLS policies for data protection

## 🛠 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.10.0)
- Firebase project
- Agora.io account
- Stripe account

### Installation

1. **Clone and setup Flutter**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`

3. **Configure Agora.io**
   - Get your App ID from Agora console
   - Update `appId` in `lib/services/live_stream_service.dart`

4. **Configure Stripe**
   - Get your publishable key
   - Update `Stripe.publishableKey` in `lib/main.dart`
   - Set up your backend for payment intents

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Key Features Implemented

- ✅ User authentication with age verification (18+)
- ✅ Dare submission with difficulty-based pricing
- ✅ Live streaming integration (Agora.io ready)
- ✅ Payment processing (Stripe integration)
- ✅ Real-time database with Firebase
- ✅ Viral video processing with FFmpeg
- ✅ Modern UI with chaos-themed design

## 💰 Revenue Model

| Revenue Stream | Platform Cut | Description |
|---------------|--------------|-------------|
| Dare Submissions | 20% | Users pay $1-25 to submit dares |
| Tips & Escalations | 50% | Audience pays to make dares harder |
| Sponsored Dares | 100% | Brands pay for featured challenges |
| Premium Features | 100% | Ad-free, exclusive content |

## 🎨 Design Philosophy

- **Chaos-themed** - Dark UI with red/purple gradients
- **High-energy** - Animations and micro-interactions
- **Mobile-first** - Optimized for vertical video content
- **Viral-ready** - Built for TikTok/Reels integration

## 🚨 Legal & Safety

- **Age Verification** - Strict 18+ enforcement
- **Content Moderation** - AI + human review
- **No Gambling** - Pure entertainment, no betting
- **Data Protection** - GDPR compliant with Firebase RLS

## 📈 Growth Strategy

1. **Viral Marketing** - Leak fails on TikTok for free promotion
2. **Influencer Partnerships** - Sponsor streamers for live battles
3. **Brand Sponsorships** - Featured dare challenges
4. **Social Integration** - Auto-share clips to maximize reach

---

**Ready to create viral chaos? Let's build the most controversial app on the internet! 🔥**