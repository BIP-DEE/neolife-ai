import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../state/app_session_controller.dart';
import 'app_shell_scope.dart';
import 'brand_mark.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.statusLabel,
  });

  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSessionController>(
      builder: (context, session, _) {
        final shell = AppShellScope.maybeOf(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final hasMeta = (title != null && title!.isNotEmpty) ||
                (eyebrow != null && eyebrow!.isNotEmpty) ||
                (statusLabel != null && statusLabel!.isNotEmpty);

            return Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                compact ? 12 : 22,
                compact ? 10 : 18,
                compact ? 12 : 22,
                compact ? 10 : 18,
              ),
              decoration: BoxDecoration(
                gradient: compact
                    ? LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.99),
                          AppTheme.backgroundAlt,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : AppTheme.panelGradient,
                borderRadius: BorderRadius.circular(compact ? 20 : 30),
                border: Border.all(color: AppTheme.border),
                boxShadow: compact
                    ? [
                        BoxShadow(
                          color: AppTheme.shadow.withValues(alpha: 0.42),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: _BrandCluster()),
                      if (shell != null) ...[
                        _UtilityButton(
                          icon: Icons.settings_outlined,
                          tooltip: 'Settings',
                          compact: compact,
                          onTap: () => shell.goTo(4),
                        ),
                        SizedBox(width: compact ? 8 : 10),
                      ],
                      _AvatarMenu(
                        caregiverName: session.caregiverName,
                        compact: compact,
                        onOpenProfile:
                            shell == null ? null : () => shell.goTo(4),
                        onLogout: context.read<AppSessionController>().signOut,
                      ),
                    ],
                  ),
                  if (hasMeta) ...[
                    SizedBox(height: compact ? 8 : 16),
                    if (compact)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (eyebrow != null && eyebrow!.isNotEmpty)
                                  Text(
                                    eyebrow!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                if (title != null && title!.isNotEmpty) ...[
                                  if (eyebrow != null && eyebrow!.isNotEmpty)
                                    const SizedBox(height: 2),
                                  Text(
                                    title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (statusLabel != null &&
                              statusLabel!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            _HeaderChip(
                              label: statusLabel!,
                              icon: Icons.circle,
                              dense: true,
                            ),
                          ],
                        ],
                      )
                    else ...[
                      Container(
                        width: double.infinity,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.border.withValues(alpha: 0.0),
                              AppTheme.border,
                              AppTheme.border.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (eyebrow != null && eyebrow!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondarySoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                eyebrow!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryDeep,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          if (statusLabel != null && statusLabel!.isNotEmpty)
                            _HeaderChip(
                              label: statusLabel!,
                              icon: Icons.circle,
                            ),
                        ],
                      ),
                    ],
                  ],
                  if (!compact && title != null && title!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      title!,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                    ),
                  ],
                  if (!compact && subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 660,
                      ),
                      child: Text(
                        subtitle!,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.48,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BrandCluster extends StatelessWidget {
  const _BrandCluster();

  @override
  Widget build(BuildContext context) {
    return const BrandMark(compact: true, showTagline: false);
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.icon,
    this.dense = false,
  });

  final String label;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 8 : 10, color: AppTheme.secondary),
          SizedBox(width: dense ? 6 : 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: dense ? 12 : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.surfaceSoft,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            border: Border.all(color: AppTheme.border),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppTheme.primaryDeep,
            size: compact ? 17 : 20,
          ),
        ),
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({
    required this.caregiverName,
    required this.onLogout,
    this.compact = false,
    this.onOpenProfile,
  });

  final String caregiverName;
  final VoidCallback onLogout;
  final bool compact;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_HeaderMenuAction>(
      tooltip: 'Account',
      onSelected: (value) {
        if (value == _HeaderMenuAction.profile) {
          onOpenProfile?.call();
        } else if (value == _HeaderMenuAction.logout) {
          onLogout();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _HeaderMenuAction.profile,
          child: Text('Settings'),
        ),
        const PopupMenuItem(
          value: _HeaderMenuAction.logout,
          child: Text('Log out'),
        ),
      ],
      child: Container(
        height: compact ? 38 : 44,
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.surfaceSoft,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(compact ? 16 : 20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 26 : 28,
              height: compact ? 26 : 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryDeep,
                    AppTheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                caregiverName.characters.first.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                caregiverName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
            ] else
              const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

enum _HeaderMenuAction { profile, logout }
