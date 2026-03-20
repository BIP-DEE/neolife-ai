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
        final focusMetric = controller.focusMetricTitle;
        final chartItems = <_TrendItem>[
          _TrendItem(
            title: 'Heart Rate',
            subtitle: controller.heartRateTrend,
            unit: 'bpm',
            color: const Color(0xFFE67E8D),
            values: _buildValues(history, (item) => item.heartRate.toDouble()),
          ),
          _TrendItem(
            title: 'SpO2',
            subtitle: controller.spo2Trend,
            unit: '%',
            color: AppTheme.secondary,
            values: _buildValues(history, (item) => item.spo2.toDouble()),
          ),
          _TrendItem(
            title: controller.temperatureTitle,
            subtitle: controller.temperatureTrend,
            unit: 'C',
            color: const Color(0xFFD7A04A),
            values: _buildValues(history, (item) => item.temperature),
          ),
          _TrendItem(
            title: controller.placementMode == PlacementMode.ankle
                ? 'Motion Trend'
                : 'Breathing Trend',
            subtitle: controller.placementTrend,
            unit: controller.placementMode == PlacementMode.ankle ? '%' : 'rpm',
            color: AppTheme.accent,
            values: _buildValues(
              history,
              (item) => controller.placementMode == PlacementMode.ankle
                  ? item.motionLevel
                  : item.breathingRate,
            ),
          ),
        ];

        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Trend analysis',
                title: 'Live trends',
                subtitle:
                    'See how values evolved across the latest sample window and which metric matters most right now.',
                statusLabel: controller.isConnected ? 'Streaming' : 'Paused',
              ),
              const SizedBox(height: 18),
              _TrendHeroCard(
                status: controller.status,
                placementLabel: controller.placementMode.label,
                explanation: controller.alertExplanation,
                focusMetricTitle: focusMetric,
                reading: reading,
                historyLength: history.length,
              ),
              const SizedBox(height: 24),
              _TrendSectionHeader(
                eyebrow: 'Charts',
                title: 'How values evolved',
                subtitle:
                    'The highlighted chart reflects the most relevant metric from the current monitoring state.',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final cards = chartItems
                      .map(
                        (item) => TrendChartCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          unit: item.unit,
                          color: item.color,
                          values: item.values,
                          highlighted: item.title == focusMetric,
                        ),
                      )
                      .toList(growable: false);

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

class _TrendHeroCard extends StatelessWidget {
  const _TrendHeroCard({
    required this.status,
    required this.placementLabel,
    required this.explanation,
    required this.focusMetricTitle,
    required this.reading,
    required this.historyLength,
  });

  final SensorStatus status;
  final String placementLabel;
  final String explanation;
  final String focusMetricTitle;
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 880;
          final overview = Column(
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
                  StatusBadge(
                    label: 'Current focus',
                    color: AppTheme.secondary,
                    icon: Icons.show_chart_rounded,
                    pulse: false,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Most relevant right now: $focusMetricTitle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  explanation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 520;
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

                  if (compact) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.9,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: stats,
                    );
                  }

                  return Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        Expanded(child: stats[i]),
                        if (i != stats.length - 1) const SizedBox(width: 10),
                      ],
                    ],
                  );
                },
              ),
            ],
          );

          final support = Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interpretation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  focusMetricTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the highlighted chart first, then compare the supporting signals beneath it.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                const _SupportHint(
                  title: 'Read first',
                  body:
                      'Focus on the highlighted chart before comparing the secondary signals.',
                ),
                const SizedBox(height: 12),
                const _SupportHint(
                  title: 'Then compare',
                  body:
                      'Look for whether heart rate, oxygen, and breathing or motion are shifting together.',
                ),
              ],
            ),
          );

          if (!wide) {
            return Column(
              children: [
                overview,
                const SizedBox(height: 16),
                support,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: overview),
              const SizedBox(width: 18),
              Expanded(flex: 4, child: support),
            ],
          );
        },
      ),
    );
  }
}

class _TrendSectionHeader extends StatelessWidget {
  const _TrendSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
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
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
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

class _SupportHint extends StatelessWidget {
  const _SupportHint({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _TrendItem {
  const _TrendItem({
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.color,
    required this.values,
  });

  final String title;
  final String subtitle;
  final String unit;
  final Color color;
  final List<double> values;
}
