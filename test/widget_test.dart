import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:neo_life_ai/app.dart';
import 'package:neo_life_ai/state/app_session_controller.dart';
import 'package:neo_life_ai/state/neo_life_controller.dart';

void main() {
  testWidgets('renders NeoLife AI welcome flow', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSessionController()),
          ChangeNotifierProvider(create: (_) => NeoLifeController()),
        ],
        child: const NeoLifeApp(),
      ),
    );

    expect(find.text('A calmer way to stay close to every shift.'),
        findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('renders dashboard after authentication', (tester) async {
    final session = AppSessionController()
      ..completeAuthentication(
        email: 'hello@neolife.ai',
        caregiverName: 'Chanda',
        infantName: 'Baby Neo',
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSessionController>.value(value: session),
          ChangeNotifierProvider(create: (_) => NeoLifeController()),
        ],
        child: const NeoLifeApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Key wellness signals'), findsOneWidget);
    expect(find.text('Recommended action'), findsOneWidget);
    expect(find.text('Recent changes'), findsOneWidget);
  });

  testWidgets('sign in flow opens dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSessionController()),
          ChangeNotifierProvider(create: (_) => NeoLifeController()),
        ],
        child: const NeoLifeApp(),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Open dashboard'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'name@example.com'),
      'hello@neolife.ai',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'At least 6 characters'),
      'securepass',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('auth-primary-signIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Key wellness signals'), findsOneWidget);
    expect(find.text('Recommended action'), findsOneWidget);
  });

  testWidgets('register flow opens dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSessionController()),
          ChangeNotifierProvider(create: (_) => NeoLifeController()),
        ],
        child: const NeoLifeApp(),
      ),
    );

    await tester.tap(find.text('Create account').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Create account'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter caregiver name'),
      'Chanda',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter infant profile name'),
      'Baby Neo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'name@example.com'),
      'hello@neolife.ai',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'At least 6 characters'),
      'securepass',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('auth-primary-register')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Key wellness signals'), findsOneWidget);
    expect(find.text('Recent changes'), findsOneWidget);
  });

  testWidgets('profile screen renders after authentication', (tester) async {
    final session = AppSessionController()
      ..completeAuthentication(
        email: 'hello@neolife.ai',
        caregiverName: 'Chanda',
        infantName: 'Baby Neo',
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSessionController>.value(value: session),
          ChangeNotifierProvider(create: (_) => NeoLifeController()),
        ],
        child: const NeoLifeApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Family, preferences, and trust'), findsOneWidget);
    expect(find.text('Care team visibility'), findsOneWidget);
  });
}
