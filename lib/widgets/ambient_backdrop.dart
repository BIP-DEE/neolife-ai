import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.ambientGradient,
      ),
      child: Stack(
        children: [
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -30,
                  child: _GlowOrb(
                    size: 280,
                    colors: [
                      AppTheme.secondary.withValues(alpha: 0.16),
                      AppTheme.primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                Positioned(
                  top: 180,
                  left: -60,
                  child: _GlowOrb(
                    size: 240,
                    colors: [
                      AppTheme.blush.withValues(alpha: 0.38),
                      AppTheme.blush.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: -80,
                  child: _GlowOrb(
                    size: 260,
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.12),
                      AppTheme.primaryDeep.withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
