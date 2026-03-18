import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class QualityIndicatorCard extends StatelessWidget {
  const QualityIndicatorCard({
    super.key,
    required this.value,
    required this.label,
  });

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    final color = value >= 0.85
        ? AppTheme.primaryDeep
        : value >= 0.65
            ? AppTheme.warning
            : AppTheme.danger;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 330;
            final gauge = TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 700),
              builder: (context, animatedValue, _) {
                return SizedBox(
                  width: 108,
                  height: 108,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 108,
                        height: 108,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation(
                            color.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 108,
                        height: 108,
                        child: CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation(color),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percent%',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 28),
                          ),
                          Text(
                            'confidence',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );

            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Signal Quality',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QualityTag(
                      color: color,
                      label: value >= 0.85
                          ? 'Skin contact strong'
                          : 'Review contact',
                    ),
                    const _QualityTag(
                      color: AppTheme.secondary,
                      label: 'Mock sensor feed',
                    ),
                  ],
                ),
              ],
            );

            return wide
                ? Row(
                    children: [
                      gauge,
                      const SizedBox(width: 18),
                      Expanded(child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gauge,
                      const SizedBox(height: 18),
                      details,
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _QualityTag extends StatelessWidget {
  const _QualityTag({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
