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

    expect(find.text('Infant wellness, clearly presented.'), findsOneWidget);
    expect(find.text('Create caregiver account'), findsOneWidget);
    expect(find.text('Sign in to the demo'), findsOneWidget);
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

    expect(find.text('Live signals'), findsOneWidget);
    expect(find.text('Placement mode'), findsOneWidget);
    expect(find.text('Alert summary'), findsOneWidget);
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

    await tester.tap(find.text('Sign in to the demo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Enter dashboard'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('auth-primary-signIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Live signals'), findsOneWidget);
    expect(find.text('Placement mode'), findsOneWidget);
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

    await tester.tap(find.text('Create caregiver account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Create account'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('auth-primary-register')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Live signals'), findsOneWidget);
    expect(find.text('Alert summary'), findsOneWidget);
  });
}
