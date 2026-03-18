import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/sensor_status.dart';

class StatusSummaryCard extends StatelessWidget {
  const StatusSummaryCard({
    super.key,
    required this.status,
    required this.explanation,
    required this.placementLabel,
  });

  final SensorStatus status;
  final String explanation;
  final String placementLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    final headline = switch (status) {
      SensorStatus.stable => 'Monitoring looks calm',
      SensorStatus.unusual => 'Trend needs review',
      SensorStatus.anomaly => 'Pattern is sustained',
    };

    final guidance = switch (status) {
      SensorStatus.stable =>
        'Continue monitoring and keep the wearable fit consistent.',
      SensorStatus.unusual =>
        'Review placement and observe the next few live samples.',
      SensorStatus.anomaly =>
        'Treat this as a stronger demo alert and investigate quickly.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.24),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  placementLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: Text(
              explanation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested response',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 36,
                  child: Text(
                    guidance,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusLegendChip(color: AppTheme.stable, label: 'Stable'),
              _StatusLegendChip(color: AppTheme.warning, label: 'Review'),
              _StatusLegendChip(color: AppTheme.danger, label: 'Alert'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusLegendChip extends StatelessWidget {
  const _StatusLegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
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
