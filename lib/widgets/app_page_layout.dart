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
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1280
        ? 32.0
        : width >= 960
            ? 26.0
            : width >= 720
                ? 22.0
                : 18.0;
    final topPadding = width >= 720 ? 22.0 : 14.0;
    final effectiveBottomSpacing = width >= 980 ? 42.0 : bottomSpacing;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        effectiveBottomSpacing,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: child,
        ),
      ),
    );
  }
}
