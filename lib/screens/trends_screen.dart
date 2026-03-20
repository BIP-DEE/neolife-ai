import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';
import '../models/sensor_reading.dart';
import '../models/sensor_status.dart';
import '../state/neo_life_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/status_badge.dart';
import '../widgets/trend_chart_card.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NeoLifeController>(
      builder: (context, controller, _) {
        final history = controller.history;
        final reading = controller.latestReading;

        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Trend analysis',
                title: 'Live trends',
                subtitle:
                    'A cleaner chart view for validating changes over time without overwhelming the caregiver.',
                statusLabel: controller.isConnected ? 'Streaming' : 'Paused',
              ),
              const SizedBox(height: 18),
              _TrendOverviewCard(
                status: controller.status,
                placementLabel: controller.placementMode.label,
                reading: reading,
                historyLength: history.length,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final cards = [
                    TrendChartCard(
                      title: 'Heart Rate',
                      subtitle: controller.heartRateTrend,
                      unit: 'bpm',
                      color: const Color(0xFFE67E8D),
                      values: _buildValues(
                          history, (item) => item.heartRate.toDouble()),
                    ),
                    TrendChartCard(
                      title: 'SpO2',
                      subtitle: controller.spo2Trend,
                      unit: '%',
                      color: AppTheme.secondary,
                      values:
                          _buildValues(history, (item) => item.spo2.toDouble()),
                    ),
                    TrendChartCard(
                      title: controller.temperatureTitle,
                      subtitle: controller.temperatureTrend,
                      unit: 'C',
                      color: const Color(0xFFD7A04A),
                      values: _buildValues(history, (item) => item.temperature),
                    ),
                    TrendChartCard(
                      title: controller.placementMode == PlacementMode.ankle
                          ? 'Motion'
                          : 'Breathing',
                      subtitle: controller.placementTrend,
                      unit: controller.placementMode == PlacementMode.ankle
                          ? '%'
                          : 'rpm',
                      color: AppTheme.accent,
                      values: _buildValues(
                        history,
                        (item) =>
                            controller.placementMode == PlacementMode.ankle
                                ? item.motionLevel
                                : item.breathingRate,
                      ),
                    ),
                  ];

                  if (!wide) {
                    return Column(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          cards[i],
                          if (i != cards.length - 1) const SizedBox(height: 14),
                        ],
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 14),
                          Expanded(child: cards[1]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 14),
                          Expanded(child: cards[3]),
                        ],
                      ),
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

  List<double> _buildValues(
    List<SensorReading> history,
    double Function(SensorReading reading) selector,
  ) {
    if (history.isEmpty) {
      return const [0, 0, 0, 0, 0];
    }

    return history.map(selector).toList(growable: false);
  }
}

class _TrendOverviewCard extends StatelessWidget {
  const _TrendOverviewCard({
    required this.status,
    required this.placementLabel,
    required this.reading,
    required this.historyLength,
  });

  final SensorStatus status;
  final String placementLabel;
  final SensorReading? reading;
  final int historyLength;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(label: status.label, color: statusColor),
              StatusBadge(
                label: placementLabel,
                color: AppTheme.accent,
                icon: Icons.place_outlined,
                pulse: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final stats = [
                _TrendStat(
                  label: 'Current HR',
                  value: '${reading?.heartRate ?? '--'} bpm',
                ),
                _TrendStat(
                  label: 'Current SpO2',
                  value: '${reading?.spo2 ?? '--'}%',
                ),
                _TrendStat(
                  label: 'Current temperature',
                  value: reading == null
                      ? '--'
                      : '${reading!.temperature.toStringAsFixed(1)} C',
                ),
                _TrendStat(
                  label: 'Samples',
                  value: '$historyLength',
                ),
              ];

              return wide
                  ? Row(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          Expanded(child: stats[i]),
                          if (i != stats.length - 1) const SizedBox(width: 10),
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          stats[i],
                          if (i != stats.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _TrendStat extends StatelessWidget {
  const _TrendStat({
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
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
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
