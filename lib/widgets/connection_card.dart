import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'brand_mark.dart';

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    super.key,
    required this.isConnected,
    required this.connectionLabel,
    required this.helperText,
    required this.onToggleConnection,
    required this.onOpenTrends,
    required this.statusLabel,
    required this.statusColor,
    required this.placementLabel,
    required this.qualityValue,
    required this.heroImagePath,
  });

  final bool isConnected;
  final String connectionLabel;
  final String helperText;
  final Future<void> Function() onToggleConnection;
  final VoidCallback onOpenTrends;
  final String statusLabel;
  final Color statusColor;
  final String placementLabel;
  final double qualityValue;
  final String heroImagePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.backgroundAlt,
              AppTheme.surfaceSoft,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;

            final copy = Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailPill(
                        label: connectionLabel,
                        color: isConnected ? AppTheme.stable : AppTheme.danger,
                        icon: Icons.sensors_outlined,
                      ),
                      _DetailPill(
                        label: statusLabel,
                        color: statusColor,
                        icon: Icons.favorite_outline,
                      ),
                      _DetailPill(
                        label: placementLabel,
                        color: AppTheme.secondary,
                        icon: Icons.place_outlined,
                      ),
                      _DetailPill(
                        label: '${(qualityValue * 100).round()}% confidence',
                        color: AppTheme.secondary,
                        icon: Icons.verified_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'A softer, more intelligent monitor for the moments parents care about most.',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      helperText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Designed for calm caregiver reassurance, parent empathy, and a premium first impression.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: onToggleConnection,
                        icon: Icon(
                          isConnected
                              ? Icons.bluetooth_disabled
                              : Icons.bluetooth_searching,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isConnected
                              ? AppTheme.danger
                              : AppTheme.primaryDeep,
                        ),
                        label: Text(
                          isConnected ? 'Disconnect Sensor' : 'Connect Sensor',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenTrends,
                        icon: const Icon(Icons.show_chart),
                        label: const Text('Open Trends'),
                      ),
                    ],
                  ),
                ],
              ),
            );
            final media = Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 0 : 24,
                0,
                24,
                24,
              ),
              child: _HeroImage(
                heroImagePath: heroImagePath,
                placementLabel: placementLabel,
                statusLabel: statusLabel,
                qualityValue: qualityValue,
              ),
            );

            return wide
                ? SizedBox(
                    height: 420,
                    child: Row(
                      children: [
                        Expanded(flex: 10, child: copy),
                        Expanded(flex: 9, child: media),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      copy,
                      media,
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.heroImagePath,
    required this.placementLabel,
    required this.statusLabel,
    required this.qualityValue,
  });

  final String heroImagePath;
  final String placementLabel;
  final String statusLabel;
  final double qualityValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    heroImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 42,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryDeep.withValues(alpha: 0.16),
                          AppTheme.primaryDeep.withValues(alpha: 0.58),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 16,
            child: _FloatingTag(
              text: 'Nursery scene',
              color: AppTheme.primaryDeep,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: 'Mode',
                      value: placementLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: 'Status',
                      value: statusLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: 'Quality',
                      value: '${(qualityValue * 100).round()}%',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 96,
            right: 16,
            child: _FloatingTag(
              text: 'ankle + chest ready',
              color: AppTheme.secondary,
              light: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({
    required this.text,
    required this.color,
    this.light = false,
  });

  final String text;
  final Color color;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.92) : color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: light ? AppTheme.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
