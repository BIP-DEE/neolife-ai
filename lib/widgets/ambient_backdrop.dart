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
                  top: -140,
                  right: -40,
                  child: _GlowOrb(
                    size: 320,
                    colors: [
                      AppTheme.secondary.withValues(alpha: 0.16),
                      AppTheme.primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                Positioned(
                  top: 140,
                  left: -80,
                  child: _GlowOrb(
                    size: 300,
                    colors: [
                      AppTheme.blush.withValues(alpha: 0.42),
                      AppTheme.blush.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: -100,
                  child: _GlowOrb(
                    size: 340,
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.14),
                      AppTheme.primaryDeep.withValues(alpha: 0.01),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -40,
                  child: _GlowOrb(
                    size: 220,
                    colors: [
                      AppTheme.sand.withValues(alpha: 0.44),
                      AppTheme.sand.withValues(alpha: 0.02),
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
