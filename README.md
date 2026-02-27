# 📺 YouTube Clone

A feature-rich YouTube clone built with **Flutter** and **Clean Architecture**, integrating the YouTube Data API v3. Supports video browsing, Shorts, subscriptions, search, channel profiles, video downloading with AES encryption, watch history, and playlists — all built on BLoC state management.

---

## 📱 APK Download

> Pre-built release APK is available in the root of this repository.

```
youtube_clone_release.apk  (63.9 MB)
```

---

## 🛠️ Flutter Version

| Tool        | Version   |
|-------------|-----------|
| Flutter     | 3.41.2 (stable) |
| Dart        | 3.11.0    |
| DevTools    | 2.54.1    |

---

## 📦 Package Dependencies

### Core Architecture
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management (BLoC/Cubit) |
| `equatable` | ^2.0.5 | Value equality for states |
| `dartz` | ^0.10.1 | Functional programming (Either) |
| `get_it` | ^7.7.0 | Service locator / dependency injection |
| `injectable` | ^2.5.0 | DI code generation |

### Networking & Storage
| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.8.0+1 | HTTP client for API calls |
| `hive` / `hive_flutter` | ^2.2.3 / ^1.1.0 | Local NoSQL storage (watch history) |
| `shared_preferences` | ^2.5.2 | Lightweight key-value storage (settings, profile) |
| `flutter_secure_storage` | ^9.2.4 | AES key storage (encrypted videos) |

### Media & UI
| Package | Version | Purpose |
|---------|---------|---------|
| `video_player` | ^2.9.5 | In-app video playback |
| `cached_network_image` | ^3.4.1 | Image caching |
| `shimmer` | ^3.0.0 | Loading skeleton animations |
| `flutter_screenutil` | ^5.9.3 | Responsive UI scaling |
| `image_picker` | ^1.1.2 | Profile photo selection |
| `flutter_downloader` | ^1.11.1 | Background video download |
| `flutter_local_notifications` | ^17.2.2 | Download progress notifications |
| `flutter_svg` | ^2.0.10 | SVG icon rendering |
| `font_awesome_flutter` | ^10.12.0 | FontAwesome icon set |
| `share_plus` | ^12.0.1 | Native share sheet |

### Crypto & Security
| Package | Version | Purpose |
|---------|---------|---------|
| `encrypt` | ^5.0.3 | AES-256 encryption/decryption |
| `crypto` | ^3.0.7 | SHA-256 file integrity hashing |
| `flutter_secure_storage` | ^9.2.4 | Secure per-video key persistence |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `go_router` | ^17.1.0 | Declarative navigation |
| `firebase_auth` / `firebase_core` | ^6.1.4 / ^4.4.0 | Authentication |
| `youtube_explode_dart` | ^3.0.5 | YouTube stream URL resolution |
| `flutter_dotenv` | ^6.0.0 | `.env` API key management |
| `connectivity_plus` | ^7.0.0 | Network state detection |
| `timeago` | ^3.7.1 | Human-readable timestamps |
| `path_provider` | ^2.1.5 | Device storage paths |
| `intl` | ^0.20.2 | Internationalisation |
| `rxdart` | ^0.28.0 | Reactive stream operators |
| `storage_space` | ^1.2.0 | Device storage info |
| `logger` | ^2.5.0 | Structured logging |

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter 3.41.x or newer
- Android Studio or VS Code with Flutter plugin
- A Firebase project (for authentication)
- A YouTube Data API v3 key

### 1. Clone
```bash
git clone <your-repo-url>
cd youtube_clone
```

### 2. Configure Environment Variables
Create a `.env` file in the project root:
```env
YOUTUBE_API_KEY=YOUR_YOUTUBE_DATA_API_V3_KEY
```
> ⚠️ Never commit your `.env` file. It is listed in `.gitignore`.

### 3. Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Download `google-services.json` → place in `android/app/`

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

### 6. Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ✨ Features Implemented

### 🏠 Home Feed
- Paginated video feed from YouTube Data API v3
- Video category filtering
- Shimmer loading skeletons
- Pull-to-refresh

### ▶️ Video Player (Watch Page)
- Custom video player with full controls
- Auto-hide controls timer
- Playback speed selection (0.5×, 1×, 1.25×, 1.5×, 2×)
- Video quality switching
- Picture-in-Picture (PiP) support
- Fullscreen / landscape mode
- Pinch-to-zoom
- Progress bar with seek

### 📹 Shorts
- Vertical swipe-based Shorts feed
- Like, follow, and comment interactions (UI)
- Real view/like counts from API

### 🔍 Search
- Real-time search with debounce
- Search history (persisted locally)
- Infinite scroll pagination
- Empty and error states

### 📡 Subscriptions
- Popular channels listing from API
- Channel avatar and subscriber count

### 👤 Channel Profile
- Channel banner, description, and video listing
- Navigation from video cards and watch page

### 📚 Library / Profile Page
- Local **Watch History** (persisted in Hive, sorted by recency)
- **Playlists** fetched live from YouTube Data API
- Profile management (name, handle, avatar)
- Downloads shortcut

### 💾 Download Manager
- Background downloads via `flutter_downloader`
- Real-time progress notifications
- Queue management (queued → downloading → encrypting → completed)
- **AES-256 encrypted storage** of downloaded videos (`.encvid`)
- Per-video decryption for playback
- Multi-select with batch delete
- Storage usage progress bar

### 🔒 Authentication
- Firebase Email/Password sign-in
- Sign-up with form validation
- Automatic session persistence

### 🌍 Internationalisation
- Multi-language support (English, Spanish, French, Hindi, Arabic, German, Portuguese, Japanese, Malayalam)
- Runtime language switching from Settings

### 🎨 Theming
- System-adaptive light/dark mode
- Manual override in Settings
- Persisted across restarts

---

## ⚠️ Known Issues / Limitations

| Issue | Details |
|-------|---------|
| `connectivity_plus` on some emulators | The connectivity check may throw a `MissingPluginException` on older Android emulators. Use a physical device for testing. |
| YouTube stream URLs | `youtube_explode_dart` occasionally fails to resolve private/age-restricted videos — downloads will fail silently for these. |
| Playlists channel ID | Currently fetches playlists for a fixed Google Developers channel. Fetching authenticated user playlists requires OAuth, which is outside YouTube Data API v3 key scope. |
| `Share` deprecation | `share_plus` v12 deprecates `Share.share()` in favour of `SharePlus`. This is a cosmetic warning and does not affect functionality. |
| Emulator AES performance | Encryption/decryption is CPU-intensive; may be slow on low-spec emulators. Physical devices recommended. |
| Up Next section | Shows placeholder cards — live recommendations via the API require project quota above the free tier limit. |
| PiP on some Android versions | PiP requires API level 26+. Will degrade gracefully on older devices. |

---

## 🔐 Security Implementation Details

### API Key Protection
- The YouTube API key is stored in a `.env` file loaded at runtime via `flutter_dotenv`.
- The key is **never compiled directly into Dart source files**.
- `.env` is excluded from version control via `.gitignore`.

### AES-256 Video Encryption
Downloaded videos are encrypted before being saved to disk:

```
Download → Write temp file → Encrypt with AES-256-CBC → Save as .encvid → Delete temp file
```

#### Encryption Flow
1. A **random 256-bit AES key** and **random 128-bit IV** are generated per video.
2. The key+IV are stored securely in **Flutter Secure Storage** (Android Keystore-backed on Android ≥ 6.0).
3. The video is encrypted in chunks and saved with the `.encvid` extension.
4. A **SHA-256 hash** of the original file is stored alongside the key for integrity verification.

#### Decryption Flow (for playback)
1. The per-video key+IV are retrieved from Secure Storage.
2. The `.encvid` file is decrypted to a temporary file in the app's cache directory.
3. The decrypted temp file is played and deleted after the session.
4. If SHA-256 hash mismatch is detected, the file is flagged as corrupt and a recovery prompt is shown.

#### Key Management
- Each video has its own unique key (no shared keys).
- Keys are identified by `videoId` and stored under a namespaced key in Secure Storage.
- Deleting a video also deletes its Secure Storage key entry.

#### Threat Model — What's Protected
| Threat | Mitigation |
|--------|-----------|
| Direct file access by another app | `.encvid` files are stored in app-private storage |
| APK reverse-engineering for keys | Keys not in source; stored in Android Keystore |
| File copying from rooted device | Videos unplayable without the Keystore-backed key |
| Corrupt files | SHA-256 hash checked before playback |

---

## 🏗️ Architecture Overview

```
lib/
├── core/              # Constants, error handling, network, DI config
├── data/
│   ├── datasources/   # Remote (YouTube API) & local (Hive) data sources
│   ├── models/        # JSON-parsable extensions of domain entities
│   ├── repositories/  # Implementations of domain repository interfaces
│   └── services/      # AES encryption, key management, background download
├── domain/
│   ├── entities/      # Pure Dart business objects (Video, Playlist, …)
│   ├── repositories/  # Abstract repository interfaces
│   └── usecases/      # Single-responsibility use cases
└── presentation/
    ├── app/           # App root, theme, localisation setup
    ├── bloc/          # BLoC / Cubit state management per feature
    ├── pages/         # Full-screen page widgets
    └── widgets/       # Reusable UI components
```

---

## 📸 Screenshots

### 🔐 Authentication

| Sign In (Email) | Sign In (Phone) | Sign Up |
|:-:|:-:|:-:|
| ![Sign In Email](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772176058.png) | ![Sign In Phone](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772176060.png) | ![Sign Up](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772176075.png) |

---

### 🏠 Splash & Home Feed

| Splash Screen | Home Feed |
|:-:|:-:|
| ![Splash](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175424.png) | ![Home Feed](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175429.png) |

---

### 📹 Shorts & Watch Page

| Shorts Player | Watch Page & Comments |
|:-:|:-:|
| ![Shorts](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175440.png) | ![Watch Page](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175606.png) |

---

### 📡 Subscriptions

| Subscriptions Feed |
|:-:|
| ![Subscriptions](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175445.png) |

---

### 📚 Library / Profile

| Profile (No History) | Profile (With History & Playlists) | Edit Profile (Light) | Edit Profile (Dark) |
|:-:|:-:|:-:|:-:|
| ![Profile Empty](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175452.png) | ![Profile History](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772176013.png) | ![Edit Profile Light](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175522.png) | ![Edit Profile Dark](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175997.png) |

---

### 💾 Downloads

| Downloads Page (Encrypted Video) |
|:-:|
| ![Downloads](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175618.png) |

---

### ⚙️ Settings

| Settings (Light Mode) | Settings (Dark Mode) | Language Picker | Sign Out Dialog |
|:-:|:-:|:-:|:-:|
| ![Settings Light](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175530.png) | ![Settings Dark](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175539.png) | ![Language](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175541.png) | ![Sign Out](https://raw.githubusercontent.com/ShithinCherathuparambil/youtube_clone/main/assets/screenshorts/Screenshot_1772175545.png) |

---

## 📦 APK Download

**[⬇️ Download Youtube Clone.apk](https://github.com/ShithinCherathuparambil/youtube_clone/raw/main/assets/apk/Youtube%20Clone.apk)** (~63.9 MB)

Or share the link above to sideload on any Android device (enable *Install from unknown sources* in device settings).

---

*Built with ❤️ using Flutter 3.41.2*
