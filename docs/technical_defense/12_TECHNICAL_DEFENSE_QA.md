# 12 — Technical Defense Q&A

> **Last audited:** 2026-10-14. 96 questions in 16 chapters. Each answer is short enough to say aloud and points to the code (paths relative to `lib/`). Learn the **bold** sentence first.

---

## Chapter 1 — Project overview

**1. What is TaskFlow mobile?**
**A worker app: see assigned tasks, do them step by step, submit proof, even offline.** Admins use a separate web dashboard.

**2. Who are the users and what can they do?**
Workers (signed-in employees). They view, start and complete tasks, comment, get notifications, and manage their profile. Role is shown but the app doesn't restrict by role; the backend does.

**3. What are the main technologies?**
Flutter/Dart, Riverpod 2.6 (state + DI), GoRouter 14 (navigation), Dio 5 (HTTP), secure storage + SharedPreferences, Firebase Cloud Messaging, gen-l10n (English/Arabic).

**4. How big is the code base?**
About 197 Dart files in `lib/` (excluding generated l10n), 13 feature folders, 10 test files with 149 passing test cases.

**5. What's the most technically interesting part?**
**Offline-first task work**: cached reads, an ordered write queue, automatic replay, and a failure list (`core/offline/`, `features/sync/`).

**6. What would you improve first?**
HTTPS and release signing (needed to ship), a global 401 handler, and backend-side statistics instead of computing them from loaded pages.

## Chapter 2 — Architecture

**7. Which architecture did you use?**
**Feature-first folders with layers: screens → Riverpod notifiers → repositories → remote/local data sources.** Clean-architecture-inspired, without a use-case layer.

**8. Why feature-first instead of layer-first?**
Everything about "tasks" lives in `features/tasks/`. It's easier to find code and change one feature without touching others.

**9. What does a repository do here?**
It decides where data comes from: server, cache or queue. Example: `TaskRepositoryImpl.getTasks` calls the API, saves the cache, and falls back to the cache when offline.

**10. Why abstract repository interfaces?**
Notifiers depend on `TaskRepository`, not the implementation, so tests can swap in fakes. See `domain/repositories/task_repository.dart`.

**11. Where is business logic?**
Mostly in notifiers (`TasksController`, `TaskDetailsController`), repositories (offline rules) and pure functions (`HomeOverview.fromTasks`).

**12. Why no use cases?**
Most operations are one repository call. A use-case layer would add files without adding logic. It's a conscious simplification.

## Chapter 3 — Startup

**13. What happens when the app starts?**
**`main()` initialises bindings, starts Firebase in the background, loads SharedPreferences, then runs `ProviderScope` → `TaskFlowApp` → `/splash`.**

**14. Why isn't Firebase awaited?**
On first launch it can take seconds; Android would show a blank launch screen. `FirebaseBootstrap.ensureInitialized()` is memoised and awaited only where push is needed.

**15. How does the splash decide where to go?**
`SplashController._resolveDestination`: onboarding not seen → onboarding; else `validateSession()` → home or login.

**16. Why 6 seconds?**
Branding requirement. `SplashScreen.minimumDuration` counts from the first drawn frame so slow devices still show the full animation.

**17. What if the server is down at startup?**
With a token: unreachable → Home in offline mode with cached data; 5xx → error panel with Retry. Without a token → Login.

**18. How is onboarding shown only once?**
`hasSeenOnboarding` flag in SharedPreferences, set by `OnboardingController.markSeen()`; not reset on logout.

## Chapter 4 — Navigation

**19. Why GoRouter?**
**Declarative routes, URL-style paths, redirect guards and a ready-made tab shell.** One file lists every screen: `app/router/app_router.dart`.

**20. How do you protect screens that need login?**
The `redirect`: not authenticated and on `/app/*` → `/login`; authenticated and on login/onboarding → home.

**21. How does the router know login state changed?**
`_RouterNotifier` listens to `authControllerProvider` and is the router's `refreshListenable`.

**22. How do the bottom tabs keep their state?**
`StatefulShellRoute.indexedStack`: each tab is a branch with its own navigator; `IndexedStack` keeps them alive.

**23. `go` vs `push`?**
`go` replaces the stack (tabs, after login, push taps); `push` adds a screen (task details) so Back returns.

**24. How do you pass data between screens?**
Path params (`/app/tasks/:id`), query params (`?focus=comments`) and `extra` objects (email for reset, `SignupDraft`).

## Chapter 5 — Riverpod

**25. Why Riverpod?**
**Compile-safe dependency injection and reactive state without `BuildContext`; easy overrides in tests.**

**26. `ref.watch` vs `ref.read`?**
`watch` subscribes and rebuilds; use it in `build`. `read` gets the value once; use it in callbacks and methods.

**27. What is `AsyncValue`?**
A union of loading, data and error. Screens use `.when(...)`. `valueOrNull` reads data without throwing.

**28. Why `AsyncNotifier` for tasks?**
It needs async loading **and** methods (`refresh`, `loadNextPage`, `updateStatus`) on the same state.

**29. What is `.family` used for?**
One state per task id: `taskDetailsControllerProvider(id)`, `taskCommentsControllerProvider(id)`.

**30. What is `.autoDispose` used for?**
State that should die with its screen: comments, calendar, and realtime, which must stop at logout.

**31. How do you reset state on logout?**
`AuthController._clearUserData()` calls `ref.invalidate` on every per-user provider; the offline store and queue are cleared too.

## Chapter 6 — Authentication

**32. How does login work?**
**`POST /auth/login` → access token saved in secure storage → per-user state reset → auth state true → router sends to Home → push registration.**

**33. Where is the token stored and why?**
`flutter_secure_storage`, key `accessToken`. It's encrypted by Android Keystore / iOS Keychain; SharedPreferences isn't.

**34. How is the token sent?**
`ApiInterceptor.onRequest` adds `Authorization: Bearer <token>` to every request.

**35. Is there a refresh token?**
No. Sessions last a year (backend setting). Expiry is detected at the next app start.

**36. What happens on 401 mid-session?**
Honest answer: **the message is shown; the user isn't logged out automatically.** Queued work is kept. Next start → login. A global 401 handler is the planned fix.

**37. What if a different user logs in on the same phone?**
`AuthController.login` compares the cached profile id; if different, it wipes the cache, queue and kept files.

## Chapter 7 — Networking

**38. Why Dio over `http`?**
**Interceptors, timeouts, multipart, cancel tokens, streaming responses.** All are used here.

**39. How many Dio instances?**
One (`dioProvider`), plus a separate short-timeout instance for the connectivity probe on purpose.

**40. How are errors handled?**
The interceptor maps every `DioException` to an `ApiException` with a `kind` (offline, timeout, server…). Data sources rethrow only `ApiException`; UI shows `error.localized(l10n)`.

**41. Why is connect timeout treated as offline?**
The request never reached the server, so it's safe to queue. Receive timeouts aren't queued; the request may have arrived.

**42. How is pagination done?**
`GET /tasks?page&limit=20`; `loadNextPage` when the user is within 300 px of the end; flags for the footer spinner/Retry.

**43. How do uploads work?**
Multipart `FormData` with `kind` (PHOTO/FILE) and the file → `POST /tasks/:id/attachments`.

## Chapter 8 — Offline mode

**44. How does the app work offline?**
**Reads come from a JSON cache; writes go into an ordered queue; the queue is replayed when the server is reachable.**

**45. Where is the cache?**
SharedPreferences under `offline.*` keys (`OfflineStore`). It's fast and loaded at startup.

**46. How do you know you're offline?**
No plugin: every Dio result reports reachability; while offline, `/config/locales` is probed every 15 s and on resume.

**47. How do you keep the order of changes?**
FIFO queue; once a task has a queued change, new changes for it are queued too (`_sendOrQueue`), so "start" never arrives after "complete".

**48. How does the UI show unsent changes?**
`_withPending` applies queued changes on top of the cached task; `PendingSyncBadge` and `SyncStatusBar` show pending state.

**49. What if the server refuses a queued change?**
4xx → removed from queue and listed as a `SyncFailure` in a sheet. Offline/timeout/5xx/401 → kept for later.

**50. Does the queue survive closing the app?**
Yes, persisted in `offline.queue`. Tested: "the queue survives an app restart".

## Chapter 9 — Tasks

**51. What task statuses exist?**
`assigned`, `inProgress`, `completed`, `overdue`, `cancelled` (`TaskStatus`).

**52. Which transitions can the worker make?**
Start (assigned/overdue → inProgress) and Complete (inProgress → completed). Cancel is admin-only.

**53. What does completion send?**
`PATCH /tasks/:id/complete` with notes and checklist results. Photos/files were already uploaded when picked.

**54. When can the user submit?**
`_canSubmit`: status in progress, checklist complete if required, no upload running.

**55. Are minimum photo counts enforced?**
No. The fields exist but the app keeps them optional. That's deliberate; I'd say so.

**56. How do search and filters work?**
Client-side over loaded tasks; search also matches the Arabic title; "Overdue" also includes tasks past their deadline.

## Chapter 10 — Home and calendar

**57. How are Home statistics calculated?**
`HomeOverview.fromTasks` derives them from the task list provider: one source of truth, no extra requests.

**58. What's the limitation?**
They cover loaded pages only (20 at first). A backend summary endpoint would fix it.

**59. Explain the on-time rate.**
Last 30 days: tasks completed by the deadline ÷ tasks whose outcome is known. Open-and-late counts as missed; cancelled or no-deadline tasks are excluded.

**60. How does the calendar load data?**
`calendarMonthTasksProvider(month)` fetches all pages for that month with `from/to`; offline it filters the cache.

**61. What was the calendar crash and fix?**
Reading `.value` of an `AsyncValue` in error state rethrew during build; replaced with `valueOrNull`.

## Chapter 11 — Notifications and realtime

**62. In-app vs push notifications?**
In-app: list from `GET /notifications` with read state and badge. Push: FCM message to the device even if the app is closed.

**63. How is the device registered for push?**
After login: permission → `getToken()` → `POST /me/device-token`; token refresh re-registers; logout → `DELETE` then `deleteToken()`.

**64. Foreground vs background push?**
Foreground: `onMessage` → local notification + list refresh. Background/terminated: system tray; taps handled by `onMessageOpenedApp` / `getInitialMessage`.

**65. Where does tapping a notification go?**
`NotificationOpener`: daily summary → calendar; comment → task with comments focused; unassigned → nowhere; else task details.

**66. How do live updates work?**
Server-Sent Events on `GET /events`; `RealtimeController` reloads what changed, debounced 400 ms, reconnecting with backoff 2/5/10/30 s.

**67. Why SSE and not WebSockets?**
One-way server→client notices are all we need; SSE is plain HTTP, simple to authenticate with the same Bearer token.

## Chapter 12 — UI, theme and localization

**68. How is the design kept consistent?**
**Tokens**: `AppColors`, `AppDimensions`, `AppTextStyles`, combined in `AppTheme` (Material 3).

**69. How do you handle color contrast?**
`AppColors.readable()` adjusts semantic colors per brightness to ≥ 5.4:1; darker secondary text in light mode.

**70. How does Arabic work?**
ARB files → generated `AppLocalizations`; Arabic flips layout to RTL; tasks show `titleAr` via `titleFor(languageCode)`.

**71. How do you test small screens?**
`ui_robustness_test.dart`: 360 dp at 1.3× text, en/ar, light/dark; overflow fails the test.

**72. Dark mode?**
Light/dark selector in settings, saved in prefs; light is the default.

**73. Which strings aren't translated?**
Upload result snackbars and "Uploading…" in the completion flow, plus server error texts.

## Chapter 13 — Dart/Flutter fundamentals

**74. Stateless vs stateful widget?**
Stateless = depends only on inputs; stateful = holds local mutable state with a lifecycle. Here app state is in Riverpod; `setState` is used only for UI details.

**75. Why check `mounted` after `await`?**
The widget may have been removed; using `context` or `setState` would throw.

**76. What does `const` give you?**
Compile-time constants are reused and skipped on rebuild: better performance.

**77. Future vs Stream?**
A single value later vs many values over time (SSE events, FCM messages).

**78. What is an extension method? Example?**
Adds methods to an existing type: `ApiException.localized(l10n)`, `context.readable(color)`.

**79. How does Flutter render?**
Widget tree → element tree → render tree; it paints itself with its own engine, not native widgets.

## Chapter 14 — Security

**80. Biggest security weakness?**
**No HTTPS in the current setup**, so tokens travel in clear on the LAN. Production needs TLS.

**81. Is the offline cache safe?**
It's inside the app sandbox but not encrypted. It's cleared on logout/account switch. Encrypting it is a listed improvement.

**82. Are there secrets in the app?**
No API keys or passwords in Dart. The API URL comes from `--dart-define`. Firebase client config is normal app config.

**83. How is logout made safe?**
The push token is removed server-side first (while still authenticated), then the tokens, cache, queue and in-memory state are cleared.

**84. Why is the WebView's JavaScript disabled?**
Legal pages are static HTML; disabling JS removes a script-injection surface.

**85. Can a worker see another worker's tasks?**
The app only shows what `GET /tasks` returns for the token; filtering is enforced by the backend.

## Chapter 15 — Testing and quality

**86. What's tested?**
149 cases: boot timing, session validation, offline queue (10), realtime (7), pagination (5), on-time rate (5), signup flow, layout robustness.

**87. How do you test without a server?**
`ProviderScope` overrides: fake data sources and mock SharedPreferences.

**88. Why not `pumpAndSettle` in the splash test?**
The splash has continuous animations; it never settles. Tests pump fixed durations.

**89. What isn't tested?**
On-device integration (camera, FCM, secure storage), interceptor mapping, profile and completion UI.

**90. Static analysis?**
`flutter_lints`; `flutter analyze` reports no issues.

## Chapter 16 — Release and Android

**91. Can you build a release APK today?**
**It builds, but can't reach the HTTP server**: Android blocks cleartext outside debug. HTTPS or a network security config is required.

**92. What about signing?**
Release currently uses the debug key and a `com.example` id. Both must change before a store upload.

**93. Which Android permissions does the app use?**
Internet, network state, notifications (Android 13+), wake lock, vibrate, FCM receive, all merged from plugins.

**94. Is iOS supported?**
The code is cross-platform, but iOS lacks the Firebase plist and camera/photo permission strings.

**95. How do you change the backend address?**
`flutter run --dart-define=API_BASE_URL=http://<ip>:3000`; it's a compile-time constant.

**96. How would you monitor crashes in production?**
None yet; I'd add Crashlytics or Sentry and replace `debugPrint` with structured logging.
