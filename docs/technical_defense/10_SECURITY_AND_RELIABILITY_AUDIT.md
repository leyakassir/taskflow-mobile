# 10 — Security and Reliability Audit

> **Last audited:** 2026-10-14. Read-only review of `taskflow_mobile`. Nothing was changed. Secrets are **not** reproduced.
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
| M1 | Medium | No global handling of 401 during a session | Confirmed |
| M2 | Medium | Offline cache and queue stored unencrypted in SharedPreferences | Confirmed |
| M3 | Medium | Home statistics and task search use only loaded pages | Confirmed |
| M4 | Medium | Attachments upload before submit; abandoned uploads stay on server | Confirmed (mobile side) |
| M5 | Medium | API traffic is plain HTTP (no TLS) in the current setup | Confirmed |
| L1 | Low | Hard-coded English strings | Confirmed |
| L2 | Low | Unchecked casts (`as String`, `state.extra!`) can throw on bad data | Confirmed |
| L3 | Low | Font downloaded at runtime | Confirmed |
| L4 | Low | Dead files and unused packages | Confirmed |
| L5 | Low | `refreshToken` key deleted but never written | Confirmed |
| L6 | Low | `debugPrint` logs error details | Confirmed |
| L7 | Low | Secure storage read on every request | Confirmed |
| L8 | Low | A write that hits a receive timeout is neither retried nor queued | Confirmed (deliberate) |
| L9 | Low | `minPhotosRequired` / `minFilesRequired` not enforced in the app | Confirmed (deliberate) |
| I1 | Info | Attachment thumbnails load public `/uploads` URLs without auth | Confirmed (mobile side) |
| I2 | Info | Server error texts shown as received (backend language) | Confirmed |
| I3 | Info | Long-lived JWT (1 year), no refresh/rotation | Inferred (backend config) |

---

## High

### H1 — Release build can't reach an HTTP backend
- **Evidence:** `android/app/src/debug/AndroidManifest.xml` has `android:usesCleartextTraffic="true"`; `main` and `profile` manifests don't; no `networkSecurityConfig`. Default `ApiConstants.baseUrl` is `http://192.168.0.101:3000`.
- **Impact:** release APK → every call fails as `connectionError` → app behaves as **offline** (login fails with the offline message).
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

### M1 — 401 in the middle of a session
- **Evidence:** `ApiInterceptor.onError` only maps errors; `AuthController` state = "token exists"; router trusts it. `SyncController` retries on 401; `RealtimeController` stops on 401.
- **Impact:** with an expired/revoked token the user sees server error messages until restarting the app (splash then sends them to login). Queued changes are preserved.
- **Fix:** in the interceptor, on 401 for an authenticated request → delete token and set auth state to false (router redirects to login).

### M2 — Unencrypted offline data
- **Evidence:** `OfflineStore` writes JSON under `offline.*` in SharedPreferences (`offline_store.dart`).
- **Impact:** task contents, comments and profile are readable on a rooted device or from an unencrypted backup. Cleared on logout.
- **Mitigation present:** cleared on logout and on account switch (`AuthController`).
- **Fix options:** encrypt the cache (key in secure storage) or disable backups. `android:allowBackup` is not set in any manifest, so the Android default (`true`) applies.

### M3 — Statistics from loaded pages only
- **Evidence:** `homeOverviewProvider` derives from `tasksControllerProvider` (page size 20); search/filter in `TasksScreen` filter the loaded list.
- **Impact:** with > 20 tasks, Home counts/on-time rate and search results can be incomplete until more pages load.
- **Fix:** backend summary/search endpoints, or use the offline full copy (`refreshAllTasks`) for statistics.

### M4 — Orphaned uploads
- **Evidence:** `CompleteTaskScreen` uploads each photo/file as soon as it is picked.
- **Impact:** if the worker leaves without submitting, files stay attached on the server.
- **Trade-off:** immediate upload gives faster submit and per-file errors.

### M5 — No TLS
Same root cause as H1. Token and passwords travel in clear text on the network. Acceptable only on a trusted LAN for development.

---

## Low

| ID | Detail | Location |
|---|---|---|
| L1 | English-only text: upload success/partial-failure snackbars, "Uploading…" | `complete_task_screen.dart`, `completion_form.dart:206` |
| L2 | `json['accessToken'] as String` throws a TypeError if missing (caught by `LoginForm` → generic error). `state.extra!` for the signup-verify route throws if opened without data | `login_response_model.dart`, `app_router.dart` |
| L3 | Nunito fetched at runtime by `google_fonts`; offline first launch shows the system font | `app_text_styles.dart`, `pubspec.yaml` |
| L4 | 8 never-imported files and a stale root `l10n/` (the 9 empty files and 6 unused packages were removed on 2026-10-14) | doc 00, doc 01 |
| L5 | `StorageKeys.refreshToken` is deleted on logout but never written | `auth_repository_impl.dart` |
| L6 | `debugPrint` prints error objects (no tokens or passwords printed — checked) | sync, realtime, FCM |
| L7 | `ApiInterceptor.onRequest` awaits secure storage every call; could cache in memory | `api_interceptor.dart` |
| L8 | Writes that time out after sending aren't queued (avoids duplicates); user must retry | `api_interceptor.dart`, `task_repository_impl.dart` |
| L9 | Minimum photo/file counts exist on `Task` but aren't required to submit | `complete_task_screen.dart` (`_canSubmit`) |

---

## Info
- **I1:** `Image.network(url)` sends no `Authorization` header, so the backend must serve `/uploads` publicly. Anyone with a file URL can open it (URLs are not guessable only if the backend uses random names — *Unverified*).
- **I2:** `ApiExceptionL10n.localized` shows 4xx `message` as received.
- **I3:** 1-year JWT (`JWT_EXPIRES_IN_SECONDS` in backend config, from project history). Stolen token = long access.

---

## What is done well (say this too)

| Strength | Evidence |
|---|---|
| Token in secure storage, not prefs | `secure_storage_service.dart` |
| Password never stored | search of storage writes |
| Logout removes push token server-side **before** deleting the session token | `AuthController.signOut` order |
| Per-user data wiped on logout and on account switch | `_clearOfflineData`, `_clearUserData` |
| One error type for the UI; no raw Dio errors leak | `api_exceptions.dart` comment + data-source pattern |
| Offline queue never silently loses work: refusals listed in a sheet | `SyncFailure`, `SyncFailuresSheet` |
| Ordered replay per task, queue survives restarts | `offline_sync_test.dart` |
| Startup can't hang: errors become a Retry panel | `SplashErrorPanel` |
| WebView with JavaScript disabled | `legal_webview_screen.dart` |
| Firebase failure can't break the app | `FirebaseBootstrap` returns false |
| No secrets in Dart code; API URL via `--dart-define` | `api_constants.dart` |

---

## Secrets check performed
- Searched `lib/` for keys/passwords: none hard-coded. The base URL is a LAN address, not a secret.
- `android/app/google-services.json` contains Firebase client identifiers (normally shipped inside the APK; not a server secret). Not reproduced here.
- Backend secrets are outside the mobile scope and are not quoted in any document.
