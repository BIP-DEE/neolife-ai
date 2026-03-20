import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.color,
    required this.values,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final String unit;
  final Color color;
  final List<double> values;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final chartValues =
        values.length < 2 ? <double>[...values, ...values] : values;
    final minValue = chartValues.reduce(min);
    final maxValue = chartValues.reduce(max);
    final average = chartValues.reduce((a, b) => a + b) / chartValues.length;
    final current = chartValues.last;
    final padding = max(1.0, (maxValue - minValue) * 0.30);
    final minY = minValue - padding;
    final maxY = maxValue + padding;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: highlighted ? 0.12 : 0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: highlighted ? color.withValues(alpha: 0.28) : AppTheme.border,
          width: highlighted ? 1.2 : 1,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (highlighted) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Current focus',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${current.toStringAsFixed(unit == 'C' ? 1 : 0)} $unit',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    _ChartStatPill(
                      label:
                          'avg ${average.toStringAsFixed(unit == 'C' ? 1 : 0)} $unit',
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        max(1, ((maxY - minY) / 4).round()).toDouble(),
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            max(1, (chartValues.length / 3).floor()).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index <= 0) {
                            return _axisLabel(
                                context, '-${chartValues.length - 1}s');
                          }
                          if (index >= chartValues.length - 1) {
                            return _axisLabel(context, 'now');
                          }
                          final secondsAgo = chartValues.length - 1 - index;
                          return _axisLabel(context, '-${secondsAgo}s');
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
                      tooltipBorderRadius: BorderRadius.circular(16),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      getTooltipColor: (_) => AppTheme.textPrimary,
                      getTooltipItems: (spots) {
                        return spots
                            .map(
                              (spot) => LineTooltipItem(
                                '${spot.y.toStringAsFixed(unit == 'C' ? 1 : 0)} $unit',
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
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < chartValues.length; i++)
                          FlSpot(i.toDouble(), chartValues[i]),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.26,
                      barWidth: 3.6,
                      color: color,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            barData.spots.isNotEmpty &&
                            spot == barData.spots.last,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4.2,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.26),
                            color.withValues(alpha: 0.02),
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
          ],
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
}

class _ChartStatPill extends StatelessWidget {
  const _ChartStatPill({
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
