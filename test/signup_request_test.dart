import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow_mobile/app/theme/app_theme.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/auth/providers/signup_request_provider.dart';
import 'package:taskflow_mobile/features/auth/screens/signup_request_screen.dart';
import 'package:taskflow_mobile/features/auth/screens/signup_verify_screen.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Server stand-in: accepts only [goodCode]; can pretend the account exists.
class FakeSignupActions extends SignupRequestActions {
  FakeSignupActions(super.ref, {this.accountExists = false});
  final bool accountExists;
  static const goodCode = '123456';
  final verified = <String>[];

  @override
  Future<void> requestCode(
    SignupDraft draft, {
    required String languageCode,
  }) async {}

  @override
  Future<void> verify(String email, String code) async {
    if (accountExists) {
      throw const ApiException('exists', statusCode: 409);
    }
    if (code != goodCode) {
      throw const ApiException('Invalid code', statusCode: 400);
    }
    verified.add(email);
  }
}

const _draft = SignupDraft(
  fullName: 'New Worker',
  email: 'new.worker@example.com',
  password: 'Chosen123!',
);

Future<FakeSignupActions> _pump(
  WidgetTester tester,
  Widget screen, {
  bool accountExists = false,
  Locale locale = const Locale('en'),
  bool dark = false,
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  late FakeSignupActions fake;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        signupRequestProvider.overrideWith(
          (ref) => fake = FakeSignupActions(ref, accountExists: accountExists),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Reading the provider builds the fake.
  ProviderScope.containerOf(tester.element(find.byWidget(screen)))
      .read(signupRequestProvider);
  return fake;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('correct code: "Request sent"', (tester) async {
    final fake = await _pump(tester, const SignupVerifyScreen(draft: _draft));
    await tester.enterText(find.byType(TextField), FakeSignupActions.goodCode);
    await tester.pumpAndSettle();
    expect(find.text(l10n.signupSentTitle), findsOneWidget);
    expect(fake.verified, [_draft.email]);
  });

  testWidgets('wrong code: "Request not sent", then try again', (tester) async {
    final fake = await _pump(tester, const SignupVerifyScreen(draft: _draft));
    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();
    expect(find.text(l10n.signupNotSentTitle), findsOneWidget);
    expect(find.text(l10n.signupNotSentCode), findsOneWidget);
    expect(fake.verified, isEmpty);

    await tester.tap(find.text(l10n.signupTryAgain));
    await tester.pumpAndSettle();
    expect(find.text(l10n.signupSendRequest), findsOneWidget);
  });

  testWidgets('account already exists: explained, nothing sent', (
    tester,
  ) async {
    await _pump(
      tester,
      const SignupVerifyScreen(draft: _draft),
      accountExists: true,
    );
    await tester.enterText(find.byType(TextField), FakeSignupActions.goodCode);
    await tester.pumpAndSettle();
    expect(find.text(l10n.signupNotSentExists), findsOneWidget);
  });

  testWidgets('details form checks every field before sending', (tester) async {
    await _pump(tester, const SignupRequestScreen());
    await tester.tap(find.text(l10n.forgotSendCode));
    await tester.pumpAndSettle();
    expect(find.text(l10n.nameTooShort), findsOneWidget);
    expect(find.text(l10n.invalidEmail), findsOneWidget);
    expect(find.text(l10n.resetPasswordShort), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final dark in const [false, true]) {
      final variant = '${locale.languageCode}/${dark ? 'dark' : 'light'}';
      for (final entry in <String, Widget>{
        'SignupRequestScreen': const SignupRequestScreen(),
        'SignupVerifyScreen': const SignupVerifyScreen(draft: _draft),
      }.entries) {
        testWidgets('${entry.key} fits 360dp @1.3x ($variant)', (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await _pump(
            tester,
            entry.value,
            locale: locale,
            dark: dark,
            textScale: 1.3,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
