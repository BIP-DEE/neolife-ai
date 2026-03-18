import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/alert_event.dart';
import '../models/placement_mode.dart';
import '../models/sensor_status.dart';
import '../state/app_session_controller.dart';
import '../state/neo_life_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/brand_mark.dart';
import '../widgets/placement_mode_card.dart';
import '../widgets/sensor_metric_card.dart';
import '../widgets/signal_preview_card.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenTrends,
    required this.onOpenAlerts,
  });

  final VoidCallback onOpenTrends;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSessionController, NeoLifeController>(
      builder: (context, session, controller, _) {
        final reading = controller.latestReading;

        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                statusLabel: controller.isConnected ? 'Live' : 'Paused',
              ),
              const SizedBox(height: 18),
              _DashboardHeroCard(
                infantName: session.infantName,
                isConnected: controller.isConnected,
                connectionLabel: controller.connectionLabel,
                status: controller.status,
                qualityValue: controller.signalQuality,
                placementLabel: controller.placementMode.shortLabel,
                placementHelperText: controller.placementMode.helperText,
                heroImagePath: controller.placementMode == PlacementMode.ankle
                    ? 'assets/images/baby_ankle.jpg'
                    : 'assets/images/baby_chest.jpg',
                onToggleConnection: controller.toggleConnection,
                onOpenTrends: onOpenTrends,
                onShowStatusInfo: () => _showStatusSheet(
                  context: context,
                  status: controller.status,
                  explanation: controller.alertExplanation,
                  placementLabel: controller.placementMode.label,
                ),
              ),
              const SizedBox(height: 18),
              PlacementModeCard(
                selectedMode: controller.placementMode,
                helperText: controller.placementMode.helperText,
                onChanged: controller.setPlacementMode,
              ),
              const SizedBox(height: 22),
              _SectionBlock(
                title: 'Live signals',
                actionLabel: 'Trends',
                onActionTap: onOpenTrends,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: columns == 4 ? 1.12 : 1.0,
                      children: [
                        SensorMetricCard(
                          title: 'Heart Rate',
                          value: reading?.heartRate.toString() ?? '--',
                          unit: 'bpm',
                          icon: Icons.favorite_rounded,
                          trendLabel: controller.heartRateTrend,
                          accentColor: const Color(0xFFE67E8D),
                        ),
                        SensorMetricCard(
                          title: 'SpO2',
                          value: reading?.spo2.toString() ?? '--',
                          unit: '%',
                          icon: Icons.bubble_chart_outlined,
                          trendLabel: controller.spo2Trend,
                          accentColor: AppTheme.secondary,
                        ),
                        SensorMetricCard(
                          title: controller.temperatureTitle,
                          value: reading == null
                              ? '--'
                              : reading.temperature.toStringAsFixed(1),
                          unit: 'C',
                          icon: Icons.thermostat_outlined,
                          trendLabel: controller.temperatureTrend,
                          accentColor: const Color(0xFFD7A04A),
                        ),
                        SensorMetricCard(
                          title: controller.placementMetricTitle,
                          value: reading == null
                              ? '--'
                              : controller.placementMetricValue
                                  .toStringAsFixed(0),
                          unit: controller.placementMetricUnit,
                          icon: controller.placementMode == PlacementMode.ankle
                              ? Icons.directions_walk_outlined
                              : Icons.air_outlined,
                          trendLabel: controller.placementTrend,
                          accentColor: AppTheme.accent,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final preview = SignalPreviewCard(
                    history: controller.history,
                    onOpenTrends: onOpenTrends,
                  );
                  final alerts = _DashboardAlertsCard(
                    status: controller.status,
                    explanation: controller.alertExplanation,
                    alertCount: controller.alertHistory.length,
                    latestAlert: controller.alertHistory.isEmpty
                        ? null
                        : controller.alertHistory.first,
                    onOpenAlerts: onOpenAlerts,
                  );

                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: preview),
                            const SizedBox(width: 16),
                            Expanded(flex: 5, child: alerts),
                          ],
                        )
                      : Column(
                          children: [
                            preview,
                            const SizedBox(height: 16),
                            alerts,
                          ],
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showStatusSheet({
    required BuildContext context,
    required SensorStatus status,
    required String explanation,
    required String placementLabel,
  }) {
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                StatusBadge(label: status.label, color: color),
                const SizedBox(height: 14),
                Text(
                  'Monitoring details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(explanation, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  'Active placement: $placementLabel',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.infantName,
    required this.isConnected,
    required this.connectionLabel,
    required this.status,
    required this.qualityValue,
    required this.placementLabel,
    required this.placementHelperText,
    required this.heroImagePath,
    required this.onToggleConnection,
    required this.onOpenTrends,
    required this.onShowStatusInfo,
  });

  final String infantName;
  final bool isConnected;
  final String connectionLabel;
  final SensorStatus status;
  final double qualityValue;
  final String placementLabel;
  final String placementHelperText;
  final String heroImagePath;
  final Future<void> Function() onToggleConnection;
  final VoidCallback onOpenTrends;
  final VoidCallback onShowStatusInfo;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    final statusTitle = switch (status) {
      SensorStatus.stable => 'Stable monitoring',
      SensorStatus.unusual => 'Needs review',
      SensorStatus.anomaly => 'Attention needed',
    };

    final statusLine = switch (status) {
      SensorStatus.stable => '$infantName is resting calmly.',
      SensorStatus.unusual => '$infantName shows a changing trend.',
      SensorStatus.anomaly => '$infantName shows a sustained anomaly.',
    };

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Live overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryDeep,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onShowStatusInfo,
              tooltip: 'Monitoring details',
              icon: const Icon(Icons.info_outline_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          infantName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Text(
              statusTitle,
              key: ValueKey(status),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 22,
          child: Text(
            statusLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(
              label: connectionLabel,
              color: isConnected ? AppTheme.secondary : AppTheme.danger,
            ),
            StatusBadge(label: status.label, color: statusColor),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _HeroStat(
                label: 'Confidence',
                value: '${(qualityValue * 100).round()}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HeroStat(
                label: 'Placement',
                value: placementLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onToggleConnection,
              icon: Icon(
                isConnected
                    ? Icons.pause_circle_outline_rounded
                    : Icons.bluetooth_connected_rounded,
                size: 18,
              ),
              label: Text(isConnected ? 'Pause feed' : 'Connect sensor'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenTrends,
              icon: const Icon(Icons.show_chart_rounded, size: 18),
              label: const Text('View trends'),
            ),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            AppTheme.surfaceSoft.withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final accentPanel = ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: wide ? 0.98 : 1.55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: SizedBox.expand(
                      key: ValueKey(heroImagePath),
                      child: Image.asset(
                        heroImagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryDeep.withValues(alpha: 0.12),
                          AppTheme.primaryDeep.withValues(alpha: 0.82),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const BrandSymbol(compact: true),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        isConnected ? 'Streaming' : 'Paused',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$placementLabel mode active',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            placementHelperText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeroImagePill(
                                icon: Icons.health_and_safety_outlined,
                                label:
                                    '${(qualityValue * 100).round()}% quality',
                              ),
                              StatusBadge(
                                label: status.label,
                                color: statusColor,
                                pulse: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: content),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: accentPanel),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 14),
                    accentPanel,
                  ],
                );
        },
      ),
    );
  }
}

class _HeroImagePill extends StatelessWidget {
  const _HeroImagePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryDeep),
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (actionLabel != null && onActionTap != null)
              OutlinedButton(
                onPressed: onActionTap,
                child: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _DashboardAlertsCard extends StatelessWidget {
  const _DashboardAlertsCard({
    required this.status,
    required this.explanation,
    required this.alertCount,
    required this.latestAlert,
    required this.onOpenAlerts,
  });

  final SensorStatus status;
  final String explanation;
  final int alertCount;
  final AlertEvent? latestAlert;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: status.label, color: color),
              const Spacer(),
              TextButton(
                onPressed: onOpenAlerts,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Alert summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _HeroStat(
            label: 'Recent alerts',
            value: '$alertCount in timeline',
          ),
          if (latestAlert != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latestAlert!.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestAlert!.details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onOpenAlerts,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.notifications_none_rounded, size: 18),
            label: const Text('Open alert timeline'),
          ),
        ],
      ),
    );
  }
}
