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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            gradient: AppTheme.panelGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 720;
                  final utilitySection = Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (statusLabel != null)
                          _HeaderChip(
                            label: statusLabel!,
                            icon: Icons.circle,
                          ),
                        if (shell != null)
                          _UtilityButton(
                            icon: Icons.settings_outlined,
                            tooltip: 'Profile & Settings',
                            onTap: () => shell.goTo(4),
                          ),
                        _AvatarMenu(
                          caregiverName: session.caregiverName,
                          onOpenProfile:
                              shell == null ? null : () => shell.goTo(4),
                          onLogout: context.read<AppSessionController>().signOut,
                        ),
                      ],
                    ),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BrandCluster(),
                        const SizedBox(height: 14),
                        utilitySection,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const _BrandCluster(),
                      const Spacer(),
                      utilitySection,
                    ],
                  );
                },
              ),
              if (title != null && title!.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                if (eyebrow != null && eyebrow!.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      eyebrow!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryDeep,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
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
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppTheme.secondary),
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

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.surfaceSoft,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppTheme.primaryDeep,
            size: 20,
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
    this.onOpenProfile,
  });

  final String caregiverName;
  final VoidCallback onLogout;
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
          child: Text('Profile & Settings'),
        ),
        const PopupMenuItem(
          value: _HeaderMenuAction.logout,
          child: Text('Log out'),
        ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.surfaceSoft,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
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
            const SizedBox(width: 8),
            Text(
              caregiverName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 6),
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
