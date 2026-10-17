# 01 — Dependencies

> **Last audited:** 2026-10-14 · Source: `pubspec.yaml` (declared constraint) and `pubspec.lock` (version actually resolved).
> Usage was established by searching every `import 'package:<name>/…'` in `lib/` and `test/`. A package is called **unused** only when no import and no generated file (`*.g.dart`, `*.freezed.dart`) exists.

Dart SDK constraint: `sdk: ^3.13.3`. Flutter used at audit time: **3.47.3 (stable)**.

---

## 1. Summary table

| Package | Declared | Resolved | Role | Status |
|---|---|---|---|---|
| `flutter` (SDK) | sdk | — | UI framework | Essential |
| `flutter_riverpod` | ^2.0.0 | 2.6.1 | State management + dependency injection | Essential (68 files) |
| `go_router` | ^14.0.0 | 14.8.1 | Navigation / routing | Essential |
| `dio` | ^5.7.0 | 5.11.1 | HTTP client | Essential |
| `flutter_secure_storage` | 11.2.0 (pinned) | 11.2.0 | Stores the login token encrypted | Essential |
| `shared_preferences` | ^2.3.2 | 2.5.5 | Settings, onboarding flag, offline cache | Essential |
| `firebase_core` | ^3.8.1 | 3.15.2 | Starts Firebase | Needed for push |
| `firebase_messaging` | ^15.1.3 | 15.2.10 | Push notifications (FCM) | Needed for push |
| `flutter_local_notifications` | ^18.0.1 | 18.0.1 | Shows pushes while the app is open; notification channel | Needed for push |
| `webview_flutter` | ^4.10.0 | 4.14.1 | Legal pages inside the app | Feature-specific |
| `url_launcher` | 6.3.2 (pinned) | 6.3.2 | Open attachments / legal page in external apps | Feature-specific |
| `google_fonts` | ^6.2.1 | 6.3.3 | Nunito typeface | Visual |
| `flutter_localizations` (SDK) | sdk | — | Material/Cupertino translations, RTL | Essential for Arabic |
| `intl` | any | 0.20.3 | Date formatting per locale (+ required by gen-l10n) | Essential |
| `image_picker` | ^1.2.3 | 1.2.3 | Camera / gallery photos | Feature-specific |
| `file_picker` | ^13.1.0 | 13.1.0 | Pick documents for task completion | Feature-specific |
| `table_calendar` | ^3.3.0 | 3.3.0 | Month calendar widget | Feature-specific |
| `path_provider` | ^2.1.6 | 2.1.6 | App documents folder for offline uploads | Feature-specific |
| dev: `flutter_test` | sdk | — | Tests | Dev |
| dev: `flutter_lints` | ^6.0.0 | 6.0.0 | Lint rules (`analysis_options.yaml`) | Dev |
| dev: `flutter_launcher_icons` | ^0.14.4 | 0.14.4 | Generates launcher icons from `assets/icons/taskflow_icon.png` | Dev (run manually) |

> **Removed on 2026-10-14:** `freezed_annotation`, `json_annotation`, `cupertino_icons`, `build_runner`, `freezed`, `json_serializable`. After removal: `flutter pub get` OK, `flutter analyze` clean, 149 tests pass, and every remaining package kept its version.
>
> **How they were found to be unused:** there is no `@freezed`, `@JsonSerializable`, `part '….g.dart'`, or any generated `*.g.dart` / `*.freezed.dart` file in `lib/`. All models use hand-written `fromJson` (e.g. `TaskModel.fromJson` in `features/tasks/data/models/task_model.dart`).

---

## 2. Package by package

### flutter_riverpod (2.6.1)
- **Simple:** a way for any screen to get shared data and services without passing them through every constructor.
- **Why TaskFlow needs it:** the task list, profile, notifications, settings, auth state, offline queue, Dio client and repositories are all shared objects.
- **Where:** 68 files. Core examples: `ProviderScope` in `main.dart`; `authControllerProvider` (`AsyncNotifierProvider`) in `features/auth/providers/auth_provider.dart`; `ConsumerWidget` screens such as `HomeScreen`.

- **APIs used:** `Provider`, `NotifierProvider`, `AsyncNotifierProvider`, `.family`, `.autoDispose`, `StateProvider`, `FutureProvider`, `ref.watch`, `ref.read`, `ref.listen`, `ref.invalidate`, `ref.exists`, `ref.onDispose`, `overrideWithValue` (in `main.dart` and tests).
- **If removed:** nothing compiles — every screen and service is created by a provider.
- **Example from the code:**
  ```dart
  // lib/features/home/providers/home_provider.dart
  final homeOverviewProvider = Provider<AsyncValue<HomeOverview>>((ref) {
    return ref.watch(tasksControllerProvider).whenData(HomeOverview.fromTasks);
  });
  ```
- **Defense Q:** *Why Riverpod and not setState?* — Home, Tasks and Calendar all read the same task list. With `setState` I'd have to pass it down manually and keep copies in sync; with Riverpod one `tasksControllerProvider` is the single source and every screen watching it rebuilds when it changes. See [doc 03](03_ARCHITECTURE_AND_RIVERPOD.md).

### go_router (14.8.1)
- **Simple:** turns URLs like `/app/tasks/123` into screens, and decides where a user may go.
- **Where:** `app/router/app_router.dart` (`GoRouter`, `GoRoute`, `StatefulShellRoute.indexedStack`, `redirect`), plus `context.go/push/pop` in ~20 screens/widgets; `FcmService` uses the router object to navigate from a push tap.
- **Supports:** bottom navigation that keeps each tab's history, task details by id, login guard.
- **If removed:** no navigation at all.
- **Defense Q:** *How does a task id reach the details screen?* — The route is `/app/tasks/:id`; the builder reads `state.pathParameters['id']` and passes it to `TaskDetailsScreen(taskId: …)`. See [doc 02](02_STARTUP_AND_NAVIGATION.md).

### dio (5.11.1)
- **Simple:** sends HTTP requests to the server and returns the replies.
- **Where:** created **once** in `core/network/dio_client.dart` (`dioProvider`) with `BaseOptions(baseUrl, connectTimeout 15 s, receiveTimeout 15 s, JSON header)` and `ApiInterceptor`. Used by every `*_remote_data_source.dart`, by `FcmService` (device token), by `RealtimeRemoteDataSource` (streamed response), and a separate tiny `Dio` in `ConnectivityController.probe()`.
- **Features used:** interceptors (`onRequest` adds `Authorization: Bearer`, `onError` maps to `ApiException`), `FormData`/`MultipartFile` uploads, `ResponseType.stream`, `CancelToken`.
- **If removed:** no server communication.
- **Defense Q:** *Where is the token added?* — In `ApiInterceptor.onRequest`, read from secure storage before every request. See [doc 05](05_API_AND_DIO.md).

### flutter_secure_storage (11.2.0)
- **Simple:** an encrypted safe on the phone (Android Keystore-backed) for secrets.
- **Where:** only `core/storage/secure_storage_service.dart` (`SecureStorageService` with `read/write/delete/deleteAll`). Keys used: `StorageKeys.accessToken` (written at login), `StorageKeys.refreshToken` (only ever deleted — never written).
- **If removed:** the token would need to live in plain storage (insecure) or the user would log in every launch.
- **Defense Q:** *Why not SharedPreferences for the token?* — SharedPreferences is a plain XML file on Android; the JWT is a credential, so it goes in the encrypted store.

### shared_preferences (2.5.5)
- **Simple:** a small key/value file for non-secret settings.
- **Where:** loaded once in `main.dart` (`SharedPreferences.getInstance()`) and injected via `sharedPreferencesProvider.overrideWithValue(prefs)`; wrapped by `LocalStorageService` (`core/storage/local_storage_service.dart`).
- **Stores:** `themeMode`, `localeCode`, `hasSeenOnboarding`, and every `offline.*` key (task cache, profile, notifications, comments, sync queue) via `OfflineStore`.
- **Why loaded before `runApp`:** settings, onboarding flag and offline cache can then be read **synchronously** by providers.
- **Defense Q:** *Is the offline cache encrypted?* — No. It is plain JSON in SharedPreferences (tasks, comments, profile). See [doc 10](10_SECURITY_AND_RELIABILITY_AUDIT.md).

### firebase_core (3.15.2) · firebase_messaging (15.2.10) · flutter_local_notifications (18.0.1)
- **Simple:** Firebase gives each phone a push address (FCM token); the app sends it to the backend so the server can push "New task assigned". The local-notifications plugin draws the notification when the app is open.
- **Where:** `core/notifications/firebase_bootstrap.dart` (starts Firebase once, in the background), `fcm_service.dart` (permission, token, listeners, tap routing), `notification_service.dart` (channel `taskflow_updates`, foreground display, background handler).
- **If removed:** no push; the in-app notification list still works (it is a normal API call).
- **Platform:** Android has `android/app/google-services.json` and the Google Services Gradle plugin. **iOS has no `GoogleService-Info.plist`**, so push cannot work on iOS as configured. Details in [doc 09](09_FIREBASE_DEVICE_AND_ANDROID.md).

### webview_flutter (4.14.1) · url_launcher (6.3.2)
- **webview_flutter:** shows the Terms / Privacy / About pages from the backend inside the app — `features/about/widgets/legal_webview_screen.dart` (`WebViewController`, `JavaScriptMode.disabled`, `NavigationDelegate` for progress/errors).
- **url_launcher:** "Open in browser" on the legal page, and opening an attachment in an external app (`features/tasks/widgets/attachments_section.dart`, `LaunchMode.externalApplication`).

### google_fonts (6.3.3)
- **Where:** `app/theme/app_text_styles.dart` (`GoogleFonts.nunito(...)`) and `app/theme/app_theme.dart` (`GoogleFonts.nunitoTextTheme`). Tests disable network font fetching (`GoogleFonts.config.allowRuntimeFetching = false`).
- **Note:** the font files are **not bundled**; google_fonts downloads Nunito at runtime on first use and caches it. Without internet on first launch, text falls back to the system font. (Inferred from the absence of font assets in `pubspec.yaml`.)

### flutter_localizations + intl (0.20.3)
- **Where:** `app/app.dart` registers `AppLocalizations.delegate` and the `Global*Localizations` delegates; `l10n.yaml` drives `flutter gen-l10n` into `lib/l10n/gen/`. `intl`'s `DateFormat` formats dates per locale in 7 files (e.g. `task_card.dart`, `welcome_header.dart`, `date_utils.dart`).
- **Supports:** English and Arabic, including right-to-left layout. See [doc 08](08_UI_AND_DESIGN_SYSTEM.md).

### image_picker (1.2.3) · file_picker (13.1.0) · path_provider (2.1.6)
- **image_picker:** camera/gallery chooser (`core/widgets/photo_source_sheet.dart`), task photos (`complete_task_screen.dart`), profile photo (`profile_screen.dart`). Photos are resized (`maxWidth/maxHeight: 2000`, `imageQuality: 85`).
- **file_picker:** documents for completion (`pdf, doc, docx, xls, xlsx, txt, csv`) in `complete_task_screen.dart` (`FilePicker.pickFiles`).
- **path_provider:** `core/offline/offline_files.dart` copies a photo/file into the app's documents folder when it must wait for an offline upload (`getApplicationDocumentsDirectory`).
- All picked files **are really uploaded** (multipart) — see [doc 06 §Completion](06_FEATURES_WALKTHROUGH.md).

### table_calendar (3.3.0)
- **Where:** only `features/calendar/widgets/task_month_calendar.dart` (`TableCalendar<CalendarEntry>`, `eventLoader`, custom `markerBuilder`, locale-aware first day of week).

### Dev tools
- **flutter_lints** — rule set used by `flutter analyze`.
- **flutter_launcher_icons** — config at the bottom of `pubspec.yaml`; generates Android/iOS launcher icons when run with `dart run flutter_launcher_icons`.

---

## 3. Built-in Flutter/Dart features worth naming separately

| Built-in | Used for | Example |
|---|---|---|
| `MaterialApp.router` | Connects GoRouter, themes, locales | `app/app.dart` |
| Material 3 `ThemeData` / `ColorScheme` | Design system | `app/theme/app_theme.dart` |
| `AppLifecycleListener` | Refresh on resume; pause live updates in background | `notification_bell_button.dart`, `connectivity_provider.dart`, `realtime_provider.dart` |
| `dart:convert` (`jsonEncode/jsonDecode`, `utf8`, `LineSplitter`) | Offline cache, SSE parsing | `offline_store.dart`, `realtime_remote_data_source.dart` |
| `dart:async` (`Timer`, `StreamSubscription`, `Completer`-style memoized `Future`) | Probing, debounce, Firebase bootstrap | `connectivity_provider.dart`, `realtime_provider.dart`, `firebase_bootstrap.dart` |
| `dart:io` (`File`, `Directory`) | Copy files for offline upload | `offline_files.dart` |
| `CustomPainter` | Animated splash/login background shapes | `splash_background_painter.dart` |

---

## 4. Cleanup done

The six unused packages listed above were removed from `pubspec.yaml` on 2026-10-14. Every package now declared is used. If asked why there is no `freezed`/`json_serializable`: models are small and parsed by hand in `fromJson`, so code generation would add build steps without much benefit.
