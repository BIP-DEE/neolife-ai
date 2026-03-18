import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_session_controller.dart';
import 'state/neo_life_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSessionController()),
        ChangeNotifierProvider(create: (_) => NeoLifeController()),
      ],
      child: const NeoLifeApp(),
    ),
  );
}
