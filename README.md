# 📰 News App

A modern Flutter news application built with **Clean Architecture**, **BLoC state management**, **Supabase Authentication**, and **NewsAPI**.

The application provides authenticated access to real-time news, intelligent search, pagination, offline handling, local caching, multilingual support, and a clean responsive interface.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-42A5F5)](https://bloclibrary.dev/)
[![Supabase](https://img.shields.io/badge/Auth-Supabase-3ECF8E?logo=supabase)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-Educational-lightgrey)](#license)

---

## 📱 Download

### Android APK

Download the latest Android APK from the **GitHub Releases** page:

**[⬇️ Download Latest APK](../../releases/latest)**

> The APK is provided for Android devices. You can also build the application locally by following the installation instructions below.

---

## ✨ Features

### 🔐 Authentication

* Email/password authentication
* User registration
* Login and logout
* Persistent Supabase session handling
* Session validation during application startup

### 📰 News

* Latest top headlines
* News search
* News detail view
* Open full article in browser
* Pagination / infinite scrolling
* Pull-to-refresh
* Lazy network image loading
* Loading shimmer states

### 🔎 Search

* Search news using NewsAPI
* 500 ms search debounce
* Empty search result handling
* Search loading and error states

### 💾 Offline & Caching

* Local news caching using SharedPreferences
* Cached news fallback when the API is unavailable
* Internet connectivity detection
* Offline banner
* Error and retry states

### 🌍 Localization

* English
* Spanish
* Persisted language selection
* Runtime language switching

### 🧭 Navigation

* Declarative navigation using GoRouter
* Splash → Language → Authentication → News flow
* News detail navigation

### 🎨 UI / UX

* Material-based interface
* Custom reusable widgets
* Consistent spacing, colors and typography
* Animated splash screen
* Shimmer loading placeholders
* Empty and error states
* Responsive mobile-first layout

---

## 🏗️ Architecture

The project follows **Clean Architecture** combined with a **feature-first folder structure**.

```text
lib/
│
├── core/
│   ├── connectivity/
│   ├── constants/
│   ├── errors/
│   ├── localization/
│   ├── network/
│   ├── services/
│   ├── themes/
│   ├── utils/
│   └── widgets/
│
├── dependency_injection/
│   └── injection.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   ├── news/
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   └── settings/
│       ├── pages/
│       └── widgets/
│
├── l10n/
├── routes/
├── app.dart
└── main.dart
```

### Architecture Layers

**Presentation**

Responsible for UI, BLoC events, states and user interaction.

**Domain**

Contains business logic through entities, repositories and use cases.

**Data**

Handles API communication, models, data sources and repository implementations.

**Core**

Contains shared networking, caching, localization, themes, connectivity and reusable UI components.

---

## 🔄 Application Flow

```text
                    ┌───────────────┐
                    │   App Start   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Splash Screen │
                    └───────┬───────┘
                            │
                     Language Selected?
                       /           \
                     No             Yes
                     │               │
                     ▼               ▼
              Language Screen    Check Session
                                     │
                           ┌─────────┴─────────┐
                           │                   │
                        Logged In          Logged Out
                           │                   │
                           ▼                   ▼
                      News Feed             Login
```

### News Data Flow

```text
UI
 │
 ▼
NewsBloc
 │
 ▼
Use Case
 │
 ▼
Repository
 │
 ├──────────────► Local Cache
 │
 ▼
Remote Data Source
 │
 ▼
Dio
 │
 ▼
NewsAPI
```

---

## 🛠️ Tech Stack

| Technology           | Purpose                   |
| -------------------- | ------------------------- |
| Flutter              | Application framework     |
| Dart                 | Programming language      |
| flutter_bloc         | State management          |
| Equatable            | Value equality            |
| Dio                  | HTTP networking           |
| NewsAPI              | News data provider        |
| Supabase             | Authentication            |
| GoRouter             | Navigation                |
| GetIt                | Dependency injection      |
| SharedPreferences    | Local persistence         |
| flutter_dotenv       | Environment configuration |
| cached_network_image | Image caching             |
| connectivity_plus    | Network connectivity      |
| url_launcher         | External article links    |
| json_serializable    | JSON serialization        |
| intl                 | Localization / formatting |

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio or Android SDK
* VS Code / Android Studio
* Git

Verify Flutter:

```bash
flutter doctor
```

---

## 📥 Installation

### 1. Clone the repository

```bash
git clone https://github.com/dev-sabaree/news.git
cd news
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_publishable_key
```

> The NewsAPI key is kept server-side in the Supabase Edge Function and is never bundled into the Flutter APK.

The application reads these values through `flutter_dotenv`.

> Never commit your real `.env` file or private credentials to GitHub.

### 4. Generate JSON serialization files

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the application

```bash
flutter run
```

For a connected Android device:

```bash
flutter devices
flutter run
```

---

## 🔑 API Configuration

### NewsAPI

The application uses NewsAPI for:

* Top headlines
* Article search
* Pagination

Create an API key from the NewsAPI service and store it as the `NEWS_API_KEY` secret in your Supabase Edge Function environment. Do **not** put the NewsAPI key in the Flutter `.env` file.

The Flutter app calls a Supabase Edge Function, which securely proxies these NewsAPI operations:

```text
Flutter App → Supabase Edge Function → NewsAPI

GET /top-headlines
GET /everything
```

The NewsAPI credential stays on the server-side Edge Function.

### Supabase

Supabase is used for:

* User registration
* Email/password login
* Session management
* Logout

Configure your Supabase project and add the required values to `.env`.

---

## 📦 Building the APK

### Debug APK

```bash
flutter build apk --debug
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```bash
flutter build apk --release
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Smaller APKs per CPU architecture

```bash
flutter build apk --split-per-abi
```

The generated APKs will be available under:

```text
build/app/outputs/flutter-apk/
```

---

## 📲 Installing the APK

### Option 1 — Android phone

1. Build the release APK.
2. Copy `app-release.apk` to your phone.
3. Open the APK.
4. Allow installation from the requested source if Android asks.
5. Install the application.

### Option 2 — ADB

Connect your Android device with USB debugging enabled:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Automated GitHub APK Releases

The repository includes a GitHub Actions workflow at `.github/workflows/android-release.yml`.

When you push a version tag such as `v1.0.0`, GitHub Actions will:

1. Install the latest stable Flutter SDK.
2. Create `.env` from the Supabase URL and publishable key GitHub Actions secrets.
3. Install dependencies.
4. Generate JSON serialization code.
5. Run `flutter analyze`.
6. Build the release APK.
7. Upload the APK as a workflow artifact.
8. Publish the APK automatically to the GitHub Release.

### Required GitHub Secrets

Add these repository secrets under **Settings → Secrets and variables → Actions**:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Do not commit the real `.env` file.

### Create a release

After adding the three secrets, create and push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will create the GitHub Release and attach:

```text
news-app-release.apk
```

You can then use the **Download Latest APK** link at the top of this README.

> The first automated release should be treated as a release-candidate build: verify authentication, API access, app startup, and APK installation on a real Android device before sharing it publicly.

---

## 🧪 Testing

Run Flutter tests with:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Format the project:

```bash
dart format lib test
```

---

## 🔐 Security

The Flutter client loads only the Supabase URL and publishable key from `.env`. The NewsAPI secret is stored server-side in the Supabase Edge Function and is not shipped with the APK.

The `.gitignore` configuration already excludes:

```text
.env
```

Do not commit:

* API keys
* Supabase credentials
* Private certificates
* Keystores
* Signing passwords

For production deployment, use secure CI/CD secrets and proper Android release signing.

---

## 📌 Project Highlights

This project demonstrates practical Flutter development concepts including:

* Clean Architecture
* Feature-first project organization
* BLoC state management
* Dependency injection
* REST API integration
* Authentication
* Local caching
* Offline-first fallback
* Pagination
* Search debouncing
* Localization
* Declarative navigation
* Reusable widgets
* Error handling
* Loading and empty states

---

## 🎯 Project Purpose

This project was developed to demonstrate how a production-style Flutter application can be structured using modern architectural and development practices.

The focus is not only on displaying news, but also on demonstrating maintainable architecture, predictable state management, API integration, authentication, local persistence and resilient user experience.

---

## 👨‍💻 Author

**Sabareesh K**

Flutter Developer | Computer Science Engineering Student

GitHub: [@dev-sabaree](https://github.com/dev-sabaree)

---

## ⭐ Support

If you find this project useful or interesting, consider giving the repository a ⭐ on GitHub.

---

## 📄 License

This project is intended for educational and portfolio purposes.
