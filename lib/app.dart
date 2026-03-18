import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth_flow_screen.dart';
import 'screens/app_shell.dart';
import 'state/app_session_controller.dart';

class NeoLifeApp extends StatelessWidget {
  const NeoLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoLife AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: Consumer<AppSessionController>(
        builder: (context, session, _) {
          return session.isAuthenticated
              ? const AppShell()
              : const AuthFlowScreen();
        },
      ),
    );
  }
}
