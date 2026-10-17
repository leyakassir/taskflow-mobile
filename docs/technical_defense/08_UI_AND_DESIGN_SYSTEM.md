# 08 — UI and Design System

> **Last audited:** 2026-10-14. Key files: `app/theme/app_colors.dart`, `app_dimensions.dart`, `app_text_styles.dart`, `app_theme.dart`, `core/widgets/*`, `features/calendar/widgets/calendar_priority_color.dart`, `features/tasks/widgets/task_status_chip.dart`.

---

## 1. Design tokens

Tokens are named constants. Screens use the names, never raw numbers or hex values, so a change in one place restyles the whole app.

### Colors (`AppColors`)
| Group | Tokens (value) |
|---|---|
| Brand | `seed` / `brandBlue` `#5B6AF0` (indigo), `brandBlueDark` `#4A58D4`, `brandNavy` `#0F1117` |
| Light surfaces | `canvasLight` `#F7F8FC`, `surfaceLight`/`cardLight` `#FFFFFF`, `fieldFillLight` `#F0F2FF`, `borderLight` `#E4E6F0` |
| Dark surfaces | `midnight` `#0F1117`, `surfaceDark` `#1A1D27`, `cardDark` `#1E2130`, `fieldFillDark` `#252838`, `borderDark` 10 % white |
| Text | `textPrimaryLight` `#0F1117`, `textPrimaryDark` `#F0F2FF`, `textSecondaryLight` `#666B87`, `textSecondaryDark` `#8A8FA8` |
| Semantic | `success` `#22C55E`, `info` `#5B6AF0`, `warning` `#F59E0B`, `danger` `#EF4444`, `neutral` `#8A8FA8` |
| Tints | `successBg`, `infoBg`, `warningBg`, `dangerBg`, `neutralBg` (same hue, ~15 % alpha) |

**Accessibility detail worth mentioning:** the designed secondary grey `#8A8FA8` reaches only 3.2:1 on white, so light mode uses `#666B87` (5.0:1) — comment in `app_colors.dart`. `AppColors.readable(color, brightness)` darkens (light mode) or lightens (dark mode) a semantic color in HSL so text on chips reaches about 5.4:1 (WCAG AA small text needs 4.5:1). Used via `context.readable(...)`.

### Status and priority color mapping
| Status (`TaskStatusChip`) | Color |
|---|---|
| Assigned | `info` (indigo) |
| In progress | `warning` (amber) |
| Completed | `success` (green) |
| Overdue | `danger` (red) |
| Cancelled | `neutral` (grey) |

| Priority (`calendarPriorityColor`) | Color |
|---|---|
| Low | `neutral` |
| Medium | `info` |
| High | `warning` |
| Urgent | `danger` |

The priority function is shared by calendar markers, legends, the colored edge of task cards, priority badges and the Home priority breakdown (comment in `calendar_priority_color.dart`). One palette → consistent meaning across screens.

### Spacing and shape (`AppDimensions`)
- Spacing scale on a 4-point grid: `space1` 4 · `space2` 8 · `space3` 12 · `space4` 16 · `space5` 20 · `space6` 24 · `space7` 32 · `space8` 40.
- `pagePadding` 16, `sectionSpacing` 24, `itemSpacing` 12.
- Radii: `fieldRadius`/`buttonRadius` 12, `taskCardRadius` 14, `cardRadius` 16, `heroRadius` 24.
- `buttonHeight` 50 (above the 48 dp minimum touch target).

### Typography (`AppTextStyles`)
All styles use **Nunito** through `GoogleFonts.nunito`:
| Style | Size / weight |
|---|---|
| `displayLarge/Medium/Small` | 32 / 28 / 24, w800 |
| `headingLarge/Medium/Small` | 20 / 18 w700, 16 w600 |
| `bodyLarge/Medium/Small` | 16 / 14 / 12, regular, line-height 1.5 |
| `labelLarge/Medium/Small` | 14 / 12 / 10, w500 |
| `button` | 15, w600 |

⚠ `google_fonts` downloads the font at runtime unless it is bundled. On a first launch with no internet the system font is used until the font can be fetched (**Confirmed** in `pubspec.yaml`: comment "Nunito, loaded at runtime — no font assets to manage").

---

## 2. Theme (`app_theme.dart`)
- `ThemeData(useMaterial3: true)` with `ColorScheme.fromSeed(seedColor: AppColors.brandBlue, …).copyWith(…)` for light and dark, then component themes (inputs, buttons, cards, navigation bar) built from the tokens.
- `SettingsController` stores `themeMode` as `light` or `dark`; **light is the default**; the old "follow system" value is read as light (comment in `settings_provider.dart`).

---

## 3. Shared widgets (`core/widgets/`)

| Widget | Used for | Status |
|---|---|---|
| `AppButton` | Primary/secondary full-width buttons with loading state | used |
| `AppTextField` | Filled text field with label, icons, obscure toggle | used (login, forms) |
| `EmptyState` | Icon + title + message when a list is empty | used |
| `ErrorView` | Error message + Retry | used |
| `LoadingIndicator` | Centered spinner | used |
| `SkeletonBlock` | Placeholder shapes while loading (`TaskCardSkeleton`, `ProfileHeaderSkeleton`) | used |
| `DotIndicator` | Page dots (onboarding, KPI carousel) | used |
| `PhotoSourceSheet` | Bottom sheet: camera or gallery | used |
| `AppBackground`, `SectionHeader`, `StatChip` | — | **never imported** (dead code) |

Feature widgets follow the same idea: e.g. `TaskCard`, `TaskStatusChip`, `TaskPriorityBadge`, `TaskSectionCard`, `ProfileMenuItem`, `SettingsSection`.

---

## 4. Loading, empty and error states

Every async screen uses `AsyncValue.when` (or `valueOrNull` + flags):

| State | Pattern |
|---|---|
| Loading (first time) | Skeletons (task list, profile header) or `LoadingIndicator` |
| Refresh | Keep current data; pull-to-refresh spinner (`RefreshIndicator`) |
| Empty | `EmptyState` with a translated message |
| Error | `ErrorView` with `ApiException.localized(l10n)` + Retry |
| Next page | Footer spinner; footer Retry if `tasksLoadMoreFailedProvider` |
| Offline | `SyncStatusBar` above the navigation bar; `PendingSyncBadge` on tasks with unsent changes |

---

## 5. Localization and RTL

- Source files: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` → generated `lib/l10n/gen/app_localizations*.dart` (`l10n.yaml`).
- Usage: `AppLocalizations.of(context).someKey`.
- Language choice: `LanguageScreen` → `SettingsController.setLocale` → `localeCode` in prefs → `MaterialApp.locale`. A language toggle also sits on the login screen (`login_language_toggle.dart`).
- Arabic switches the whole layout to right-to-left automatically.
- Task content: `Task.titleFor(languageCode)` / `descriptionFor(languageCode)` pick `titleAr` / `descriptionAr` when available.
- Backend emails use the `lang` field sent with forgot-password and signup requests.
- **Known gaps (hard-coded English):** upload result snackbars in `complete_task_screen.dart`, "Uploading…" in `completion_form.dart`, and server-side 4xx error texts (shown as received).
- Root folder `l10n/` (outside `lib/`) is a stale duplicate; the build uses `lib/l10n`.

---

## 6. Responsiveness and accessibility

- `ui_robustness_test.dart` renders key screens on a **360 dp wide** phone at **1.3× text scale** in English/Arabic and light/dark, failing on overflow. **Confirmed** (passes).
- `login_layout_test.dart` checks the login layout fits.
- Tooltips on icon buttons (e.g. show/hide password in `LoginForm`) give screen readers a label.
- Not verified: TalkBack/VoiceOver walkthrough, tablet/landscape layouts (*Unverified*).

---

## 7. Branding assets
- `assets/icons/taskflow_icon.png` — in-app logo and source for `flutter_launcher_icons`.
- Android launch screen: gradient `drawable/launch_background.xml`; Android 12+ splash in `values-v31` / `values-night-v31` uses the brand color with a transparent icon so it blends into the Flutter splash.
- Notification small icon: `@drawable/ic_stat_taskflow` (white silhouette, required by Android).
