import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';

class PlacementModeSelector extends StatelessWidget {
  const PlacementModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
    this.compact = false,
  });

  final PlacementMode selectedMode;
  final ValueChanged<PlacementMode> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 4 : 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlacementModeOption(
              label: 'Ankle',
              icon: Icons.directions_walk_rounded,
              selected: selectedMode == PlacementMode.ankle,
              compact: compact,
              onTap: () => onChanged(PlacementMode.ankle),
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: _PlacementModeOption(
              label: 'Chest',
              icon: Icons.air_rounded,
              selected: selectedMode == PlacementMode.chest,
              compact: compact,
              onTap: () => onChanged(PlacementMode.chest),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementModeOption extends StatelessWidget {
  const _PlacementModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 16 : 18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 9 : 12,
        ),
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
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          border: Border.all(
            color: selected ? AppTheme.secondary : AppTheme.border,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: compact ? 16 : 18, color: AppTheme.primaryDeep),
              SizedBox(width: compact ? 5 : 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
