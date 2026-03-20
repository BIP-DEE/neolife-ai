import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/sensor_reading.dart';

class SignalPreviewCard extends StatelessWidget {
  const SignalPreviewCard({
    super.key,
    required this.history,
    required this.onOpenTrends,
  });

  final List<SensorReading> history;
  final VoidCallback onOpenTrends;

  @override
  Widget build(BuildContext context) {
    final samples = history.isEmpty ? _fallbackSamples : history;
    final heartRateSpots = <FlSpot>[];
    final spo2Spots = <FlSpot>[];
    final latestSample = samples.last;

    for (var i = 0; i < samples.length; i++) {
      heartRateSpots.add(FlSpot(i.toDouble(), samples[i].heartRate.toDouble()));
      spo2Spots.add(FlSpot(i.toDouble(), samples[i].spo2.toDouble()));
    }

    final allValues = [
      ...heartRateSpots.map((spot) => spot.y),
      ...spo2Spots.map((spot) => spot.y),
    ];
    final minY = allValues.reduce(min) - 4;
    final maxY = allValues.reduce(max) + 4;

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
              final compact = constraints.maxWidth < 520;

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signal preview',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A quick view of heart rate and oxygen trends before opening the full chart.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onOpenTrends,
                          icon: const Icon(Icons.show_chart_rounded, size: 18),
                          label: const Text('Open trends'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signal preview',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A quick view of heart rate and oxygen trends before opening the full chart.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: onOpenTrends,
                          icon: const Icon(Icons.show_chart_rounded, size: 18),
                          label: const Text('Open trends'),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PreviewInfoPill(
                label: 'HR ${latestSample.heartRate} bpm',
                color: const Color(0xFFE67E8D),
              ),
              _PreviewInfoPill(
                label: 'SpO2 ${latestSample.spo2}%',
                color: AppTheme.secondary,
              ),
              const _PreviewInfoPill(
                label: 'Last 12 seconds',
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: SizedBox(
              height: 176,
              child: LineChart(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                LineChartData(
                  minX: 0,
                  maxX: (samples.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 6,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            max(1, (samples.length / 3).floor()).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index <= 0) {
                            return _axisLabel(
                                context, '-${samples.length - 1}s');
                          }
                          if (index >= samples.length - 1) {
                            return _axisLabel(context, 'now');
                          }
                          return _axisLabel(
                            context,
                            '-${samples.length - 1 - index}s',
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (_) => AppTheme.textPrimary,
                      getTooltipItems: (items) {
                        return items
                            .map(
                              (item) => LineTooltipItem(
                                item.y.toStringAsFixed(0),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            .toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    _barData(
                      color: const Color(0xFFE67E8D),
                      spots: heartRateSpots,
                    ),
                    _barData(
                      color: AppTheme.secondary,
                      spots: spo2Spots,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendPill(label: 'Heart rate', color: Color(0xFFE67E8D)),
              _LegendPill(label: 'SpO2', color: AppTheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _barData({
    required Color color,
    required List<FlSpot> spots,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.24,
      barWidth: 3,
      color: color,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) =>
            barData.spots.isNotEmpty && spot == barData.spots.last,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.01),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _axisLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  List<SensorReading> get _fallbackSamples => List<SensorReading>.generate(
        8,
        (index) => SensorReading(
          heartRate: 132 + index,
          spo2: 97 - (index % 2),
          temperature: 36.8 + (index * 0.04),
          motionLevel: 36 + index.toDouble(),
          breathingRate: 32 + index.toDouble(),
          signalQuality: 0.84,
          timestamp: DateTime.now().subtract(Duration(seconds: 8 - index)),
        ),
      );
}

class _PreviewInfoPill extends StatelessWidget {
  const _PreviewInfoPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
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

class _LegendPill extends StatelessWidget {
  const _LegendPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
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
