import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';
import '../models/sensor_status.dart';
import '../state/neo_life_controller.dart';
import '../widgets/alert_history_card.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/status_badge.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({
    super.key,
    required this.onOpenDevice,
  });

  final VoidCallback onOpenDevice;

  @override
  Widget build(BuildContext context) {
    return Consumer<NeoLifeController>(
      builder: (context, controller, _) {
        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Alert center',
                title: 'Alerts and history',
                subtitle:
                    'Triage what changed, understand the cause, and move quickly to the right follow-up action.',
                statusLabel: '${controller.alertHistory.length} recent',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final triage = _AlertTriageCard(
                    status: controller.status,
                    statusHeadline: controller.statusHeadline,
                    explanation: controller.alertExplanation,
                    recommendedActionTitle: controller.recommendedActionTitle,
                    recommendedActionDetail: controller.recommendedActionDetail,
                    placementLabel: controller.placementMode.label,
                    alertCount: controller.alertHistory.length,
                  );
                  final support = _AlertSupportCard(
                    status: controller.status,
                    attentionLabel: controller.attentionLabel,
                    onOpenDevice: onOpenDevice,
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        triage,
                        const SizedBox(height: 16),
                        support,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: triage),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: support),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _AlertSectionHeader(
                eyebrow: 'Recent changes',
                title: 'Timeline',
                subtitle:
                    'Recent events are ordered by time so caregivers can scan from newest to oldest quickly.',
              ),
              const SizedBox(height: 14),
              AlertHistoryCard(alerts: controller.alertHistory),
            ],
          ),
        );
      },
    );
  }
}

class _AlertTriageCard extends StatelessWidget {
  const _AlertTriageCard({
    required this.status,
    required this.statusHeadline,
    required this.explanation,
    required this.recommendedActionTitle,
    required this.recommendedActionDetail,
    required this.placementLabel,
    required this.alertCount,
  });

  final SensorStatus status;
  final String statusHeadline;
  final String explanation;
  final String recommendedActionTitle;
  final String recommendedActionDetail;
  final String placementLabel;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
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
              StatusBadge(label: status.label, color: color),
              StatusBadge(
                label: placementLabel,
                color: AppTheme.accent,
                icon: Icons.place_outlined,
                pulse: false,
              ),
              StatusBadge(
                label: '$alertCount recent',
                color: AppTheme.secondary,
                icon: Icons.notifications_none_rounded,
                pulse: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Current status',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            statusHeadline,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(explanation, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 620;
              final cause = _TriageBlock(
                eyebrow: 'Likely cause',
                title: 'What changed',
                body: explanation,
              );
              final action = _TriageBlock(
                eyebrow: 'Recommended action',
                title: recommendedActionTitle,
                body: recommendedActionDetail,
              );

              if (!wide) {
                return Column(
                  children: [
                    cause,
                    const SizedBox(height: 12),
                    action,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cause),
                  const SizedBox(width: 12),
                  Expanded(child: action),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AlertSupportCard extends StatelessWidget {
  const _AlertSupportCard({
    required this.status,
    required this.attentionLabel,
    required this.onOpenDevice,
  });

  final SensorStatus status;
  final String attentionLabel;
  final VoidCallback onOpenDevice;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };

    final guidance = switch (status) {
      SensorStatus.stable =>
        'No immediate intervention is needed. Keep the current fit and continue monitoring.',
      SensorStatus.unusual =>
        'Confirm placement and device fit first, then review the latest trend shift.',
      SensorStatus.anomaly =>
        'Start with the device fit review so the caregiver can rule out signal contact issues quickly.',
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
          Text(
            'Suggested follow-up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(attentionLabel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(guidance, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended first step',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review device fit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onOpenDevice,
            style:
                OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.bluetooth_connected_rounded, size: 18),
            label: const Text('Review device fit'),
          ),
        ],
      ),
    );
  }
}

class _TriageBlock extends StatelessWidget {
  const _TriageBlock({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
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
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AlertSectionHeader extends StatelessWidget {
  const _AlertSectionHeader({
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
