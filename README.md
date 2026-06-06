# FoodLink (MySaveFood)

> Connecting Surplus. Feeding Communities.

FoodLink is a Flutter mobile application that connects food donors (cafeterias, food stalls, vendors) with people who can benefit from surplus or near-expiry food. Donors broadcast available items in real time, and receivers can discover, reserve, and pick them up before they go to waste — reducing food waste while supporting community welfare.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Data Model](#data-model)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Running the App](#running-the-app)
- [Limitations & Future Work](#limitations--future-work)

## Features

### Core
- **Authentication & Roles** — Email/password and Google Sign-In, with distinct Donor, Student/Receiver, and Admin roles.
- **Real-Time Food Feed** — Browse currently available food items with photos, quantity, pickup location, and expiry ("best before") time, streamed live from Firestore.
- **Post & Manage Listings** — Donors can create listings with photos, descriptions, quantities, and pickup details.
- **Claim / Reservation System** — Receivers can reserve items; available quantity updates in real time to prevent double-booking.
- **QR Pickup Verification** — Generate and scan QR codes to confirm pickup handoffs.
- **Notifications** — Push notifications (Firebase Cloud Messaging) alert users about new listings and claim updates.
- **Profiles & Stats** — Track donation/claim history, ratings, and badges (e.g. verified donor).
- **Leaderboards** — Recognize top donors and active students.
- **Sharing** — Share listings externally via the device's share sheet.
- **Reporting & Moderation** — Users can report suspicious listings or accounts; Admins can review, manage users, and remove content.
- **Admin Analytics** — Dashboard with charts summarizing platform activity.

### Shariah Compliance
- Donors confirm Halal status before a listing can be published.
- Reporting tools help keep the platform trustworthy and free of abuse.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/docs) (cross-platform: Android, iOS, Web, Desktop)
- **Backend:** [Firebase](https://firebase.google.com/docs) — Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Other notable packages:** `cached_network_image`, `fl_chart`, `qr_flutter`, `mobile_scanner`, `share_plus`, `cloudinary_public`, `google_fonts`

See `pubspec.yaml` for the full dependency list.

## Architecture

The app follows an **MVVM (Model-View-ViewModel)**-inspired structure:

- **Model** — Plain data classes mapping to Firestore documents (e.g. `FoodItemModel`, `UserModel`, `ClaimModel`).
- **View** — Stateless/Stateful widgets responsible only for UI rendering (`lib/views`, `lib/widgets`).
- **ViewModel** — `Provider`-based classes that fetch data, manage loading/auth state, and contain business logic (`lib/providers`, `lib/services`).

This separation keeps UI code free of business logic and makes the app easier to test and extend.

## Data Model

The app uses **Cloud Firestore** (NoSQL). Key collections:

**`users`**
- `uid`, `name`, `email`, `role` (`donor` | `student` | `admin`)

**`food_items`**
- `itemId`, `donorId`, `imageUrl`, `title`, `description`, `quantity`, `pickupLocation`, `expiryTime`, `status` (`available` | `claimed`)

**`claims`**
- `claimId`, `itemId`, `studentId`, `timestamp`

## Project Structure

```
lib/
├── core/          # Shared config, constants, routes, theme, utilities
├── models/        # Data models (FoodItem, User, Claim, Rating, ...)
├── providers/     # State management (Provider/ViewModel layer)
├── services/      # Firebase & external service integrations
├── views/         # App screens, grouped by area (auth, main, admin, post, ...)
├── widgets/        # Reusable UI components
└── main.dart      # App entry point
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `>=3.2.0 <4.0.0`)
- A configured [Firebase](https://firebase.google.com/) project
- Android Studio / Xcode (for mobile builds) or a modern browser (for web)

### Installation

```bash
git clone <repository-url>
cd FoodLink
flutter pub get
```

## Firebase Setup

This project uses Firebase for authentication, database, storage, and messaging.

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password and Google Sign-In), **Cloud Firestore**, **Cloud Storage**, and **Cloud Messaging**.
3. Generate platform configuration files using the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This regenerates `lib/firebase_options.dart` for your own Firebase project.
4. Deploy the included security rules and indexes if needed:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

## Running the App

```bash
# Run on a connected device or emulator
flutter run

# Run on a specific platform
flutter run -d chrome
flutter run -d windows
```

### Tests

```bash
flutter test
```

## Limitations & Future Work

### Current Limitations
- **Manual location entry** — Pickup locations are entered as free text; there is no map-based location picker.
- **No in-app chat** — Coordination relies solely on listing descriptions; donors and receivers cannot message each other directly.
- **Basic search** — Search currently filters by food name only, not by distance or category.

### Planned Enhancements
- **Map integration** — A "Food Near Me" view using a maps API to visualize nearby listings.
- **Smart notifications** — Notify users when a preferred food type is posted.
- **AI food recognition** — Auto-classify food type from photos to speed up listing creation.

## References

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)
