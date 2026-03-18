import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/alert_event.dart';
import '../models/sensor_status.dart';

class AlertHistoryCard extends StatelessWidget {
  const AlertHistoryCard({
    super.key,
    required this.alerts,
  });

  final List<AlertEvent> alerts;

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = alerts.take(4).toList(growable: false);

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
              Expanded(
                child: Text(
                  'Alert history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Recent timeline',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (visibleAlerts.isEmpty)
            Text(
              'No alerts captured yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (var index = 0; index < visibleAlerts.length; index++) ...[
              _AlertRow(alert: visibleAlerts[index]),
              if (index != visibleAlerts.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final AlertEvent alert;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    final icon = switch (alert.status) {
      SensorStatus.stable => Icons.check_circle_outline,
      SensorStatus.unusual => Icons.health_and_safety_outlined,
      SensorStatus.anomaly => Icons.warning_amber_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _formatTimestamp(alert.timestamp),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.details,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final normalizedHour = hour == 0 ? 12 : hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$normalizedHour:$minute $suffix';
  }
}
