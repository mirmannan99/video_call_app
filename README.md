# Video Call App

A Flutter demo app showcasing:

- Authentication (demo credentials)
- Users list with pagination and offline cache (Hydrated Bloc)
- 1:1 video calling using Agora (RTC Engine 6.x)
- Screen sharing (mobile)
- Local notifications (mocked incoming call)

## Build & Run

Prerequisites:

- Flutter (stable channel, 3.35.6 or newer). Verify with:
  - `flutter --version`
  - `flutter doctor`
- Android Studio SDKs + Xcode (for iOS) installed

Install deps:

```bash
flutter pub get
```

Android (device/emulator):

```bash
flutter run -d android
```

iOS (simulator/device):

```bash
flutter run -d ios
```

Build artifacts:

- APK (split per ABI): `flutter build apk --release --split-per-abi`
- App Bundle (Play): `flutter build appbundle --release`
- iOS (no codesign): `flutter build ios --no-codesign`

CI: GitHub Actions builds Android APKs and an IPA (zipped) on pushes/PRs to
`main`.

---

## SDK Setup & App Configuration

### Agora (Video)

Update `lib/core/services/agora_config.dart` with your credentials:

```dart
class AgoraConfig {
	static const String appId = "<YOUR_AGORA_APP_ID>";
	static const String token = "<TEMP_TOKEN_OR_YOUR_TOKEN_SERVER_OUTPUT>";
	static const String channelName = "<channel-name>";
}
```

Notes:

- The repository uses a demo token/channel for quick start. Tokens expire; for
  production, generate tokens on a backend.
- Both caller and callee must use the same `channelName` to meet in the same
  room.

### Android

- Project uses Java 17 and core library desugaring (required by some plugins
  like local notifications)
  - See `android/app/build.gradle.kts`:
    - `compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17; isCoreLibraryDesugaringEnabled = true }`
    - `kotlinOptions { jvmTarget = "17" }`
    - Dependency:
      `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`
- Android 13+ (Tiramisu): the app requests the POST_NOTIFICATIONS runtime
  permission on startup when needed.

### iOS

- You need a signing team to run on a device.
- Microphone/Camera permissions are used by the Agora SDK (Flutter handles
  Info.plist entries via the plugin).
- Screen sharing on iOS typically requires a ReplayKit Broadcast Upload
  Extension for full functionality. This demo uses API calls compatible with
  mobile sharing; adding a ReplayKit extension is recommended for
  production-quality sharing.

---

## How to Use

1. Splash → Auth

- On launch you’ll see a splash animation, then an auth screen.
- Demo credentials: `test@example.com` / `password123`.

2. Users List

- Pull-to-refresh and infinite scroll.
- Offline cache: The last successfully loaded list persists with Hydrated Bloc
  and is shown when offline.

3. Video Call

- Controls: mic toggle, camera toggle, screen share, camera switch, speaker, end
  call.
- End call ends for both sides via a lightweight in-call data stream signal.
- If the remote turns off video, you’ll see a video-off placeholder.

4. Mock Incoming Call (Local Notification)

- In the users list, tap the phone icon to simulate an incoming call
  notification on the same device.
- Tap the notification → Incoming Call screen → Accept to enter the call.
- Android 13+: accept the notifications permission prompt to see the
  notification.

---

## Assumptions & Limitations

- Push notifications are mocked locally. There is no real signaling server or
  FCM/APNs integration yet. To notify a real “other device”, add Firebase Cloud
  Messaging (or your backend) and trigger
  `NotificationService.showIncomingCallNotification()` from the message handler.
- Agora token in the repo is for demo only and may expire. For production, issue
  time-bound tokens from your backend and never hardcode them in the client.
- iOS screen sharing: For a best-in-class experience, add a ReplayKit Broadcast
  Upload Extension and wire it with Agora per their docs.
- Platform view rendering: Avoid wrapping video views (AgoraVideoView) with
  opacity/clip effects (Opacity/ClipRRect/etc.) due to Impeller/platform view
  limitations.
- Navigation uses a global navigator key via GetIt. Ensure only a single
  `MaterialApp` sets the `navigatorKey`.
- Hydration: user list persists only the “loaded” state. Logout clears persisted
  auth and user state.

Additional notes:

- Offline cache scope: Only the Users list is cached (last successful snapshot).
  Pagination merges during online use; if a refresh fails, the prior successful
  state is preserved and shown. There’s no write-through or conflict resolution.
- Call model: Single 1:1 calls only; no group calls, lobby, or matchmaking.
  There’s no automatic rejoin/retry on network loss and no token renewal flow.
- Notifications: Local-only mock. No CallKit (iOS) / Telecom (Android) UI, no
  full-screen intent, and no VoIP push. Background/terminated behavior is
  limited without real push + platform integrations.
- Screen share behavior can vary by device/OEM. Long sessions may suspend when
  the app is backgrounded. For iOS production-quality sharing, ReplayKit is
  required; on Android, user consent prompts are expected.
- Permissions UX is minimal: the app requests camera/mic/notifications at
  runtime but doesn’t offer in-app toggles or detailed rationale screens.
- Performance: Platform views (video) are sensitive to composition. Avoid
  clipping/opacity/transforms around video surfaces; older devices may exhibit
  frame drops during screen share.
- CI artifacts: iOS build is produced without codesigning and cannot be
  installed on devices as-is; use your team/signing for distribution.
- Internationalization/accessibility: English-only UI, no RTL layout tuning, and
  no formal accessibility audit.

---

## Troubleshooting

- Android build error: “requires core library desugaring”

  - We’ve enabled it. Ensure Java 17 is used (CI uses Temurin 17); locally,
    update your JDK if needed.

- No notification on Android 13+

  - Accept the notifications permission prompt; ensure the app/channel isn’t
    silenced; test with the mock button in the list.

- Duplicate GlobalKey error on auth

  - Each screen owns its own `GlobalKey<FormState>`; don’t keep a global form
    key in providers/singletons.

- Riverpod ref unmounted error on call end
  - The screen caches the provider instance and avoids using `ref` during
    disposal; ensure you’re on the current code.

---

## Tested Environment (reference)

These are the versions used during final verification on macOS:

- Flutter: 3.35.6 (stable), Dart: 3.9.2, DevTools: 2.48.0
- Engine: d2913632a4
- macOS: 26.0.1 (darwin-arm64)
- Android toolchain: SDK Platform 36, Build-tools 36.1.0
- Java (Android Studio runtime): 21.0.3; Project toolchain targets Java 17
- Xcode: 26.0.1 (Build 17A400), CocoaPods: 1.16.2
- IDEs: Android Studio 2024.2, VS Code 1.105.1
- Devices tested: Android 15 emulator, iOS 26.0.1 device/simulator

Newer versions should work; if you see build issues, verify JDK (17+), Android
SDK (API 35/36), and that CocoaPods are installed for iOS.

---

## CI/CD

GitHub Actions (macOS) will:

- Set up Java 17 (Temurin) + Flutter stable
- `flutter pub get`
- Build Android APKs (split per ABI)
- Build iOS (no codesign) and zip IPA
- Publish artifacts to a GitHub release (`v1.0.<run_number>`) using a repo
  secret `GITHUB_TOKEN`

---

## Tech Stack

- Flutter, Dart
- State management: Riverpod (legacy ChangeNotifierProvider), Bloc and Hydrated
  Bloc for users list
- Networking: Dio
- Video: Agora RTC Engine 6.x
- Notifications: flutter_local_notifications

---

## License

This repository is for Assignment Purpose.
