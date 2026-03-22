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
import '../widgets/placement_mode_selector.dart';
import '../widgets/sensor_metric_card.dart';
import '../widgets/signal_preview_card.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenTrends,
    required this.onOpenAlerts,
    required this.onOpenDevice,
  });

  final VoidCallback onOpenTrends;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenDevice;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSessionController, NeoLifeController>(
      builder: (context, session, controller, _) {
        final reading = controller.latestReading;
        final latestAlert = controller.alertHistory.isEmpty
            ? null
            : controller.alertHistory.first;

        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Now monitoring',
                title: session.infantName,
                subtitle:
                    'See the current wellness state first, then move into trends, alerts, or device review only when needed.',
                statusLabel: controller.isConnected ? 'Live' : 'Paused',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 1080;
                  final hero = _DashboardHeroCard(
                    infantName: session.infantName,
                    status: controller.status,
                    isConnected: controller.isConnected,
                    statusHeadline: controller.statusHeadline,
                    statusCaption: controller.statusCaption,
                    connectionLabel:
                        controller.isConnected ? 'Feed live' : 'Feed paused',
                    qualityValue: controller.signalQuality,
                    placementLabel: controller.placementMode.shortLabel,
                    heroImagePath:
                        controller.placementMode == PlacementMode.ankle
                            ? 'assets/images/baby_ankle.jpg'
                            : 'assets/images/baby_chest.jpg',
                    placementHelperText: controller.placementMode.helperText,
                    onToggleConnection: controller.toggleConnection,
                    onPrimaryAction: () => _showStatusSheet(
                      context: context,
                      status: controller.status,
                      explanation: controller.alertExplanation,
                      placementLabel: controller.placementMode.label,
                    ),
                  );

                  final liveSignals = _SectionBlock(
                    eyebrow: 'Live now',
                    title: 'Key wellness signals',
                    subtitle: 'The latest values caregivers should scan first.',
                    actionLabel: 'Trends',
                    onActionTap: onOpenTrends,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900 ? 4 : 2;
                        final narrow = constraints.maxWidth < 380;
                        return GridView.count(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: columns == 4
                              ? 1.14
                              : narrow
                                  ? 0.84
                                  : 1.0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                              icon: controller.placementMode ==
                                      PlacementMode.ankle
                                  ? Icons.directions_walk_outlined
                                  : Icons.air_outlined,
                              trendLabel: controller.placementTrend,
                              accentColor: AppTheme.accent,
                            ),
                          ],
                        );
                      },
                    ),
                  );

                  final recentChanges = _SectionBlock(
                    eyebrow: 'Recent changes',
                    title: 'What changed most recently',
                    subtitle:
                        'Use Trends to understand the pattern, or Alerts to review cause and follow-up.',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 940;
                        final preview = SignalPreviewCard(
                          history: controller.history,
                          onOpenTrends: onOpenTrends,
                        );
                        final changes = _RecentChangesCard(
                          status: controller.status,
                          summaryText: controller.dashboardSummary,
                          latestAlert: latestAlert,
                          alertCount: controller.alertHistory.length,
                          onOpenAlerts: onOpenAlerts,
                        );

                        if (!wide) {
                          return Column(
                            children: [
                              preview,
                              const SizedBox(height: 16),
                              changes,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 8, child: preview),
                            const SizedBox(width: 18),
                            Expanded(flex: 5, child: changes),
                          ],
                        );
                      },
                    ),
                  );

                  final supportColumn = Column(
                    children: [
                      _RecommendedActionCard(
                        status: controller.status,
                        attentionLabel: controller.attentionLabel,
                        title: controller.recommendedActionTitle,
                        detail: controller.recommendedActionDetail,
                        isConnected: controller.isConnected,
                        onOpenTrends: onOpenTrends,
                        onOpenAlerts: onOpenAlerts,
                        onOpenDevice: onOpenDevice,
                      ),
                      const SizedBox(height: 16),
                      _PlacementQuickCard(
                        selectedMode: controller.placementMode,
                        helperText: controller.placementMode.helperText,
                        qualityLabel: controller.qualityLabel,
                        onChanged: controller.setPlacementMode,
                        onOpenDevice: onOpenDevice,
                      ),
                    ],
                  );

                  if (!desktop) {
                    return Column(
                      children: [
                        hero,
                        const SizedBox(height: 18),
                        liveSignals,
                        const SizedBox(height: 20),
                        _RecommendedActionCard(
                          status: controller.status,
                          attentionLabel: controller.attentionLabel,
                          title: controller.recommendedActionTitle,
                          detail: controller.recommendedActionDetail,
                          isConnected: controller.isConnected,
                          onOpenTrends: onOpenTrends,
                          onOpenAlerts: onOpenAlerts,
                          onOpenDevice: onOpenDevice,
                        ),
                        const SizedBox(height: 18),
                        _PlacementQuickCard(
                          selectedMode: controller.placementMode,
                          helperText: controller.placementMode.helperText,
                          qualityLabel: controller.qualityLabel,
                          onChanged: controller.setPlacementMode,
                          onOpenDevice: onOpenDevice,
                        ),
                        const SizedBox(height: 20),
                        recentChanges,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: [
                            hero,
                            const SizedBox(height: 22),
                            liveSignals,
                            const SizedBox(height: 24),
                            recentChanges,
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: supportColumn),
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
    required this.status,
    required this.isConnected,
    required this.statusHeadline,
    required this.statusCaption,
    required this.connectionLabel,
    required this.qualityValue,
    required this.placementLabel,
    required this.heroImagePath,
    required this.placementHelperText,
    required this.onToggleConnection,
    required this.onPrimaryAction,
  });

  final String infantName;
  final SensorStatus status;
  final bool isConnected;
  final String statusHeadline;
  final String statusCaption;
  final String connectionLabel;
  final double qualityValue;
  final String placementLabel;
  final String heroImagePath;
  final String placementHelperText;
  final Future<void> Function() onToggleConnection;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    return Container(
      width: double.infinity,
      padding: AppTheme.panelPadding(context, phone: 14, regular: 18),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 26, regular: 32),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final wide = constraints.maxWidth >= 760;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      infantName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatusBadge(label: status.label, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                statusHeadline,
                style: (compact
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: SizedBox(
                  height: compact ? 18 : 42,
                  child: Text(
                    statusCaption,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: (compact
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodyLarge)
                        ?.copyWith(
                      color: compact
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 9 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondarySoft.withValues(alpha: 0.85),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.border),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 400;
                    final details = Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isConnected
                                ? Icons.bluetooth_connected_rounded
                                : Icons.bluetooth_disabled_rounded,
                            size: 16,
                            color: AppTheme.primaryDeep,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isConnected ? 'Pod connected' : 'Pod disconnected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    );
                    final button = FilledButton.icon(
                      onPressed: onToggleConnection,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(
                          stacked
                              ? double.infinity
                              : compact
                                  ? 138
                                  : 168,
                          compact ? 40 : 48,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 10 : 16,
                          vertical: compact ? 10 : 14,
                        ),
                      ),
                      icon: Icon(
                        isConnected
                            ? Icons.bluetooth_disabled_rounded
                            : Icons.bluetooth_connected_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isConnected ? 'Disconnect pod' : 'Reconnect pod',
                      ),
                    );

                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          details,
                          const SizedBox(height: 10),
                          button,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: details),
                        const SizedBox(width: 10),
                        button,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _HeroInfoTile(
                    text: connectionLabel,
                    icon: Icons.wifi_tethering_rounded,
                    tint: AppTheme.secondary,
                  ),
                  _HeroInfoTile(
                    text: 'Confidence ${(qualityValue * 100).round()}%',
                    icon: Icons.shield_outlined,
                    tint: AppTheme.primaryDeep,
                  ),
                  _HeroInfoTile(
                    text: '$placementLabel mode',
                    icon: Icons.place_outlined,
                    tint: AppTheme.accent,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onPrimaryAction,
                  icon: const Icon(Icons.insights_outlined, size: 18),
                  label: const Text('More details'),
                ),
              ),
            ],
          );

          final visual = ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: wide ? 1.12 : 2.05,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(heroImagePath, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryDeep.withValues(alpha: 0.02),
                          AppTheme.primaryDeep.withValues(alpha: 0.32),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
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
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.48),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.touch_app_outlined,
                            size: 18,
                            color: AppTheme.primaryDeep,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              placementHelperText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (!wide) {
            return copy;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: copy),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _RecommendedActionCard extends StatelessWidget {
  const _RecommendedActionCard({
    required this.status,
    required this.attentionLabel,
    required this.title,
    required this.detail,
    required this.isConnected,
    required this.onOpenTrends,
    required this.onOpenAlerts,
    required this.onOpenDevice,
  });

  final SensorStatus status;
  final String attentionLabel;
  final String title;
  final String detail;
  final bool isConnected;
  final VoidCallback onOpenTrends;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenDevice;

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    final primaryLabel = !isConnected
        ? 'Open device setup'
        : status == SensorStatus.stable
            ? 'Review trends'
            : 'Open alerts';
    final primaryTap = !isConnected
        ? onOpenDevice
        : status == SensorStatus.stable
            ? onOpenTrends
            : onOpenAlerts;

    return Container(
      width: double.infinity,
      padding: AppTheme.panelPadding(context, phone: 14, regular: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 24, regular: 30),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended action',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: compact ? 40 : 44,
            child: Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 11 : 14,
              vertical: compact ? 9 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(compact ? 18 : 20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 34 : 38,
                  height: compact ? 34 : 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.flag_outlined, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Needs attention',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attentionLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: primaryTap,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            icon: Icon(
              !isConnected
                  ? Icons.bluetooth_searching_rounded
                  : status == SensorStatus.stable
                      ? Icons.show_chart_rounded
                      : Icons.notifications_active_outlined,
              size: 18,
            ),
            label: Text(primaryLabel),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onOpenDevice,
            icon: const Icon(Icons.medical_information_outlined, size: 18),
            label: const Text('Review device fit'),
          ),
        ],
      ),
    );
  }
}

class _PlacementQuickCard extends StatelessWidget {
  const _PlacementQuickCard({
    required this.selectedMode,
    required this.helperText,
    required this.qualityLabel,
    required this.onChanged,
    required this.onOpenDevice,
  });

  final PlacementMode selectedMode;
  final String helperText;
  final String qualityLabel;
  final ValueChanged<PlacementMode> onChanged;
  final VoidCallback onOpenDevice;

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);
    return Container(
      width: double.infinity,
      padding: AppTheme.panelPadding(context, phone: 12, regular: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 24, regular: 30),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 360;
              final titleBlock = Text(
                'Placement mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: compact ? 15 : null,
                    ),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: onOpenDevice,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Device'),
                  ),
                ],
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: 8),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          PlacementModeSelector(
            selectedMode: selectedMode,
            onChanged: onChanged,
            compact: compact,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 360;
              final helper = Expanded(
                child: Text(
                  helperText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              );
              final meta = Text(
                qualityLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: meta),
                        TextButton(
                          onPressed: onOpenDevice,
                          child: const Text('Open'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      helperText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  helper,
                  const SizedBox(width: 12),
                  meta,
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: onOpenDevice,
                    child: const Text('Open'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.eyebrow,
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 540;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (narrow && actionLabel != null && onActionTap != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onActionTap,
                child: Text(actionLabel!),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (actionLabel != null && onActionTap != null) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _RecentChangesCard extends StatelessWidget {
  const _RecentChangesCard({
    required this.status,
    required this.summaryText,
    required this.latestAlert,
    required this.alertCount,
    required this.onOpenAlerts,
  });

  final SensorStatus status;
  final String summaryText;
  final AlertEvent? latestAlert;
  final int alertCount;
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
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 270;
              final countPill = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$alertCount recent',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(label: status.label, color: color),
                    const SizedBox(height: 8),
                    countPill,
                  ],
                );
              }

              return Row(
                children: [
                  StatusBadge(label: status.label, color: color),
                  const Spacer(),
                  countPill,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Needs attention',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: Text(
              summaryText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (latestAlert != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(20),
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatAlertTime(latestAlert!.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onOpenAlerts,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            icon: const Icon(Icons.notifications_none_rounded, size: 18),
            label: const Text('Open alert timeline'),
          ),
        ],
      ),
    );
  }

  String _formatAlertTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Updated just now';
    }
    if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes} min ago';
    }
    return 'Updated ${difference.inHours} hr ago';
  }
}

class _HeroInfoTile extends StatelessWidget {
  const _HeroInfoTile({
    required this.text,
    required this.icon,
    required this.tint,
  });

  final String text;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  fontSize: 12.5,
                ),
          ),
        ],
      ),
    );
  }
}
