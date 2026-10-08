import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsState {
  const SettingsState({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale? locale;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool resetLocale = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: resetLocale ? null : locale ?? this.locale,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.watch(localStorageServiceProvider);

    // Restore themeMode
    final rawTheme = storage.getString(StorageKeys.themeMode);
    final themeMode = switch (rawTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      // Light is the default; the old "follow system" choice no longer exists.
      _ => ThemeMode.light,
    };

    // Restore locale (optional)
    final localeCode = storage.getString(StorageKeys.localeCode);
    final locale = (localeCode == null || localeCode.isEmpty)
        ? null
        : Locale(localeCode);

    return SettingsState(themeMode: themeMode, locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final storage = ref.read(localStorageServiceProvider);

    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    state = state.copyWith(themeMode: mode);
    await storage.setString(StorageKeys.themeMode, raw);
  }

  Future<void> setLocale(Locale? locale) async {
    final storage = ref.read(localStorageServiceProvider);

    state = state.copyWith(locale: locale, resetLocale: locale == null);

    if (locale == null) {
      await storage.remove(StorageKeys.localeCode);
    } else {
      await storage.setString(StorageKeys.localeCode, locale.languageCode);
    }
  }
}
