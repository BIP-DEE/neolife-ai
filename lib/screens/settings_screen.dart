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
                title: 'Profile and settings',
                subtitle:
                    'Keep caregiver preferences, product trust cues, and prototype details in one calm place.',
                statusLabel: 'Prototype',
              ),
              const SizedBox(height: 18),
              _ProfileCard(
                caregiverName: session.caregiverName,
                infantName: session.infantName,
                email: session.email,
              ),
              const SizedBox(height: 18),
              _SettingsCard(
                title: 'Notifications',
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _criticalAlerts,
                      onChanged: (value) =>
                          setState(() => _criticalAlerts = value),
                      title: const Text('Critical alerts'),
                      subtitle: const Text(
                          'Keep sustained anomaly notifications visible.'),
                    ),
                    SwitchListTile(
                      value: _dailySummary,
                      onChanged: (value) =>
                          setState(() => _dailySummary = value),
                      title: const Text('Daily summary'),
                      subtitle: const Text(
                          'Show a daily recap card in the profile feed.'),
                    ),
                    SwitchListTile(
                      value: _quietHours,
                      onChanged: (value) => setState(() => _quietHours = value),
                      title: const Text('Quiet hours'),
                      subtitle: const Text(
                          'Silence non-critical prompts during rest windows.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Monitoring setup',
                child: Column(
                  children: [
                    _InfoRow(
                      title: 'Current placement',
                      subtitle: controller.placementMode.label,
                      icon: Icons.place_outlined,
                    ),
                    const Divider(height: 28),
                    const _InfoRow(
                      title: 'Data source',
                      subtitle: 'Mock stream running locally on device',
                      icon: Icons.lock_outline_rounded,
                    ),
                    const Divider(height: 28),
                    const _InfoRow(
                      title: 'BLE readiness',
                      subtitle:
                          'Service layer prepared for future sensor replacement',
                      icon: Icons.memory_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'About NeoLife AI',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 12),
                    Text(
                      'NeoLife AI is presented here as a premium infant wellness concept: softer UI, clearer status language, and a structure ready for real wearable connectivity later.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: widget.onSignOut,
                      child: const Text('Sign out to welcome flow'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryDeep,
                  AppTheme.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              caregiverName.characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caregiverName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Primary infant profile: $infantName',
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.secondarySoft,
            borderRadius: BorderRadius.circular(12),
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
