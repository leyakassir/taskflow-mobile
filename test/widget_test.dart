import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow_mobile/app/app.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:taskflow_mobile/features/splash/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // No network in tests: render with the test font instead of fetching Nunito.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('App boots: splash, then onboarding on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const TaskFlowApp(),
      ),
    );
    await tester.pump(); // let the router build
    expect(find.byType(SplashScreen), findsOneWidget);

    // The splash stays up for its minimum duration, then moves on.
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
