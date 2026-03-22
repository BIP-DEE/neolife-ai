import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';
import '../models/sensor_status.dart';
import '../state/neo_life_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/placement_mode_card.dart';
import '../widgets/product_showcase_card.dart';
import '../widgets/quality_indicator_card.dart';
import '../widgets/status_badge.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({
    super.key,
    required this.onOpenTrends,
    required this.onOpenAlerts,
  });

  final VoidCallback onOpenTrends;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    return Consumer<NeoLifeController>(
      builder: (context, controller, _) {
        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Device setup',
                title: 'Wearable and placement',
                subtitle:
                    'Connection, fit, placement, and signal quality are grouped here so caregivers can adjust the device quickly.',
                statusLabel:
                    controller.isConnected ? 'Connected' : 'Disconnected',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final overview = _DeviceOverviewCard(
                    isConnected: controller.isConnected,
                    status: controller.status,
                    placementMode: controller.placementMode,
                    qualityValue: controller.signalQuality,
                    onToggleConnection: controller.toggleConnection,
                    onOpenTrends: onOpenTrends,
                    onOpenAlerts: onOpenAlerts,
                  );
                  final quality = QualityIndicatorCard(
                    value: controller.signalQuality,
                    label: controller.qualityLabel,
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        overview,
                        const SizedBox(height: 16),
                        quality,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: overview),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: quality),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const _DeviceSectionHeader(
                eyebrow: 'Setup',
                title: 'Placement and fit',
                subtitle:
                    'Choose the wearable position and review the fit notes together so changes remain deliberate.',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final placement = PlacementModeCard(
                    selectedMode: controller.placementMode,
                    helperText: controller.placementMode.helperText,
                    onChanged: controller.setPlacementMode,
                    subtitle:
                        'Select the wearable position that matches the current fit.',
                    footerLabel: controller.qualityLabel,
                  );
                  final steps = _SetupStepsCard(
                    currentMode: controller.placementMode,
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        placement,
                        const SizedBox(height: 16),
                        steps,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: placement),
                      const SizedBox(width: 18),
                      Expanded(flex: 5, child: steps),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const _DeviceSectionHeader(
                eyebrow: 'Hardware',
                title: 'Product showcase',
                subtitle:
                    'This section stays visually secondary so setup guidance remains more important than the hardware render.',
              ),
              const SizedBox(height: 14),
              const ProductShowcaseCard(
                eyebrow: 'Hardware view',
                title: 'Sensor pod detail',
                description:
                    'A calmer hardware view supports product trust without competing with the setup workflow.',
                imageAssetPath: 'assets/images/pod_exploded.png',
                tags: [
                  'BLE-ready architecture',
                  'NeoLife hardware concept',
                  'Future sensor integration',
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceOverviewCard extends StatelessWidget {
  const _DeviceOverviewCard({
    required this.isConnected,
    required this.status,
    required this.placementMode,
    required this.qualityValue,
    required this.onToggleConnection,
    required this.onOpenTrends,
    required this.onOpenAlerts,
  });

  final bool isConnected;
  final SensorStatus status;
  final PlacementMode placementMode;
  final double qualityValue;
  final Future<void> Function() onToggleConnection;
  final VoidCallback onOpenTrends;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      SensorStatus.stable => AppTheme.stable,
      SensorStatus.unusual => AppTheme.warning,
      SensorStatus.anomaly => AppTheme.danger,
    };
    final image = placementMode == PlacementMode.ankle
        ? 'assets/images/baby_ankle.jpg'
        : 'assets/images/baby_chest.jpg';

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;
          final copy = Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      label: isConnected ? 'Sensor online' : 'Sensor paused',
                      color: isConnected ? AppTheme.secondary : AppTheme.danger,
                    ),
                    StatusBadge(label: status.label, color: statusColor),
                    StatusBadge(
                      label: placementMode.shortLabel,
                      color: AppTheme.accent,
                      icon: Icons.place_outlined,
                      pulse: false,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Connection and fit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isConnected
                      ? 'The wearable is ready for monitoring.'
                      : 'The wearable is paused right now.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Keep placement, confidence, and connection in one place so the caregiver can correct setup issues quickly.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _DeviceStat(
                        label: 'Confidence',
                        value: '${(qualityValue * 100).round()}%',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DeviceStat(
                        label: 'Placement',
                        value: placementMode.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: onToggleConnection,
                      child:
                          Text(isConnected ? 'Disconnect pod' : 'Connect pod'),
                    ),
                    OutlinedButton(
                      onPressed: onOpenTrends,
                      child: const Text('Open trends'),
                    ),
                    TextButton(
                      onPressed: onOpenAlerts,
                      child: const Text('See alerts'),
                    ),
                  ],
                ),
              ],
            ),
          );

          final visual = Padding(
            padding: EdgeInsets.fromLTRB(wide ? 0 : 20, 0, 20, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: wide ? 0.96 : 1.42,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          );

          if (!wide) {
            return Column(
              children: [
                copy,
                visual,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 10, child: copy),
              Expanded(flex: 7, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _SetupStepsCard extends StatelessWidget {
  const _SetupStepsCard({
    required this.currentMode,
  });

  final PlacementMode currentMode;

  @override
  Widget build(BuildContext context) {
    final guidance = currentMode == PlacementMode.ankle
        ? const [
            'Wrap the ankle band so the pod sits flat without pinching.',
            'Keep the infant warm to preserve temperature trend quality.',
            'Expect motion to influence the feed more during active moments.',
          ]
        : const [
            'Place the chest band snugly across the upper torso.',
            'Confirm smooth breathing movement beneath the wearable.',
            'Use chest placement when breathing effort and temperature trend are the main focus.',
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fit guidance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Keep these setup notes visible while adjusting the wearable.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final item in guidance) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppTheme.primaryDeep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            if (item != guidance.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DeviceSectionHeader extends StatelessWidget {
  const _DeviceSectionHeader({
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

class _DeviceStat extends StatelessWidget {
  const _DeviceStat({
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
        borderRadius: BorderRadius.circular(18),
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
