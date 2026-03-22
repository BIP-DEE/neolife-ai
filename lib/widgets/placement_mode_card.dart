import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';
import 'placement_mode_selector.dart';

class PlacementModeCard extends StatelessWidget {
  const PlacementModeCard({
    super.key,
    required this.selectedMode,
    required this.helperText,
    required this.onChanged,
  });

  final PlacementMode selectedMode;
  final String helperText;
  final ValueChanged<PlacementMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);
    return Container(
      width: double.infinity,
      padding: AppTheme.panelPadding(context, phone: 14, regular: 18),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
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
            'Placement mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: compact ? 15 : null,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the wearable position with one tap.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          PlacementModeSelector(
            selectedMode: selectedMode,
            onChanged: onChanged,
            compact: compact,
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Icon(
                  selectedMode == PlacementMode.ankle
                      ? Icons.directions_walk_rounded
                      : Icons.air_rounded,
                  color: AppTheme.primaryDeep,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    helperText,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
