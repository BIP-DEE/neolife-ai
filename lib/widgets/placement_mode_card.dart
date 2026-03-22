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
    this.title = 'Placement mode',
    this.subtitle,
    this.footerLabel,
    this.actionLabel,
    this.onActionTap,
    this.compact = false,
  });

  final PlacementMode selectedMode;
  final String helperText;
  final ValueChanged<PlacementMode> onChanged;
  final String title;
  final String? subtitle;
  final String? footerLabel;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = compact || AppTheme.isPhone(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(phone ? 12 : 16),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(phone ? 22 : 28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 340;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: phone ? 15 : null,
                        ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: phone ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              );

              if (actionLabel == null || onActionTap == null) {
                return titleBlock;
              }

              final action = TextButton(
                onPressed: onActionTap,
                child: Text(actionLabel!),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: 6),
                    action,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 10),
                  action,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          PlacementModeSelector(
            selectedMode: selectedMode,
            onChanged: onChanged,
            compact: phone,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: phone ? 10 : 12,
              vertical: phone ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(phone ? 16 : 18),
              border: Border.all(color: AppTheme.border),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 320;
                final helper = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedMode == PlacementMode.ankle
                          ? Icons.directions_walk_rounded
                          : Icons.air_rounded,
                      color: AppTheme.primaryDeep,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        helperText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                );

                final footer = footerLabel == null || footerLabel!.isEmpty
                    ? null
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          footerLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      );

                if (stacked || footer == null) {
                  return Row(
                    children: [
                      Expanded(child: helper),
                      if (footer != null) ...[
                        const SizedBox(width: 8),
                        Flexible(child: footer),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: helper),
                    const SizedBox(width: 10),
                    footer,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
