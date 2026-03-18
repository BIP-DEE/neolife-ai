import 'package:flutter/material.dart';

class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    super.key,
    required this.child,
    this.bottomSpacing = 112,
  });

  final Widget child;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomSpacing),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
        ),
      ),
    );
  }
}
