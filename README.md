# AI Travel Planner

A full-stack **Flutter** travel planning application powered by **Firebase** and **Google Gemini AI**. The app features a role-based system with three distinct dashboards for **Travelers**, **Travel Agents**, and **Admins**, plus an integrated AI assistant on every screen.

---

## Features

### Role-Based Access
| Role | Capabilities |
|------|-------------|
| **Traveler** | Browse & search packages, book trips, view booking history, wishlist, world map explorer |
| **Agent** | Create & manage travel packages with images & locations, view all customer bookings |
| **Admin** | Manage users & agents, monitor system activity, full platform oversight |

### AI Assistant (Gemini 2.5 Flash)
- Embedded AI chat sidebar available on **all three dashboards**
- Context-aware — knows the user's role and name
- Powered by a **Vercel serverless function** to keep the API key secure (never exposed in the APK)

### Interactive Map
- OpenStreetMap-based world explorer (no API key required)
- Agents can pin exact pickup/destination locations via an in-app location picker
- Travelers can explore destinations visually

### Package Management
- Agents create rich travel packages (title, description, price, duration, destinations, images)
- Real-time sync via **Cloud Firestore**
- QR code generation for bookings (`qr_flutter`)

### Authentication
- Firebase Authentication (email/password)
- Persistent login with role-based routing on startup

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3 (Dart), Material 3, Google Fonts (Plus Jakarta Sans) |
| **State Management** | Provider |
| **Backend / DB** | Firebase Auth + Cloud Firestore |
| **AI** | Google Gemini 2.5 Flash via Vercel serverless function |
| **Maps** | flutter_map + OpenStreetMap (no key needed) |
| **Deployment** | Vercel (serverless API) + Firebase (Flutter Web) |

---

## Project Structure

```
lib/
├── main.dart                   # App entry, theme, routing
├── firebase_options.dart       # Auto-generated Firebase config
├── models/                     # Data models (Package, Booking, User...)
├── providers/                  # AuthProvider, WishlistProvider
├── screens/
│   ├── auth/                   # Login & Register screens
│   ├── traveler/               # Dashboard, Package list/detail, Bookings, World Explorer
│   ├── agent/                  # Dashboard, Create/Manage packages, Customer bookings, Location picker
│   └── admin/                  # Dashboard, Manage agents/users, System monitor
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   ├── firestore_service.dart  # Firestore CRUD
│   ├── ai_assistant_service.dart # Gemini API calls (via Vercel)
│   └── geocoding_service.dart  # Reverse geocoding
├── utils/                      # Constants, routes, helpers
└── widgets/                    # Reusable UI components

api/
└── gemini-chat.js              # Vercel serverless function (Gemini proxy)
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Node.js `18+` (for the Vercel serverless function)
- A Firebase project with **Authentication** and **Firestore** enabled
- A **Gemini API key** from [Google AI Studio](https://aistudio.google.com/)
- A [Vercel](https://vercel.com) account

---

### 1. Clone the Repository

```bash
git clone https://github.com/Saksham-Gupta-GH/AI_travel_planner.git
cd AI_travel_planner
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Install Node Dependencies (for the AI backend)

```bash
npm install
```

### 4. Firebase Setup

This project uses Firebase. The `lib/firebase_options.dart` file is **auto-generated** and included in the repo. If you want to connect your own Firebase project:

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Firebase project
flutterfire configure
```

Make sure to enable:
- **Firebase Authentication** → Email/Password
- **Cloud Firestore** → in production or test mode

---

## Deploying the AI Backend (Vercel)

The Gemini API key is kept secure on the server — it is **never bundled** into the Flutter app or APK.

### 1. Deploy to Vercel

```bash
npx vercel
```

Follow the prompts. When asked for the project root, use `./`.

### 2. Set Environment Variables in Vercel Dashboard

Go to **Project → Settings → Environment Variables** and add:

| Variable | Value |
|----------|-------|
| `GEMINI_API_KEY` | Your key from Google AI Studio |
| `GEMINI_MODEL` | `gemini-2.5-flash-lite` *(optional, already hardcoded)* |

### 3. Get Your Endpoint URL

After deployment, your AI endpoint will be:

```
https://your-vercel-app.vercel.app/api/gemini-chat
```

---

## Running the Flutter App

### Web (Chrome)

```bash
flutter run -d chrome \
  --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat
```

### Android

```bash
flutter run -d <device-id> \
  --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat
```

### Build APK

```bash
flutter build apk \
  --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat
```

> **Note:** Without `--dart-define=AI_API_ENDPOINT`, the AI assistant will be disabled but the rest of the app works normally.

---

## Deploying the Flutter Web App

You can host the Flutter Web build on **Firebase Hosting** or **Vercel** (see below).

### Option A — Firebase Hosting (Recommended)

```bash
./deploy.sh https://your-vercel-app.vercel.app
```

This script builds Flutter Web with the AI endpoint baked in and deploys to Firebase Hosting in one step. Your app will be live at:

```
https://saksham230911186.web.app
```

Or manually:

```bash
flutter build web --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat
firebase deploy --only hosting
```

### Option B — Vercel (Flutter Web)

Vercel **does not natively support Flutter builds**, but you can pre-build and deploy the output:

```bash
# Build the Flutter web output
flutter build web --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat

# Deploy the build/web folder to Vercel
npx vercel build/web --prod
```

> **Recommended:** Use **Firebase Hosting** for the Flutter web frontend — it's purpose-built for this and gives you a single Firebase project for auth + database + hosting.

---

## Security Notes

- `lib/firebase_options.dart` contains public Firebase config values (this is safe for client-side Firebase SDKs)
- The **Gemini API key is never in the Flutter code** — it lives only in Vercel environment variables
- `.env*.local` and `.vercel/` are git-ignored

---

## Key Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
flutter_map: ^6.1.0      # OpenStreetMap, no API key
provider: ^6.1.2
google_fonts: ^6.1.0
qr_flutter: ^4.1.0
intl: ^0.19.0
http: ^1.1.0
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

This project is for educational purposes. Feel free to use and adapt it.

---

*Built with Flutter, Firebase & Google Gemini AI*
