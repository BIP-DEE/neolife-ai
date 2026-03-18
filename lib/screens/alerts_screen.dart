import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/placement_mode.dart';
import '../state/neo_life_controller.dart';
import '../widgets/alert_history_card.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/status_summary_card.dart';

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
                    'Keep the current explanation clear, then scan the recent timeline below it.',
                statusLabel: '${controller.alertHistory.length} recent',
              ),
              const SizedBox(height: 18),
              StatusSummaryCard(
                status: controller.status,
                explanation: controller.alertExplanation,
                placementLabel: controller.placementMode.label,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onOpenDevice,
                  icon: const Icon(Icons.bluetooth_connected_rounded, size: 18),
                  label: const Text('Review device fit'),
                ),
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
