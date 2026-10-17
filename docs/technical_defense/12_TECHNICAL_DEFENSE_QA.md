# 12 — Technical Defense Q&A

> **Last audited:** 2026-10-14 · **Updated:** 2026-10-18 (offline mode removed; Chapter 8 is now *Sessions and tokens*). 96 questions in 16 chapters. Each answer is short enough to say aloud and points to the code (paths relative to `lib/`). Learn the **bold** sentence first.

---

## Chapter 1 — Project overview

**1. What is TaskFlow mobile?**
**A worker app: see assigned tasks, do them step by step, and submit proof.** Admins use a separate web dashboard.

**2. Who are the users and what can they do?**
Workers (signed-in employees). They view, start and complete tasks, comment, get notifications, and manage their profile. Role is shown but the app doesn't restrict by role; the backend does.

**3. What are the main technologies?**
Flutter/Dart, Riverpod 2.6 (state + DI), GoRouter 14 (navigation), Dio 5 (HTTP), secure storage + SharedPreferences, Firebase Cloud Messaging, gen-l10n (English/Arabic).

**4. How big is the code base?**
About 177 Dart files in `lib/` (excluding generated l10n), 12 feature folders, 9 test files with 144 passing test cases.

**5. What's the most technically interesting part?**
**Silent session renewal and live updates.** A 15-minute access token is renewed with a rotating refresh token without the user noticing (`core/network/api_interceptor.dart`), and admin changes arrive instantly over Server-Sent Events (`features/realtime/`).

**6. What would you improve first?**
HTTPS and release signing (needed to ship), iOS configuration, and backend-side statistics instead of computing them from loaded pages.

## Chapter 2 — Architecture

**7. Which architecture did you use?**
**Feature-first folders with layers: screens → Riverpod notifiers → repositories → remote data sources → Dio.** Clean-architecture-inspired, without a use-case layer.

**8. Why feature-first instead of layer-first?**
Everything about "tasks" lives in `features/tasks/`. It's easier to find code and change one feature without touching others.

**9. What does a repository do here?**
It is the contract between state and data. `TaskRepositoryImpl` calls the remote data source and combines calls when needed, e.g. `getTasksInRange` loads every page of a month for the calendar.

**10. Why abstract repository interfaces?**
Notifiers depend on `TaskRepository`, not the implementation, so tests can swap in fakes. See `domain/repositories/task_repository.dart`.

**11. Where is business logic?**
Mostly in notifiers (`TasksController`, `TaskDetailsController`), the interceptor (session renewal) and pure functions (`HomeOverview.fromTasks`).

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
With a token: unreachable or 5xx → error panel with Retry, tokens kept. Without a token → Login.

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
`AuthController._clearUserData()` calls `ref.invalidate` on every per-user provider. Nothing user-related is stored on the phone.

## Chapter 6 — Authentication

**32. How does login work?**
**`POST /auth/login` (with `client: "mobile"`) → access + refresh tokens saved in secure storage → per-user state reset → auth state true → router sends to Home → push registration.**

**33. Where is the token stored and why?**
`flutter_secure_storage`, keys `accessToken` and `refreshToken`. It's encrypted by Android Keystore / iOS Keychain; SharedPreferences isn't.

**34. How is the token sent?**
`ApiInterceptor.onRequest` adds `Authorization: Bearer <token>` to every request.

**35. Is there a refresh token?**
Yes. The access token lasts 15 minutes; the refresh token lasts 30 days from its last use and is replaced on every refresh. See Chapter 8.

**36. What happens on 401 mid-session?**
**The interceptor renews the token and resends the request; the user sees nothing.** Only if the refresh is rejected are the tokens deleted and the user sent to login.

**37. What if a different user logs in on the same phone?**
Nothing of the previous user is saved on the phone, and `_clearUserData` invalidates every per-user provider at login, so the new user starts clean.

## Chapter 7 — Networking

**38. Why Dio over `http`?**
**Interceptors, timeouts, multipart, cancel tokens, streaming responses.** All are used here.

**39. How many Dio instances?**
One (`dioProvider`). The interceptor also keeps a second `Dio` without interceptors, only for `POST /auth/refresh`, so a refresh can't trigger another refresh.

**40. How are errors handled?**
The interceptor maps every `DioException` to an `ApiException` with a `kind` (offline, timeout, server…). Data sources rethrow only `ApiException`; UI shows `error.localized(l10n)`.

**41. Why is connect timeout treated as "no connection"?**
The request never reached the server, so the user gets "No internet connection". A receive timeout is different: the request may have arrived, so it shows "Connection timed out" and is not resent automatically (to avoid duplicates).

**42. How is pagination done?**
`GET /tasks?page&limit=20`; `loadNextPage` when the user is within 300 px of the end; flags for the footer spinner/Retry.

**43. How do uploads work?**
Multipart `FormData` with `kind` (PHOTO/FILE) and the file → `POST /tasks/:id/attachments`.

## Chapter 8 — Sessions and tokens

**44. How long does a session last?**
**The access token lasts 15 minutes; it is renewed silently with a refresh token.** The refresh token lasts 30 days from its last use, so a worker who opens the app at least once a month stays signed in.

**45. What is this technique called?**
Silent token refresh with refresh-token rotation (a sliding session).

**46. How does the refresh work?**
A request gets 401 → `ApiInterceptor.onError` calls `POST /auth/refresh` with the refresh token → saves the new access and refresh tokens → resends the original request once with `dio.fetch`.

**47. What if three requests fail with 401 at the same time?**
They share one refresh: `_refreshing ??= _refresh()` keeps a single `Future` that all of them await. Otherwise the second request would reuse a refresh token that was just replaced. Tested in `session_test.dart`.

**48. Why is each refresh token single use?**
If a copied token is used after the real app has already replaced it, the server sees the reuse and ends every session of that user. A stolen refresh token stops working.

**49. When is the user sent to login?**
Only when the refresh is rejected: 30 days without using the app, a password reset, an account deactivated by an admin, or logout. A network error during refresh keeps the tokens.

**50. Why did you remove offline mode?**
A product decision: the app now always shows the server's current data. With no connection, screens show "No internet connection" with Retry. It also removed the unencrypted cache (a security finding) and a lot of code.

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
`calendarMonthTasksProvider(month)` fetches all pages (100 per page) for that month with `from/to`.

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

**81. Is any user data stored on the phone?**
Only the two tokens, in encrypted secure storage. Tasks, comments and the profile live in memory; SharedPreferences holds just theme, language and the onboarding flag.

**82. Are there secrets in the app?**
No API keys or passwords in Dart. The API URL comes from `--dart-define`. Firebase client config is normal app config.

**83. How is logout made safe?**
The push token is removed server-side first (while still authenticated), then `POST /auth/logout` revokes the refresh token, then both tokens and the in-memory state are cleared.

**84. Why is the WebView's JavaScript disabled?**
Legal pages are static HTML; disabling JS removes a script-injection surface.

**85. Can a worker see another worker's tasks?**
The app only shows what `GET /tasks` returns for the token; filtering is enforced by the backend.

## Chapter 15 — Testing and quality

**86. What's tested?**
144 cases: boot timing, session and token refresh (8), realtime (7), pagination (5), on-time rate (5), signup flow, layout robustness.

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
