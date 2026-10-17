# 10 — Security and Reliability Audit

> **Last audited:** 2026-10-14 · **Updated:** 2026-10-18 (M1 and M2 resolved; I3 replaced; two new low findings). Review of `taskflow_mobile`. Secrets are **not** reproduced.
>
> Severity: **High** = blocks a real release or can lose/expose data · **Medium** = real weakness, workaround exists · **Low** = quality / hygiene · **Info** = worth knowing.
>
> Important framing for the defense: the app **works as designed in debug on the LAN**. These findings are about moving to production.

---

## Summary

| ID | Severity | Finding | Status |
|---|---|---|---|
| H1 | High | Release build cannot use cleartext HTTP; API default is `http://` | Confirmed |
| H2 | High | Release signed with the debug key; `applicationId` is `com.example.taskflow_mobile` | Confirmed |
| H3 | High (iOS only) | iOS lacks camera/photo usage strings and Firebase config | Confirmed |
| ~~M1~~ | — | ~~No global handling of 401 during a session~~ | **Resolved 2026-10-18** (silent refresh; session end → login) |
| ~~M2~~ | — | ~~Offline cache stored unencrypted in SharedPreferences~~ | **Resolved 2026-10-18** (offline mode removed; no user data stored) |
| M3 | Medium | Home statistics and task search use only loaded pages | Confirmed |
| M4 | Medium | Attachments upload before submit; abandoned uploads stay on server | Confirmed (mobile side) |
| M5 | Medium | API traffic is plain HTTP (no TLS) in the current setup | Confirmed |
| L1 | Low | Hard-coded English strings | Confirmed |
| L2 | Low | `state.extra!` for the signup-verify route can throw | Confirmed |
| L3 | Low | Font downloaded at runtime | Confirmed |
| L4 | Low | Dead files | Confirmed |
| L6 | Low | `debugPrint` logs error details | Confirmed |
| L7 | Low | Secure storage read on every request | Confirmed |
| L8 | Low | A write that hits a receive timeout is not resent | Confirmed (deliberate) |
| L9 | Low | `minPhotosRequired` / `minFilesRequired` not enforced in the app | Confirmed (deliberate) |
| L10 | Low | When the server ends a session, the device's push token is not removed from the backend | Confirmed |
| L11 | Low | If the app is killed between "server rotated the refresh token" and "app saved it", the user must log in again | Inferred |
| I1 | Info | Attachment thumbnails load public `/uploads` URLs without auth | Confirmed (mobile side) |
| I2 | Info | Server error texts shown as received (backend language) | Confirmed |
| I3 | Info | Dashboard sessions still use one long-lived JWT (mobile uses 15-minute tokens) | Confirmed (backend) |
| I4 | Info | The app needs a connection for everything (no offline mode) | Confirmed (design decision) |

---

## High

### H1 — Release build can't reach an HTTP backend
- **Evidence:** `android/app/src/debug/AndroidManifest.xml` has `android:usesCleartextTraffic="true"`; `main` and `profile` manifests don't; no `networkSecurityConfig`. Default `ApiConstants.baseUrl` is `http://192.168.0.101:3000`.
- **Impact:** release APK → every call fails as `connectionError` → login shows "No internet connection".
- **Fix:** HTTPS for the API (production), or a `network_security_config.xml` allowing cleartext only for the dev host.

### H2 — Release signing and package id
- **Evidence:** `build.gradle.kts`: `release { signingConfig = signingConfigs.getByName("debug") }`, `applicationId = "com.example.taskflow_mobile"`.
- **Impact:** can't publish to Play; anyone with the default debug keystore could sign an "update"; the id can't change after publishing.
- **Fix:** own upload keystore via `key.properties` (kept out of source control), real id such as `com.<org>.taskflow`.

### H3 — iOS not release-ready
- **Evidence:** no `NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`; no `GoogleService-Info.plist`.
- **Impact:** opening the camera/gallery crashes on iOS; no push on iOS.

---

## Medium

### M1 — Resolved: session expiry
Before: a 1-year token, and a 401 mid-session only showed an error message.
Now: 15-minute access token renewed silently by `ApiInterceptor` (`POST /auth/refresh`, single-flight, resend once). If the refresh is rejected, both tokens are deleted and `AuthController.sessionExpired()` sends the user to login. Tested in `session_test.dart` and end-to-end against the backend (doc 04 §6).

### M2 — Resolved: unencrypted offline data
Offline mode was removed. SharedPreferences now holds only theme, language and the onboarding flag; tasks, comments and the profile live in memory only.

### M3 — Statistics from loaded pages only
- **Evidence:** `homeOverviewProvider` derives from `tasksControllerProvider` (page size 20); search/filter in `TasksScreen` filter the loaded list.
- **Impact:** with > 20 tasks, Home counts/on-time rate and search results can be incomplete until more pages load.
- **Fix:** backend summary/search endpoints.

### M4 — Orphaned uploads
- **Evidence:** `CompleteTaskScreen` uploads each photo/file as soon as it is picked.
- **Impact:** if the worker leaves without submitting, files stay attached on the server.
- **Trade-off:** immediate upload gives faster submit and per-file errors.

### M5 — No TLS
Same root cause as H1. Tokens and passwords travel in clear text on the network. Acceptable only on a trusted LAN for development. The 15-minute access token limits how long a sniffed token is useful, but the refresh token is also sent in clear — HTTPS is still required.

---

## Low

| ID | Detail | Location |
|---|---|---|
| L1 | English-only text: upload success/partial-failure snackbars, "Uploading…" | `complete_task_screen.dart`, `completion_form.dart` |
| L2 | `state.extra!` for the signup-verify route throws if opened without data. (`LoginResponseModel` now checks its fields and throws `ApiException.generic()` instead of a `TypeError`.) | `app_router.dart` |
| L3 | Nunito fetched at runtime by `google_fonts`; a first launch without internet shows the system font | `app_text_styles.dart`, `pubspec.yaml` |
| L4 | 8 never-imported files and a stale root `l10n/` (empty files, unused packages and offline-mode files were removed on 2026-10-14 / 2026-10-18) | doc 00, doc 01 |
| L6 | `debugPrint` prints error objects (no tokens or passwords printed — checked) | realtime, FCM, auth logout |
| L7 | `ApiInterceptor.onRequest` awaits secure storage every call; could cache in memory | `api_interceptor.dart` |
| L8 | Writes that time out after sending aren't resent (avoids duplicates); user must retry | `api_interceptor.dart` |
| L9 | Minimum photo/file counts exist on `Task` but aren't required to submit | `complete_task_screen.dart` (`_canSubmit`) |
| L10 | `sessionExpired()` can't call `DELETE /me/device-token` (no valid session), so the backend may still push that user's notifications to this phone until someone else logs in on it (the token is then reassigned) | `auth_provider.dart`, backend `registerDeviceToken` upsert |
| L11 | Refresh tokens are single use. If the app dies after the server rotated the token but before the new one was saved, the next refresh fails and the user logs in again. Rare; no data is lost | `api_interceptor.dart`, backend `RefreshTokenService` |

*(L5 — "refreshToken key never written" — no longer applies: the key is now used.)*

---

## Info
- **I1:** `Image.network(url)` sends no `Authorization` header, so the backend must serve `/uploads` publicly. Anyone with a file URL can open it (URLs are not guessable only if the backend uses random names — *Unverified*).
- **I2:** `ApiExceptionL10n.localized` shows 4xx `message` as received.
- **I3:** The dashboard does not send `client: 'mobile'`, so it still receives one JWT of `JWT_EXPIRES_IN_SECONDS` (1 year in the dev `.env`) and no refresh token. Moving it to refresh tokens is a dashboard change (outside mobile scope).
- **I4:** With no connection, every screen shows an error with Retry; nothing is saved for later. This was a product decision (2026-10-18).

---

## What is done well (say this too)

| Strength | Evidence |
|---|---|
| Both tokens in secure storage, not prefs | `secure_storage_service.dart` |
| 15-minute access tokens, rotating single-use refresh tokens, reuse detection | `api_interceptor.dart`; backend `refresh-token.service.ts` |
| Refresh tokens stored only as SHA-256 hashes on the server | backend `RefreshToken.tokenHash` |
| One refresh shared by parallel requests; resend at most once | `ApiInterceptor._refreshing`, `tokenRefreshRetried` |
| Password reset and deactivation end mobile sessions | backend `password-reset.service.ts`, `RefreshTokenService.refresh` |
| Password never stored | search of storage writes |
| No user data stored on the phone | SharedPreferences keys: theme, language, onboarding only |
| Logout removes the push token and revokes the refresh token **before** deleting local tokens | `AuthController.signOut`, `AuthRepositoryImpl.logout` |
| Per-user state wiped on login, logout and session end | `_clearUserData` |
| One error type for the UI; no raw Dio errors leak | `api_exceptions.dart` comment + data-source pattern |
| Startup can't hang: errors become a Retry panel | `SplashErrorPanel` |
| WebView with JavaScript disabled | `legal_webview_screen.dart` |
| Firebase failure can't break the app | `FirebaseBootstrap` returns false |
| No secrets in Dart code; API URL via `--dart-define` | `api_constants.dart` |

---

## Secrets check performed
- Searched `lib/` for keys/passwords: none hard-coded. The base URL is a LAN address, not a secret.
- `android/app/google-services.json` contains Firebase client identifiers (normally shipped inside the APK; not a server secret). Not reproduced here.
- Backend secrets are outside the mobile scope and are not quoted in any document.
