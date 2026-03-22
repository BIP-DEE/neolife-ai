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
                    'Check the current wellness state first, then move into trends, alerts, or device review only when needed.',
                statusLabel: controller.isConnected ? 'Live' : 'Paused',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 1080;
                  final hero = _DashboardHeroCard(
                    status: controller.status,
                    isConnected: controller.isConnected,
                    statusHeadline: controller.statusHeadline,
                    statusCaption: controller.statusCaption,
                    connectionLabel:
                        controller.isConnected ? 'Feed live' : 'Feed paused',
                    nextActionLabel: controller.recommendedActionTitle,
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
                      PlacementModeCard(
                        selectedMode: controller.placementMode,
                        helperText: controller.placementMode.helperText,
                        onChanged: controller.setPlacementMode,
                        subtitle:
                            'Keep placement aligned with how the wearable is being used.',
                        footerLabel: controller.qualityLabel,
                        actionLabel: 'Open device',
                        onActionTap: onOpenDevice,
                      ),
                    ],
                  );

                  if (!desktop) {
                    return Column(
                      children: [
                        hero,
                        const SizedBox(height: 14),
                        liveSignals,
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 14),
                        PlacementModeCard(
                          selectedMode: controller.placementMode,
                          helperText: controller.placementMode.helperText,
                          onChanged: controller.setPlacementMode,
                          title: 'Placement',
                          subtitle: 'Choose the wearable position.',
                          footerLabel: controller.qualityLabel,
                          actionLabel: 'Device',
                          onActionTap: onOpenDevice,
                          compact: true,
                        ),
                        const SizedBox(height: 18),
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
    required this.status,
    required this.isConnected,
    required this.statusHeadline,
    required this.statusCaption,
    required this.connectionLabel,
    required this.nextActionLabel,
    required this.qualityValue,
    required this.placementLabel,
    required this.heroImagePath,
    required this.placementHelperText,
    required this.onToggleConnection,
    required this.onPrimaryAction,
  });

  final SensorStatus status;
  final bool isConnected;
  final String statusHeadline;
  final String statusCaption;
  final String connectionLabel;
  final String nextActionLabel;
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
      padding: AppTheme.panelPadding(context, phone: 12, regular: 18),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 24, regular: 32),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final wide = constraints.maxWidth >= 760;
          final connectButton = FilledButton.icon(
            onPressed: onToggleConnection,
            style: FilledButton.styleFrom(
              minimumSize: Size(
                compact ? 150 : 168,
                compact ? 42 : 48,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
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
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge(label: status.label, color: statusColor),
                  _HeroStatusPill(
                    icon: isConnected
                        ? Icons.bluetooth_connected_rounded
                        : Icons.bluetooth_disabled_rounded,
                    label: isConnected ? 'Pod live' : 'Pod offline',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                statusHeadline,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? Theme.of(context).textTheme.headlineSmall
                            : Theme.of(context).textTheme.headlineMedium)
                        ?.copyWith(height: 1.08),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: compact ? 18 : 40,
                child: Text(
                  statusCaption,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: (compact
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.bodyLarge)
                      ?.copyWith(
                    color:
                        compact ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondarySoft.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.flag_outlined,
                        color: statusColor,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Next: $nextActionLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  connectButton,
                  TextButton.icon(
                    onPressed: onPrimaryAction,
                    icon: const Icon(Icons.insights_outlined, size: 18),
                    label: const Text('More details'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _HeroMetadataStrip(
                items: [
                  _HeroMetadataItem(
                    icon: Icons.wifi_tethering_rounded,
                    text: connectionLabel,
                    tint: AppTheme.secondary,
                  ),
                  _HeroMetadataItem(
                    icon: Icons.shield_outlined,
                    text: 'Confidence ${(qualityValue * 100).round()}%',
                    tint: AppTheme.primaryDeep,
                  ),
                  _HeroMetadataItem(
                    icon: Icons.place_outlined,
                    text: '$placementLabel mode',
                    tint: AppTheme.accent,
                  ),
                ],
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
                          AppTheme.primaryDeep.withValues(alpha: 0.22),
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
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
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
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
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
                              maxLines: 1,
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
              const SizedBox(width: 16),
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
              final stacked = constraints.maxWidth < 340;
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

class _HeroStatusPill extends StatelessWidget {
  const _HeroStatusPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryDeep),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetadataItem {
  const _HeroMetadataItem({
    required this.icon,
    required this.text,
    required this.tint,
  });

  final IconData icon;
  final String text;
  final Color tint;
}

class _HeroMetadataStrip extends StatelessWidget {
  const _HeroMetadataStrip({
    required this.items,
  });

  final List<_HeroMetadataItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final item in items)
            _HeroMetadataInline(
              icon: item.icon,
              text: item.text,
              tint: item.tint,
            ),
        ],
      ),
    );
  }
}

class _HeroMetadataInline extends StatelessWidget {
  const _HeroMetadataInline({
    required this.icon,
    required this.text,
    required this.tint,
  });

  final IconData icon;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: tint),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.4,
                ),
          ),
        ),
      ],
    );
  }
}
