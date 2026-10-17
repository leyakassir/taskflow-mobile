# 13 — Presentation Scripts

> Three scripts to read aloud: 2, 5 and 10 minutes. *[Brackets]* = what to show on screen. Speaking pace ≈ 130 words/minute.

---

## 2-minute version

"TaskFlow is a task management platform for field and office workers. I built the **mobile app**, the tool the worker uses every day.

*[Home screen]* After signing in, the worker sees today's work: tasks due today, overdue items, progress and an on-time rate.

*[Task details]* Each task has a description, deadline, priority, checklist, attachments and comments. The worker taps **Start**, does the work, ticks the checklist, takes photos and submits. The admin sees the result live on the dashboard.

Two things make it robust. First, the session is **secure without being annoying**: the login token lasts only 15 minutes and is renewed silently in the background, so the worker stays signed in while a stolen token quickly becomes useless. Second, it is **live**: when an admin changes a task, the app updates within a second through a server event stream, and push notifications reach the worker even when the app is closed.

Technically it's Flutter with Riverpod for state, GoRouter for navigation, Dio for the API and Firebase for push. It supports English and Arabic with right-to-left layout, light and dark themes, and has 144 automated tests passing."

---

## 5-minute version

**1. Problem (30 s)**
"Teams assign work by phone or chat, and nobody knows what is done. TaskFlow gives admins a dashboard and workers an app, both on one backend."

**2. Demo walkthrough (2 min)**
- *[Splash → Login]* "Sign in with company credentials. If you have no account, you can request one with an emailed code; an admin approves it."
- *[Home]* "The day at a glance. These numbers are computed from the worker's tasks."
- *[Tasks tab]* "Paged list (20 at a time), search, filters by status, colors by priority."
- *[Task → Start → Complete]* "Start, then complete: checklist, photos from the camera, files, notes. Photos upload as you pick them, so Submit is instant."
- *[Calendar]* "The same tasks by day, colored by priority."
- *[Notifications]* "Every assignment or comment arrives here and as a push notification; tapping opens the right task."

**3. Architecture (1 min)**
*[Diagram from doc 03]* "The code is organised by feature. Screens watch Riverpod providers. Providers call repositories, and repositories call the server through one Dio client. That client adds the login token, renews it when it expires, and turns every error into one app-level type, so every screen shows the same friendly, translated messages."

**4. Sessions and live updates (1 min)**
*[Dashboard and phone side by side]* "The admin changes this task's deadline in the dashboard, and the phone updates on its own: live updates use Server-Sent Events. Behind the scenes, the login token expires every 15 minutes. When a request is rejected, the app trades its refresh token for a new pair and repeats the request, so the worker never notices. Each refresh token works only once, so a copied token is detected and the session is ended."

**5. Quality and next steps (30 s)**
"144 tests cover token refresh, live updates, session handling, pagination and layout on small screens in both languages. Before a store release we need HTTPS, a real signing key and the iOS configuration. Those are the next steps."

---

## 10-minute version

### Part 1 — Context (1 min)
Same as the 5-minute section 1, plus: "My scope is the Flutter mobile app. It talks to a NestJS REST API; the admin dashboard is a separate web app."

### Part 2 — Live demo (3 min)
Follow the manual checklist in doc 11 §3, steps 1–8. Narrate:
- First launch: onboarding shown once.
- Wrong password → clear message; airplane mode → "no connection" message, translated.
- Arabic switch → full RTL.
- Dark mode.

### Part 3 — Architecture deep dive (2 min)
- *[Project tree]* "Feature folders: `auth`, `tasks`, `calendar`, `notifications`, `profile`, `realtime`… each with data, domain, providers, screens and widgets."
- *[Sequence diagram "Start task", doc 03 §3]* "Tap → notifier → repository → data source → Dio with the token → server. If the token has expired, Dio gets a new one and sends the same request again; none of the layers above it knows."
- "Dependency injection is Riverpod itself: every service is a provider, and tests replace any of them."

### Part 4 — Key engineering decisions (2 min)
1. **Single error type.** `ApiException` with a `kind`; the UI never sees Dio errors. Benefit: consistent, translated messages.
2. **Short sessions with silent refresh.** 15-minute access tokens, rotating single-use refresh tokens, and one shared refresh when several requests fail at once.
3. **No data stored on the phone.** Offline mode was removed on purpose: the worker always sees the server's current data, and nothing sensitive sits unencrypted on the device.
4. **Firebase in the background.** The splash appears immediately; if Firebase is missing, the app still works.
5. **Session validation at startup.** A valid or renewable session opens Home; a rejected one sends you to login; no connection or a server error shows Retry.

### Part 5 — Quality (1 min)
- 144 tests, analyzer clean.
- Robustness tests: 360 dp at 1.3× text in both languages and themes.
- Contrast-checked colors (≥ 4.5:1).

### Part 6 — Honest limitations and roadmap (1 min)
"Before production:
1. HTTPS. Android release builds block plain HTTP.
2. Real signing key and package name.
3. Statistics and search from the server instead of loaded pages.
4. iOS configuration, integration tests and crash reporting."

### Closing (15 s)
"TaskFlow mobile turns assigned work into a clear daily flow for the worker, keeps working without a network, and keeps the admin informed in real time. Thank you. I'm happy to take questions."
