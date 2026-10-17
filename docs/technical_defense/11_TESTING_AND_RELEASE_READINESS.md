# 11 — Testing and Release Readiness

> **Last audited:** 2026-10-14 · **Updated:** 2026-10-18. `flutter test` → **144 passed, 0 failed** (~26 s). `flutter analyze` → **No issues found**.

---

## 1. Test inventory

The source has **39 test declarations** in 9 files. Loops in `ui_robustness_test.dart` and `signup_request_test.dart` run them per language (en/ar), theme (light/dark) and screen, which gives **144 executed cases**. (On 2026-10-18 the 10 offline-sync tests were deleted with offline mode, and the 3 old session tests were replaced by 8 in `session_test.dart`.)

| File | Declarations | What it proves | Kind |
|---|---|---|---|
| `widget_test.dart` | 1 | App boots: splash first frame visible, still on splash at 5 s, onboarding after 6 s on first launch | Widget (full app) |
| `session_test.dart` | 8 | **Startup:** no connection → error + Retry, token kept; session rejected → both tokens removed; server error → error + Retry, token kept. **Refresh:** expired access token → renewed and request resent; 3 requests failing together share **one** refresh; refresh rejected → tokens deleted + sent to login; no connection during refresh → tokens kept; wrong password at login is not treated as an expired session | Unit, with a fake HTTP server (`HttpClientAdapter`) |
| `realtime_test.dart` | 7 | SSE parser; connects when shell shown; admin change reloads once per burst; notification event reloads; heartbeats ignored; reconnect + catch-up; 401 stops retrying | Unit with fake stream |
| `tasks_pagination_test.dart` | 5 | Loads 20 at a time until the last page; a failed page keeps the list and can be retried; pull-to-refresh restarts at page 1; a background reload (live updates) keeps every loaded page; < 20 tasks → one page, no "Load more" | Unit (controller) |
| `home_overview_test.dart` | 5 | On-time rate rules (late, overdue, cancelled, window, none) | Pure unit |
| `signup_request_test.dart` | 5 (+ looped layout cases) | Correct code → "Request sent"; wrong code → retry; existing account explained; form validates every field; layouts in en/ar × light/dark | Widget |
| `ui_robustness_test.dart` | 6 (looped) | Key screens on 360 dp at 1.3× text in en/ar × light/dark, no overflow; contrast checks | Widget |
| `calendar_screen_test.dart` | 1 (looped per locale/case) | Calendar renders with tasks (guards the earlier `AsyncValue` crash) | Widget |
| `login_layout_test.dart` | 1 (looped per screen height) | Login sheet reaches the bottom edge at several heights | Widget |

How the tests isolate the app: `ProviderScope(overrides: [...])` replaces `sharedPreferencesProvider` (with `SharedPreferences.setMockInitialValues`) and data sources with fakes. No real network is used.

---

## 2. What is not tested

| Gap | Risk |
|---|---|
| No `integration_test/` (on-device end-to-end) | Real plugins (camera, secure storage, FCM, WebView) are never run in tests |
| Login and logout screens end to end | Covered only at repository/interceptor level (`session_test.dart`) and by a manual backend run |
| Task completion screen (`CompleteTaskScreen` UI, `_canSubmit`) | No test |
| `ApiInterceptor` error mapping (non-401 cases) | Mapping table (doc 05) has no unit test; the 401/refresh path is tested |
| Profile edit / avatar / password | No tests |
| Notifications screen and `NotificationOpener` routing | No tests |
| FCM / local notifications | Not testable without a device; untested |
| Golden (screenshot) tests | None |
| Coverage report | Not generated (`flutter test --coverage` not run in this audit) |

---

## 3. Manual test checklist (before a demo)

1. Fresh install → splash ~6 s → onboarding → login.
2. Wrong password → server message; airplane mode → "No internet connection".
3. Login → Home KPIs; Tasks tab paging (scroll past 20); search; filter "Overdue".
4. Open task → Start → Complete with photo (camera + gallery), file, checklist, notes → Submit.
5. Stay in the app more than 15 minutes, then refresh a list → it loads normally (the token was renewed silently).
6. Admin changes a task in the dashboard → app updates without refresh (SSE).
7. Push: app in background → tap → opens the task.
8. Switch to Arabic → RTL layout; dark mode.
9. Legal pages open; "open in browser" works.
10. Log out → login screen; log in again works.

---

## 4. Release readiness

| Area | State | Blocking? |
|---|---|---|
| Static analysis | Clean | — |
| Unit/widget tests | 144 pass | — |
| HTTPS / cleartext | Release can't call `http://` API (doc 10 H1) | **Yes** |
| Signing | Debug key (H2) | **Yes** (store release) |
| Application id | `com.example…` (H2) | **Yes** (store release) |
| Version | `pubspec.yaml` `version:` drives `versionCode`/`versionName` | Bump before each release |
| API URL | Compile-time `--dart-define=API_BASE_URL=…` | Must be set to the production URL |
| iOS | Missing permission strings and Firebase file (H3) | Yes for iOS |
| Obfuscation | Not configured; optional `--obfuscate --split-debug-info=…` | No |
| Crash reporting | None (no Crashlytics/Sentry) | No, but recommended |
| Privacy policy | Served from backend (`/legal/page?slug=privacy`) | — |

### Build commands (for reference; not run by the audit)
```bash
# Debug on a phone on the same Wi-Fi
flutter run --dart-define=API_BASE_URL=http://<PC-IP>:3000

# Release APK (needs HTTPS API, or a network security config, and a real signing key)
flutter build apk --release --dart-define=API_BASE_URL=https://<api-host>

# Play Store bundle
flutter build appbundle --release --dart-define=API_BASE_URL=https://<api-host>
```

**Verdict:** ready for a **debug demo** on the LAN. **Not yet ready** for a release/store build until H1 and H2 are fixed.
