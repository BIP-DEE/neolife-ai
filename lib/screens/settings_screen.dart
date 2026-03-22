import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/placement_mode.dart';
import '../state/app_session_controller.dart';
import '../state/neo_life_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/app_page_layout.dart';
import '../widgets/brand_mark.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onSignOut,
  });

  final VoidCallback onSignOut;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _criticalAlerts = true;
  bool _dailySummary = true;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSessionController, NeoLifeController>(
      builder: (context, session, controller, _) {
        return AppPageLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                eyebrow: 'Account',
                title: 'Settings',
                subtitle:
                    'Manage caregiver details, baby profile context, notifications, trust, and account actions.',
                statusLabel: 'Account',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 960;
                  final profileHero = _ProfileHeroCard(
                    caregiverName: session.caregiverName,
                    infantName: session.infantName,
                    email: session.email,
                    placementLabel: controller.placementMode.label,
                  );
                  final settingsOverview = _SettingsActionsCard(
                    criticalAlerts: _criticalAlerts,
                    quietHours: _quietHours,
                    placementMode: controller.placementMode,
                    onSignOut: widget.onSignOut,
                  );

                  final familyProfilesContent = Column(
                    children: [
                      _InfoRow(
                        title: 'Caregiver name',
                        subtitle: session.caregiverName,
                        icon: Icons.person_outline_rounded,
                      ),
                      const Divider(height: 28),
                      _InfoRow(
                        title: 'Email',
                        subtitle: session.email,
                        icon: Icons.alternate_email_rounded,
                      ),
                      const Divider(height: 28),
                      _InfoRow(
                        title: 'Baby profile',
                        subtitle: session.infantName,
                        icon: Icons.child_friendly_rounded,
                      ),
                    ],
                  );

                  final monitoringPreferencesContent = Column(
                    children: [
                      const _InfoRow(
                        title: 'Placement focus',
                        subtitle:
                            'Current signal interpretation follows the selected wearable placement.',
                        icon: Icons.place_outlined,
                      ),
                      const Divider(height: 28),
                      const _InfoRow(
                        title: 'Live refresh',
                        subtitle:
                            'Signals refresh every second for a calm, near-live overview.',
                        icon: Icons.timer_outlined,
                      ),
                      const Divider(height: 28),
                      _InfoRow(
                        title: 'Temperature signal',
                        subtitle:
                            '${controller.temperatureTitle} is used across wellness views and alerts.',
                        icon: Icons.thermostat_outlined,
                      ),
                    ],
                  );

                  final familySharingContent = Column(
                    children: const [
                      _InfoRow(
                        title: 'Shared access',
                        subtitle:
                            'Invite a second caregiver so both adults can review the same infant status.',
                        icon: Icons.group_outlined,
                      ),
                      Divider(height: 28),
                      _InfoRow(
                        title: 'Support contact',
                        subtitle:
                            'Reach the NeoLife team for onboarding, product help, or account questions.',
                        icon: Icons.support_agent_rounded,
                      ),
                    ],
                  );

                  final notificationsContent = Column(
                    children: [
                      SwitchListTile(
                        value: _criticalAlerts,
                        onChanged: (value) =>
                            setState(() => _criticalAlerts = value),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Critical alerts'),
                        subtitle: const Text(
                          'Surface only the most important changes immediately.',
                        ),
                      ),
                      SwitchListTile(
                        value: _dailySummary,
                        onChanged: (value) =>
                            setState(() => _dailySummary = value),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Daily summary'),
                        subtitle: const Text(
                          'Receive a short wellness recap for the day.',
                        ),
                      ),
                      SwitchListTile(
                        value: _quietHours,
                        onChanged: (value) =>
                            setState(() => _quietHours = value),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('Quiet hours'),
                        subtitle: const Text(
                          'Reduce non-urgent prompts during preferred rest hours.',
                        ),
                      ),
                    ],
                  );

                  final privacyTrustContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandMark(compact: true),
                      const SizedBox(height: 12),
                      Text(
                        'NeoLife AI is designed to make infant wellness easier to understand at a glance, with reassuring presentation, careful alerting, and a privacy-first experience.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      const _InfoRow(
                        title: 'Privacy',
                        subtitle:
                            'Caregiver and infant details stay protected on this device with clear account controls and trust-first design.',
                        icon: Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        title: 'Medical scope',
                        subtitle:
                            'NeoLife AI supports wellness visibility and is not a substitute for urgent medical evaluation.',
                        icon: Icons.health_and_safety_outlined,
                      ),
                    ],
                  );

                  final aboutContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _InfoRow(
                        title: 'Product experience',
                        subtitle:
                            'NeoLife AI brings together live wellness signals, calmer alerts, and clearer caregiver guidance in one connected infant monitoring experience.',
                        icon: Icons.auto_awesome_outlined,
                      ),
                      SizedBox(height: 12),
                      _InfoRow(
                        title: 'Support',
                        subtitle:
                            'Contact the NeoLife team for onboarding, account support, and trust questions.',
                        icon: Icons.mark_email_read_outlined,
                      ),
                    ],
                  );

                  final familyProfiles = _SettingsSectionCard(
                    eyebrow: 'Profiles',
                    title: 'Caregiver and baby',
                    child: familyProfilesContent,
                  );

                  final monitoringPreferences = _SettingsSectionCard(
                    eyebrow: 'Monitoring',
                    title: 'Monitoring preferences',
                    child: monitoringPreferencesContent,
                  );

                  final familySharing = _SettingsSectionCard(
                    eyebrow: 'Family sharing',
                    title: 'Care team visibility',
                    child: familySharingContent,
                  );

                  final notifications = _SettingsSectionCard(
                    eyebrow: 'Notifications',
                    title: 'Caregiver alerts',
                    child: notificationsContent,
                  );

                  final privacyTrust = _SettingsSectionCard(
                    eyebrow: 'Privacy and trust',
                    title: 'How NeoLife AI handles care information',
                    child: privacyTrustContent,
                  );

                  final about = _SettingsSectionCard(
                    eyebrow: 'About NeoLife AI',
                    title: 'Product and support',
                    child: aboutContent,
                  );

                  final leftColumn = Column(
                    children: [
                      familyProfiles,
                      const SizedBox(height: 16),
                      monitoringPreferences,
                      const SizedBox(height: 16),
                      familySharing,
                    ],
                  );
                  final rightColumn = Column(
                    children: [
                      notifications,
                      const SizedBox(height: 16),
                      privacyTrust,
                      const SizedBox(height: 16),
                      about,
                    ],
                  );

                  if (!wide) {
                    final mobileCareContent = Column(
                      children: [
                        notificationsContent,
                        const Divider(height: 28),
                        monitoringPreferencesContent,
                      ],
                    );
                    final mobileSupportContent = Column(
                      children: [
                        familySharingContent,
                        const Divider(height: 28),
                        aboutContent,
                      ],
                    );
                    final mobileSections = Column(
                      children: [
                        _SettingsDisclosureCard(
                          eyebrow: 'Profiles',
                          title: 'Caregiver and baby',
                          summary:
                              'Review caregiver details, email, and the active baby profile.',
                          initiallyExpanded: true,
                          child: familyProfilesContent,
                        ),
                        const SizedBox(height: 12),
                        _SettingsDisclosureCard(
                          eyebrow: 'Care preferences',
                          title: 'Alerts and monitoring',
                          summary:
                              'Control alerts, refresh behavior, and monitoring preferences together.',
                          child: mobileCareContent,
                        ),
                        const SizedBox(height: 12),
                        _SettingsDisclosureCard(
                          eyebrow: 'Support',
                          title: 'Family and support',
                          summary:
                              'Keep shared caregiver access, support, and product help easy to reach.',
                          child: mobileSupportContent,
                        ),
                        const SizedBox(height: 12),
                        _SettingsDisclosureCard(
                          eyebrow: 'Trust',
                          title: 'Privacy and trust',
                          summary:
                              'See privacy, medical scope, and trust information clearly.',
                          child: privacyTrustContent,
                        ),
                      ],
                    );

                    return Column(
                      children: [
                        profileHero,
                        const SizedBox(height: 16),
                        mobileSections,
                        const SizedBox(height: 16),
                        settingsOverview,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: profileHero),
                          const SizedBox(width: 18),
                          Expanded(flex: 5, child: settingsOverview),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: leftColumn),
                          const SizedBox(width: 18),
                          Expanded(child: rightColumn),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.caregiverName,
    required this.infantName,
    required this.email,
    required this.placementLabel,
  });

  final String caregiverName;
  final String infantName;
  final String email;
  final String placementLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.panelPadding(context, phone: 16, regular: 18),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 24, regular: 30),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final avatar = Container(
            width: wide ? 68 : 58,
            height: wide ? 68 : 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryDeep,
                  AppTheme.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: Text(
              caregiverName.characters.first.toUpperCase(),
              style: (wide
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.titleLarge)
                  ?.copyWith(
                color: Colors.white,
              ),
            ),
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caregiverName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProfilePill(
                    label: 'Primary caregiver',
                    icon: Icons.person_outline_rounded,
                  ),
                  _ProfilePill(
                    label: 'Infant profile: $infantName',
                    icon: Icons.child_friendly_rounded,
                  ),
                ],
              ),
            ],
          );
          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AccountHighlight(
                label: 'Baby profile',
                value: infantName,
                icon: Icons.child_friendly_rounded,
              ),
              const SizedBox(height: 10),
              _AccountHighlight(
                label: 'Placement',
                value: placementLabel,
                icon: Icons.place_outlined,
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 12),
                copy,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(flex: 7, child: copy),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: overview),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsActionsCard extends StatelessWidget {
  const _SettingsActionsCard({
    required this.criticalAlerts,
    required this.quietHours,
    required this.placementMode,
    required this.onSignOut,
  });

  final bool criticalAlerts;
  final bool quietHours;
  final PlacementMode placementMode;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            'Settings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account and controls',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the essential account actions and monitoring shortcuts visible here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProfilePill(
                label: criticalAlerts
                    ? 'Critical alerts on'
                    : 'Critical alerts off',
                icon: Icons.notifications_active_outlined,
              ),
              _ProfilePill(
                label: quietHours ? 'Quiet hours active' : 'Quiet hours off',
                icon: Icons.nightlight_outlined,
              ),
              _ProfilePill(
                label: '${placementMode.label} focus',
                icon: Icons.place_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _InfoRow(
            title: 'Account support',
            subtitle:
                'Use this area for sign-out, trust questions, and caregiver support.',
            icon: Icons.support_agent_rounded,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            eyebrow,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SettingsDisclosureCard extends StatelessWidget {
  const _SettingsDisclosureCard({
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(summary, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          children: [
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.secondarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.primaryDeep, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountHighlight extends StatelessWidget {
  const _AccountHighlight({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.secondarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: AppTheme.primaryDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryDeep),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
