import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            AppTheme.surfaceSoft.withValues(alpha: 0.96),
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
          Text('Placement mode', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Choose the wearable position with one tap.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 430;
                final ankle = _PlacementToggleButton(
                  label: 'Ankle',
                  caption: 'Motion + peripheral temp',
                  icon: Icons.directions_walk_rounded,
                  selected: selectedMode == PlacementMode.ankle,
                  onTap: () => onChanged(PlacementMode.ankle),
                );
                final chest = _PlacementToggleButton(
                  label: 'Chest',
                  caption: 'Breathing + core temp',
                  icon: Icons.air_rounded,
                  selected: selectedMode == PlacementMode.chest,
                  onTap: () => onChanged(PlacementMode.chest),
                );

                return vertical
                    ? Column(
                        children: [
                          ankle,
                          const SizedBox(height: 8),
                          chest,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: ankle),
                          const SizedBox(width: 8),
                          Expanded(child: chest),
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(18),
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

class _PlacementToggleButton extends StatelessWidget {
  const _PlacementToggleButton({
    required this.label,
    required this.caption,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppTheme.secondarySoft,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.secondary : AppTheme.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.80)
                    : AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppTheme.primaryDeep, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
