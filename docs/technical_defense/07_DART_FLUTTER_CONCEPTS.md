# 07 — Dart and Flutter Concepts (with examples from TaskFlow)

> **Last audited:** 2026-10-14. Dart SDK constraint `^3.13.3`, Flutter 3.47.3. Each concept: short definition → where TaskFlow uses it → what to say if asked.

---

## Part A — Dart language

### 1. Null safety
Types are non-nullable by default; `?` allows null; `!` asserts non-null; `??` gives a default; `?.` calls only if non-null.
```dart
// auth_repository_impl.dart
final token = await _secureStorage.read(StorageKeys.accessToken); // String?
if (token == null || token.isEmpty) return false;
```
```dart
// task_model.dart (TaskPageModel.fromJson)
page: (json['page'] as num?)?.toInt() ?? 1,
```
**Risk spots:** `as String` casts on JSON (`LoginResponseModel.fromJson`) and `state.extra!` in the router — they throw if the data is missing.

### 2. `final`, `const`, `late`
- `final` = assigned once. `const` = compile-time constant, shared instance (e.g. `const ApiException.generic()`, `const SizedBox(height: …)` — fewer rebuilds/allocations).
- `late` = initialised later but before use: `late int _secondsLeft;` in `resend_code_button.dart`.

### 3. Classes, constructors, factories
- Private constructor to block instantiation: `ApiConstants._();`.
- Named + required parameters: `ApiException(this.message, {this.statusCode, this.kind = ApiErrorKind.server})`.
- Redirecting named constructor: `const ApiException.generic() : this('…', kind: ApiErrorKind.generic);`
- `factory` constructors build objects from JSON: `LoginResponseModel.fromJson`, `HomeOverview.fromTasks`.

### 4. Immutability and `copyWith`
Entities are immutable; changes create a new object:
```dart
// task_repository_impl.dart (_withPending)
result = result.copyWith(status: TaskStatus.completed, completionTimestamp: op.createdAt);
```
Why: Riverpod detects a new state object and rebuilds; no hidden mutation.

### 5. Enums
`TaskStatus { assigned, inProgress, completed, overdue, cancelled }`, `TaskPriority`, `ApiErrorKind`, `PendingOperationType`. Stored by `.name` (`PendingOperation.toJson` → `'type': type.name`) and parsed back with `values.where((t) => t.name == json['type']).firstOrNull` so unknown values are dropped safely.

### 6. Switch expressions and patterns (Dart 3)
```dart
// api_exception_l10n.dart
String localized(AppLocalizations l10n) => switch (kind) {
  ApiErrorKind.server => isServerError ? l10n.genericError : message,
  ApiErrorKind.timeout => l10n.errorTimeout,
  …
};
```
```dart
// realtime_provider.dart — logical-or pattern
case RealtimeEventType.ping || RealtimeEventType.unknown:
  return;
```
The compiler checks that every enum value is handled (exhaustiveness).

### 7. Extensions
Add methods to existing types without subclassing:
- `extension ApiExceptionL10n on ApiException` → `error.localized(l10n)`.
- `extension ReadableSemanticColor on BuildContext` (`app_colors.dart`) → `context.readable(AppColors.danger)` picks a contrast-safe shade for the current brightness.

### 8. Collections: spread, collection-if/for, cascade
```dart
// tasks_provider.dart
state = AsyncData([...current, ...result.tasks]);          // spread
state = AsyncData([ for (final task in current) if (task.id == updated.id) updated else task ]);
```
```dart
// auth_provider.dart — cascade
ref
  ..invalidate(tasksControllerProvider)
  ..invalidate(profileControllerProvider);
```
```dart
// task_remote_data_source.dart — collection-if in a map
if (from != null) 'from': from.toUtc().toIso8601String(),
```

### 9. async / await, Future
`Future<T>` = a value later. `await` pauses the function, not the app (single-threaded event loop).
- `unawaited(FirebaseBootstrap.ensureInitialized())` in `main.dart` — start but don't wait.
- `Future.microtask(() => sync(refreshCache: true))` in `SyncController.build` — run right after `build` returns (you can't change state inside `build`).
- `try / on ApiException catch (e) / catch (_) / finally` — see `LoginForm._submit`.

### 10. Streams
A sequence of async events. Used for SSE: `body.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter())` → `parseServerSentEvents` → `Stream<RealtimeEvent>`; subscribed with `listen(onData, onError:, onDone:, cancelOnError: true)` and cancelled in `_disconnect()`. Also FCM: `FirebaseMessaging.onMessage.listen(...)`, `onTokenRefresh.listen(...)`.

### 11. Timers
`Timer.periodic` (connectivity probe every 15 s; resend-code countdown), one-shot `Timer` (realtime debounce 400 ms, reconnect backoff). Always cancelled in `ref.onDispose` / `dispose()`.

### 12. Isolates
**Not used.** All JSON parsing is on the main isolate. Fine for the data sizes here (≤ 100 tasks per request). If asked: `compute()` could move heavy parsing off the UI thread.

### 13. Generics
`Provider<Dio>`, `AsyncNotifier<List<Task>>`, `_dio.get<Map<String, dynamic>>(…)`, `AsyncValue<HomeOverview>` — type safety for state and responses.

---

## Part B — Flutter framework

### 14. Everything is a widget; three trees
Widget (configuration) → Element (lives in the tree, holds state) → RenderObject (layout/paint). Rebuilding a widget is cheap; Flutter reuses elements when type and key match.

### 15. StatelessWidget vs StatefulWidget vs ConsumerWidget
| Kind | When | Example |
|---|---|---|
| `StatelessWidget` | Pure UI from constructor data | `ProfileLogoutButton`, `TaskCard` |
| `StatefulWidget` | Local, short-lived UI state (controllers, animations, flags) | `ResendCodeButton` (countdown) |
| `ConsumerWidget` | Needs providers, no local state | many screens |
| `ConsumerStatefulWidget` | Providers **and** local state | `LoginForm` (`_isSubmitting`, text controllers), `TasksScreen` (scroll controller) |

Rule in this codebase: **app/server state → Riverpod; ephemeral UI state → `setState`.**

### 16. Lifecycle and `mounted`
`initState` → `build` (many times) → `dispose`. Controllers (`TextEditingController`, `ScrollController`, `AnimationController`) are created in state and disposed in `dispose()` (`LoginForm.dispose`). After an `await`, code checks `if (!mounted) return;` before `setState` or using `context` (`LoginForm._submit`).

### 17. BuildContext
A handle to the widget's position in the tree. Used to look up inherited data: `Theme.of(context)`, `AppLocalizations.of(context)`, `Localizations.localeOf(context)`, `context.push(...)` (GoRouter extension).

### 18. Keys
Used where identity matters in lists: `TasksScreen` gives each card `key: ValueKey(task.id)` so Flutter keeps the right element when the list is filtered or reloaded; keys also appear in `notification_list.dart`, `notification_bell_button.dart`, `stats_card.dart`. Say: "keys help Flutter match old and new widgets when items move".

### 19. Layout
`Column`/`Row`/`Expanded`/`Flexible`, `ListView.builder` (lazy lists), `CustomScrollView` + slivers, `SafeArea`, `LayoutBuilder`/`MediaQuery` for small screens. `ui_robustness_test.dart` checks a 360 dp screen at 1.3× text scale for overflow in en/ar and light/dark.

### 20. Navigation (GoRouter, declarative)
`context.go(path)` replaces the stack (tabs, after login); `context.push(path)` adds on top (task details); `context.pop()` goes back. Redirect guards protect `/app/*`. Details in doc 02.

### 21. Theming
`ThemeData` (Material 3) built from tokens in `app_theme.dart`; `ThemeMode.light/dark` chosen by `SettingsController`. Widgets read colors from `Theme.of(context).colorScheme` or the `AppColors` tokens. Doc 08.

### 22. Localization and RTL
`flutter gen-l10n` (`l10n.yaml`) generates `AppLocalizations` from `app_en.arb` / `app_ar.arb`. `MaterialApp` gets `localizationsDelegates` + `supportedLocales`. Arabic automatically flips layout to right-to-left (`Directionality`); use `EdgeInsetsDirectional` / `AlignmentDirectional` for start/end.

### 23. Animations
Explicit animations with `AnimationController` + `SingleTickerProviderStateMixin`/`TickerProviderStateMixin` in `splash_screen.dart`, `splash_loading_bar.dart`, `auth_background.dart`. Infinite animations mean tests must `pump(duration)` instead of `pumpAndSettle()`.

### 24. Platform channels / plugins
Packages like `flutter_secure_storage`, `image_picker`, `firebase_messaging`, `webview_flutter` call native Android/iOS code through method channels. That's why `WidgetsFlutterBinding.ensureInitialized()` runs first in `main()`.

### 25. App lifecycle
`AppLifecycleListener(onResume:, onPause:)` — used by `ConnectivityController` (probe on resume) and `RealtimeController` (disconnect on pause, reconnect on resume). The notification bell refreshes on resume too.

### 26. Build modes
Debug (hot reload, asserts, slow), Profile (performance measurement), Release (AOT-compiled, optimised, **no cleartext HTTP here**). `debugPrint` output still exists in release but is rate-limited; it is not shown to users.

---

## Part C — Questions you can expect on these concepts

| Question | Short answer |
|---|---|
| `const` vs `final`? | `const` is known at compile time and canonicalised; `final` is set once at runtime. |
| Why check `mounted`? | The widget may be gone after an `await`; using its context would throw. |
| Future vs Stream? | One value later vs many values over time (SSE, FCM messages). |
| Why `Future.microtask` in a notifier's `build`? | State can't be modified during `build`; microtask runs right after. |
| Hot reload vs hot restart? | Reload keeps state and injects code; restart rebuilds the app from `main()`. |
| Why `ListView.builder`? | Builds only visible items — needed for long task lists. |
