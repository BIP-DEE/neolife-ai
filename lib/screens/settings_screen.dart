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
                eyebrow: 'Profile',
                title: 'Family, preferences, and trust',
                subtitle:
                    'Keep caregiver details, baby profile context, notifications, and privacy settings together in one clear product space.',
                statusLabel: 'Account',
              ),
              const SizedBox(height: 18),
              _ProfileHeroCard(
                caregiverName: session.caregiverName,
                infantName: session.infantName,
                email: session.email,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final leftColumn = Column(
                    children: [
                      _SettingsSectionCard(
                        eyebrow: 'Caregiver profile',
                        title: 'Primary caregiver',
                        child: Column(
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSectionCard(
                        eyebrow: 'Infant profile',
                        title: 'Baby profile',
                        child: Column(
                          children: [
                            _InfoRow(
                              title: 'Profile name',
                              subtitle: session.infantName,
                              icon: Icons.child_friendly_rounded,
                            ),
                            const Divider(height: 28),
                            _InfoRow(
                              title: 'Current placement',
                              subtitle: controller.placementMode.label,
                              icon: Icons.place_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSectionCard(
                        eyebrow: 'Monitoring preferences',
                        title: 'Monitoring preferences',
                        child: Column(
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSectionCard(
                        eyebrow: 'Family sharing',
                        title: 'Care team visibility',
                        child: Column(
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
                        ),
                      ),
                    ],
                  );
                  final rightColumn = Column(
                    children: [
                      _SettingsSectionCard(
                        eyebrow: 'Notifications',
                        title: 'Caregiver alerts',
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _criticalAlerts,
                              onChanged: (value) =>
                                  setState(() => _criticalAlerts = value),
                              title: const Text('Critical alerts'),
                              subtitle: const Text(
                                'Surface only the most important changes immediately.',
                              ),
                            ),
                            SwitchListTile(
                              value: _dailySummary,
                              onChanged: (value) =>
                                  setState(() => _dailySummary = value),
                              title: const Text('Daily summary'),
                              subtitle: const Text(
                                'Receive a short wellness recap for the day.',
                              ),
                            ),
                            SwitchListTile(
                              value: _quietHours,
                              onChanged: (value) =>
                                  setState(() => _quietHours = value),
                              title: const Text('Quiet hours'),
                              subtitle: const Text(
                                'Reduce non-urgent prompts during preferred rest hours.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSectionCard(
                        eyebrow: 'Privacy and trust',
                        title: 'How NeoLife AI handles care information',
                        child: Column(
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
                                  'Caregiver and infant details stay on this device in the current product preview.',
                              icon: Icons.verified_user_outlined,
                            ),
                            const SizedBox(height: 12),
                            const _InfoRow(
                              title: 'Medical scope',
                              subtitle:
                                  'NeoLife AI supports wellness visibility and is not a substitute for urgent medical evaluation.',
                              icon: Icons.health_and_safety_outlined,
                            ),
                            const SizedBox(height: 12),
                            const _InfoRow(
                              title: 'Support',
                              subtitle:
                                  'Contact the NeoLife team for help with onboarding, account support, and trust questions.',
                              icon: Icons.mark_email_read_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSectionCard(
                        eyebrow: 'About NeoLife AI',
                        title: 'Product overview',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NeoLife AI brings together live wellness signals, calmer alerts, and clearer caregiver guidance in one connected infant monitoring experience.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: widget.onSignOut,
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Sign out'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        leftColumn,
                        const SizedBox(height: 16),
                        rightColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: leftColumn),
                      const SizedBox(width: 18),
                      Expanded(flex: 5, child: rightColumn),
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
  });

  final String caregiverName;
  final String infantName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final avatar = Container(
            width: 68,
            height: 68,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 16),
                copy,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(child: copy),
            ],
          );
        },
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.secondarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.primaryDeep, size: 18),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryDeep),
          const SizedBox(width: 8),
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
