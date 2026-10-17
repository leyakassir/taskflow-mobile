# 14 — Study Plan

> A 7-day plan (about 2 hours a day) to be able to explain any part of the app. Each day: **read** (docs), **open** (source files), **practice** (say answers out loud from [doc 12](12_TECHNICAL_DEFENSE_QA.md)).

---

## Priority topics (study these first)

1. **Sessions and silent token refresh**: the most likely to be questioned. (doc 04 §6, `api_interceptor.dart`, `auth_provider.dart`, `session_test.dart`)
2. **Riverpod basics**: watch/read, AsyncValue, family/autoDispose, invalidate. (doc 03)
3. **Login, token storage and session validation.** (doc 04)
4. **Dio interceptor and error mapping.** (doc 05 §4)
5. **Routing and redirect.** (doc 02)
6. **Known limitations, said honestly**: HTTPS/cleartext, debug signing, loaded-page statistics, no offline mode (and why it was removed). (doc 10)
7. **Push notifications lifecycle.** (doc 09 §2)
8. **Live updates (SSE).** (doc 06 §Live updates)

---

## Day-by-day

| Day | Read | Open in the editor | Practice (doc 12) |
|---|---|---|---|
| 1 | 00 Project map, 01 Dependencies | `main.dart`, `app/app.dart`, `pubspec.yaml` | Ch. 1, Ch. 2 |
| 2 | 02 Startup & navigation | `app_router.dart`, `route_names.dart`, `splash_provider.dart`, `splash_screen.dart` | Ch. 3, Ch. 4 |
| 3 | 03 Architecture & Riverpod | `tasks_provider.dart`, `task_details_provider.dart`, `home_provider.dart`, `auth_provider.dart` | Ch. 5 |
| 4 | 04 Auth & storage, 05 API & Dio | `auth_repository_impl.dart`, `login_form.dart`, `dio_client.dart`, `api_interceptor.dart`, `api_exceptions.dart` | Ch. 6, Ch. 7 |
| 5 | 06 Features (sessions, tasks, calendar) | `api_interceptor.dart`, `auth_repository_impl.dart`, `task_repository_impl.dart`, `complete_task_screen.dart` | Ch. 8, 9, 10 |
| 6 | 06 (notifications, realtime), 08 UI, 09 Firebase/Android | `fcm_service.dart`, `notifications_provider.dart`, `realtime_provider.dart`, `app_colors.dart`, `build.gradle.kts` | Ch. 11, 12, 16 |
| 7 | 07 Concepts, 10 Audit, 11 Testing, 13 Scripts | `test/session_test.dart`, `test/widget_test.dart` | Ch. 13, 14, 15; rehearse the 5- and 10-minute scripts with the demo |

---

## Self-check: can you do these without notes?

- [ ] Draw the layer diagram (screen → notifier → repository → data source → Dio).
- [ ] Trace "Start task", naming the classes, including what happens when the token has expired.
- [ ] Explain why connect timeout = "no connection" but receive timeout = "timed out".
- [ ] List what happens on logout, in order.
- [ ] Explain `ref.watch` vs `ref.read` with an example from the code.
- [ ] Explain how three requests failing with 401 together share one refresh (`_refreshing`).
- [ ] Explain the on-time rate formula.
- [ ] Say the three things needed before a store release.
- [ ] Show the notification tap routing rules.
- [ ] Run the tests: `flutter test` (expect 144 passed).

---

## Demo preparation checklist

- [ ] Backend running; phone on the same Wi-Fi; correct IP passed with `--dart-define=API_BASE_URL=…`.
- [ ] Use a **debug** build (`flutter run`). Release builds can't reach an HTTP server (doc 09 §4).
- [ ] A worker account with: one assigned, one in-progress, one overdue task, one task with a required checklist.
- [ ] Admin dashboard open in a browser to show live updates.
- [ ] Notifications permission granted on the phone.
- [ ] Practise the live-update demo (change a task in the dashboard, watch the phone) once before presenting.
- [ ] Backup: screenshots or a screen recording in case the network fails.

---

## Opening the docs

```powershell
# In VS Code
code C:\Taskflow\taskflow_mobile\docs\technical_defense

# Folder in Explorer
explorer C:\Taskflow\taskflow_mobile\docs\technical_defense
```
In VS Code, open any `.md` file and press **Ctrl+Shift+V** for the preview. Mermaid diagrams render with the "Markdown Preview Mermaid Support" extension, or on GitHub.
