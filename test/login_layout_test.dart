import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow_mobile/app/theme/app_theme.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/auth/screens/login_screen.dart';
import 'package:taskflow_mobile/features/auth/widgets/login_form.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final height in [640.0, 900.0, 1100.0]) {
    testWidgets('Login sheet reaches the bottom edge (height $height)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      tester.view.physicalSize = Size(390, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: AppTheme.light,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);

      // The white sheet holding the form.
      final sheet = find
          .ancestor(
            of: find.byType(LoginForm),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration! as BoxDecoration).borderRadius != null &&
                  (w.decoration! as BoxDecoration).boxShadow != null,
            ),
          )
          .first;
      final rect = tester.getRect(sheet);
      // On short screens the page scrolls; scroll to the end first.
      if (rect.bottom > height) {
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -2000),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(
        tester.getRect(sheet).bottom,
        moreOrLessEquals(height, epsilon: 0.5),
      );
    });
  }
}
