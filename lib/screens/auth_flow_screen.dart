import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../state/app_session_controller.dart';
import '../widgets/ambient_backdrop.dart';
import '../widgets/brand_mark.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final _registerCaregiverController = TextEditingController();
  final _registerInfantController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _signInAcceptedTerms = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _registerCaregiverController.dispose();
    _registerInfantController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSessionController>(
      builder: (context, session, _) {
        final wideBrand = MediaQuery.sizeOf(context).width >= 720;

        return Scaffold(
          body: AmbientBackdrop(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BrandMark(
                      compact: !wideBrand,
                      showTagline: wideBrand,
                    ),
                  ),
                  SizedBox(height: wideBrand ? 18 : 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: switch (session.stage) {
                      AuthStage.welcome => _WelcomeStage(
                          key: const ValueKey('welcome'),
                          onSignIn: session.showSignIn,
                          onRegister: session.showRegister,
                          onReviewMode: session.enterReviewMode,
                          onAbout: () => _showAboutSheet(context),
                          onPrivacy: () => _showLegalSheet(context),
                          onSupport: () => _showSupportSheet(context),
                        ),
                      AuthStage.signIn => _AuthStageScaffold(
                          key: const ValueKey('signin'),
                          imagePath: 'assets/images/baby_crib.jpeg',
                          title: 'Welcome back',
                          subtitle:
                              'Sign in to open your infant wellness dashboard.',
                          form: _AuthFormCard(
                            mode: _AuthMode.signIn,
                            title: 'Sign in',
                            subtitle:
                                'Continue to your latest live status, alerts, and trends.',
                            primaryLabel: 'Open dashboard',
                            secondaryLabel: 'Create account',
                            onSecondaryTap: session.showRegister,
                            onBack: session.showWelcome,
                            emailController: _signInEmailController,
                            passwordController: _signInPasswordController,
                            acceptedTerms: _signInAcceptedTerms,
                            onToggleTerms: (value) {
                              setState(() => _signInAcceptedTerms = value);
                            },
                            onPrimaryTap: () {
                              session.completeAuthentication(
                                email: _signInEmailController.text,
                              );
                            },
                            onShowLegal: _showLegalSheet,
                          ),
                        ),
                      AuthStage.register => _AuthStageScaffold(
                          key: const ValueKey('register'),
                          imagePath: 'assets/images/baby_chest.jpg',
                          title: 'Create your account',
                          subtitle:
                              'Set up your caregiver account and infant profile.',
                          form: _AuthFormCard(
                            mode: _AuthMode.register,
                            title: 'Create account',
                            subtitle:
                                'Add your caregiver and infant details to begin.',
                            primaryLabel: 'Create account',
                            secondaryLabel: 'Already have an account?',
                            onSecondaryTap: session.showSignIn,
                            onBack: session.showWelcome,
                            caregiverController: _registerCaregiverController,
                            infantController: _registerInfantController,
                            emailController: _registerEmailController,
                            passwordController: _registerPasswordController,
                            acceptedTerms: _acceptedTerms,
                            onToggleTerms: (value) {
                              setState(() => _acceptedTerms = value);
                            },
                            onPrimaryTap: () {
                              if (!_acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please accept the Terms & Privacy notice to continue.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              session.completeAuthentication(
                                email: _registerEmailController.text,
                                caregiverName:
                                    _registerCaregiverController.text,
                                infantName: _registerInfantController.text,
                              );
                            },
                            onShowLegal: _showLegalSheet,
                          ),
                        ),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLegalSheet(BuildContext context) {
    return _showInfoSheet(
      context,
      title: 'Privacy & trust',
      intro:
          'NeoLife AI is designed around trust, clear wellness context, and a reassuring family experience.',
      points: const [
        _InfoSheetPoint(
          title: 'Private by design',
          body:
              'Caregiver and infant details stay protected on this device, with clear account controls and thoughtful access management.',
        ),
        _InfoSheetPoint(
          title: 'Wellness guidance',
          body:
              'NeoLife AI supports infant wellness visibility and does not replace urgent medical evaluation or diagnosis.',
        ),
        _InfoSheetPoint(
          title: 'Care support',
          body:
              'The NeoLife team is available for onboarding help, product questions, and privacy guidance.',
        ),
      ],
    );
  }

  Future<void> _showAboutSheet(BuildContext context) {
    return _showInfoSheet(
      context,
      title: 'About NeoLife AI',
      intro:
          'NeoLife AI brings live wellness signals, temperature trend context, and calmer caregiver guidance into one connected infant monitoring experience.',
      points: const [
        _InfoSheetPoint(
          title: 'Built for reassurance',
          body:
              'The product is designed to help caregivers understand what is happening now before moving into deeper trend review.',
        ),
        _InfoSheetPoint(
          title: 'Trend-first monitoring',
          body:
              'NeoLife AI highlights how values are moving over time so caregivers can make better sense of change.',
        ),
      ],
    );
  }

  Future<void> _showSupportSheet(BuildContext context) {
    return _showInfoSheet(
      context,
      title: 'Support',
      intro:
          'Need help getting started or adjusting the wearable? NeoLife support is here to help caregivers stay confident.',
      points: const [
        _InfoSheetPoint(
          title: 'Onboarding help',
          body:
              'Get guidance with setup, placement, fit, and using the dashboard with confidence.',
        ),
        _InfoSheetPoint(
          title: 'Contact',
          body:
              'Reach the NeoLife team at support@neolife.ai for account, trust, and product questions.',
        ),
      ],
    );
  }

  Future<void> _showInfoSheet(
    BuildContext context, {
    required String title,
    required String intro,
    required List<_InfoSheetPoint> points,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  intro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < points.length; i++) ...[
                  _LegalPoint(
                    title: points[i].title,
                    body: points[i].body,
                  ),
                  if (i != points.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeStage extends StatelessWidget {
  const _WelcomeStage({
    super.key,
    required this.onSignIn,
    required this.onRegister,
    required this.onReviewMode,
    required this.onAbout,
    required this.onPrivacy,
    required this.onSupport,
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;
  final VoidCallback onReviewMode;
  final VoidCallback onAbout;
  final VoidCallback onPrivacy;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 980),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final visual = const _HeroVisual(
            imagePath: 'assets/images/baby_crib.jpeg',
            title: 'Calm visibility for infant wellness.',
            subtitle:
                'A reassuring home for live monitoring, trends, and thoughtful caregiver support.',
          );
          final story = _WelcomeCard(
            onSignIn: onSignIn,
            onRegister: onRegister,
            onReviewMode: onReviewMode,
            onAbout: onAbout,
            onPrivacy: onPrivacy,
            onSupport: onSupport,
          );

          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 8, child: visual),
                    const SizedBox(width: 18),
                    Expanded(flex: 5, child: story),
                  ],
                )
              : Column(
                  children: [
                    story,
                    const SizedBox(height: 12),
                    visual,
                  ],
                );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.onSignIn,
    required this.onRegister,
    required this.onReviewMode,
    required this.onAbout,
    required this.onPrivacy,
    required this.onSupport,
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;
  final VoidCallback onReviewMode;
  final VoidCallback onAbout;
  final VoidCallback onPrivacy;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);

    return Container(
      padding: AppTheme.panelPadding(
        context,
        phone: 16,
        regular: 24,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 26, regular: 32),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'NeoLife family care',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryDeep,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          Text(
            'A calmer way to stay close to what matters.',
            style: (compact
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineMedium)
                ?.copyWith(
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Live wellness signals and thoughtful caregiver guidance in one trusted experience.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: compact ? 1.42 : 1.48,
                ),
          ),
          SizedBox(height: compact ? 12 : 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 420;
              final createButton = FilledButton.icon(
                onPressed: onRegister,
                style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(compact ? 48 : 52)),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Create account'),
              );
              final signInButton = OutlinedButton.icon(
                onPressed: onSignIn,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(compact ? 48 : 52),
                ),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Sign in'),
              );

              if (stacked) {
                return Column(
                  children: [
                    createButton,
                    const SizedBox(height: 10),
                    signInButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: createButton),
                  const SizedBox(width: 10),
                  Expanded(child: signInButton),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: onReviewMode,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Enter review mode'),
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WelcomeTag(label: 'Live wellness overview'),
                _WelcomeTag(label: 'Caregiver-ready support'),
              ],
            ),
          ],
          const SizedBox(height: 10),
          if (compact)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _WelcomeMicroFact(
                  icon: Icons.favorite_outline_rounded,
                  label: 'Live now',
                ),
                _WelcomeMicroFact(
                  icon: Icons.notifications_active_outlined,
                  label: 'Trusted alerts',
                ),
              ],
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 520;
                final cards = const [
                  _WelcomeMetric(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Live now',
                    body: 'See the current wellness state first.',
                  ),
                  _WelcomeMetric(
                    icon: Icons.notifications_active_outlined,
                    title: 'Trusted alerts',
                    body: 'Know what changed and what needs review.',
                  ),
                ];

                if (stacked) {
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[1]),
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i != cards.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _WelcomeFooterPill(label: 'About', onTap: onAbout),
              _WelcomeFooterPill(label: 'Privacy', onTap: onPrivacy),
              _WelcomeFooterPill(label: 'Support', onTap: onSupport),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeTag extends StatelessWidget {
  const _WelcomeTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _WelcomeMetric extends StatelessWidget {
  const _WelcomeMetric({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: BoxDecoration(
              color: AppTheme.secondarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon,
                size: compact ? 16 : 18, color: AppTheme.primaryDeep),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WelcomeMicroFact extends StatelessWidget {
  const _WelcomeMicroFact({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
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
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeFooterPill extends StatelessWidget {
  const _WelcomeFooterPill({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _AuthStageScaffold extends StatelessWidget {
  const _AuthStageScaffold({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.form,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 940),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final visual = _HeroVisual(
            imagePath: imagePath,
            title: title,
            subtitle: subtitle,
          );

          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: visual),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: form),
                  ],
                )
              : Column(
                  children: [
                    form,
                    const SizedBox(height: 12),
                    visual,
                  ],
                );
        },
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 24, regular: 32),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      padding: AppTheme.panelPadding(context, phone: 10, regular: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 500;

            return AspectRatio(
              aspectRatio: compact ? 1.9 : 1.08,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imagePath, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryDeep.withValues(alpha: 0.01),
                          AppTheme.primaryDeep.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  if (!compact)
                    const Positioned(
                      top: 16,
                      left: 16,
                      child: _HeroVisualChip(),
                    ),
                  if (!compact)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          'Infant wellness',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: compact ? 176 : 286),
                      padding: EdgeInsets.all(compact ? 8 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: compact ? 0.34 : 0.46),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: (compact
                                    ? Theme.of(context).textTheme.titleMedium
                                    : Theme.of(context).textTheme.titleLarge)
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          if (!compact) ...[
                            const SizedBox(height: 10),
                            const Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _HeroVisualStat(label: 'Private by design'),
                                _HeroVisualStat(label: 'Trend-first view'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroVisualChip extends StatelessWidget {
  const _HeroVisualChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const BrandSymbol(compact: true),
    );
  }
}

class _HeroVisualStat extends StatelessWidget {
  const _HeroVisualStat({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

enum _AuthMode { signIn, register }

class _AuthFormCard extends StatefulWidget {
  const _AuthFormCard({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onSecondaryTap,
    required this.onBack,
    required this.emailController,
    required this.passwordController,
    required this.acceptedTerms,
    required this.onToggleTerms,
    required this.onPrimaryTap,
    required this.onShowLegal,
    this.caregiverController,
    this.infantController,
  });

  final _AuthMode mode;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;
  final VoidCallback onBack;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? caregiverController;
  final TextEditingController? infantController;
  final bool acceptedTerms;
  final ValueChanged<bool>? onToggleTerms;
  final VoidCallback onPrimaryTap;
  final Future<void> Function(BuildContext context) onShowLegal;

  @override
  State<_AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<_AuthFormCard> {
  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_handleInputChanged);
    widget.passwordController.addListener(_handleInputChanged);
    widget.caregiverController?.addListener(_handleInputChanged);
    widget.infantController?.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_handleInputChanged);
    widget.passwordController.removeListener(_handleInputChanged);
    widget.caregiverController?.removeListener(_handleInputChanged);
    widget.infantController?.removeListener(_handleInputChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AuthFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emailController != widget.emailController) {
      oldWidget.emailController.removeListener(_handleInputChanged);
      widget.emailController.addListener(_handleInputChanged);
    }
    if (oldWidget.passwordController != widget.passwordController) {
      oldWidget.passwordController.removeListener(_handleInputChanged);
      widget.passwordController.addListener(_handleInputChanged);
    }
    if (oldWidget.caregiverController != widget.caregiverController) {
      oldWidget.caregiverController?.removeListener(_handleInputChanged);
      widget.caregiverController?.addListener(_handleInputChanged);
    }
    if (oldWidget.infantController != widget.infantController) {
      oldWidget.infantController?.removeListener(_handleInputChanged);
      widget.infantController?.addListener(_handleInputChanged);
    }
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppTheme.isPhone(context);
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text;
    final caregiverName = widget.caregiverController?.text.trim() ?? '';
    final infantName = widget.infantController?.text.trim() ?? '';
    final emailValid = _isValidEmail(email);
    final passwordValid = password.length >= 6;
    final profileValid = widget.mode == _AuthMode.signIn
        ? true
        : caregiverName.isNotEmpty && infantName.isNotEmpty;
    final formValid =
        emailValid && passwordValid && profileValid && widget.acceptedTerms;

    return Container(
      padding: AppTheme.panelPadding(context, phone: 18, regular: 24),
      decoration: BoxDecoration(
        gradient: AppTheme.panelGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.panelRadius(context, phone: 26, regular: 32),
        ),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FormPill(
                label: widget.mode == _AuthMode.signIn
                    ? 'Secure sign in'
                    : 'Family onboarding',
                icon: widget.mode == _AuthMode.signIn
                    ? Icons.lock_outline_rounded
                    : Icons.child_care_outlined,
              ),
              if (!compact)
                const _FormPill(
                  label: 'Support included',
                  icon: Icons.support_agent_rounded,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          if (widget.mode == _AuthMode.register) ...[
            _AuthTextField(
              label: 'Caregiver name',
              hintText: 'Enter caregiver name',
              controller: widget.caregiverController!,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            if (caregiverName.isEmpty)
              const _ValidationText('Enter a caregiver name.'),
            const SizedBox(height: 16),
            _AuthTextField(
              label: 'Infant profile name',
              hintText: 'Enter infant profile name',
              controller: widget.infantController!,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            if (infantName.isEmpty)
              const _ValidationText('Enter an infant profile name.'),
            const SizedBox(height: 16),
          ],
          _AuthTextField(
            label: 'Email',
            hintText: 'name@example.com',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          if (email.isNotEmpty && !emailValid)
            const _ValidationText('Enter a valid email address.'),
          const SizedBox(height: 16),
          _AuthTextField(
            label: 'Password',
            hintText: 'At least 6 characters',
            controller: widget.passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: widget.mode == _AuthMode.signIn
                ? const [AutofillHints.password]
                : const [AutofillHints.newPassword],
            onSubmitted: (_) => _submitIfValid(context, formValid),
          ),
          if (password.isNotEmpty && !passwordValid)
            const _ValidationText('Password must be at least 6 characters.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: widget.acceptedTerms,
                  onChanged: (value) =>
                      widget.onToggleTerms?.call(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            Text(
                              'I agree to the',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            InkWell(
                              onTap: () => widget.onShowLegal(context),
                              child: Text(
                                'Terms & Conditions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (!widget.acceptedTerms &&
                            (email.isNotEmpty ||
                                password.isNotEmpty ||
                                caregiverName.isNotEmpty ||
                                infantName.isNotEmpty))
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: _ValidationText(
                              'Accept the terms to continue.',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: ValueKey('auth-primary-${widget.mode.name}'),
            onPressed:
                formValid ? () => _submitIfValid(context, formValid) : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(widget.primaryLabel),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 440;

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: widget.onSecondaryTap,
                        child: Text(widget.secondaryLabel),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  TextButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onSecondaryTap,
                    child: Text(widget.secondaryLabel),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'NeoLife AI is built to make infant wellness easier to understand, with calmer alerts and clearer next steps for caregivers.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String value) {
    if (value.isEmpty) {
      return false;
    }
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  void _submitIfValid(BuildContext context, bool formValid) {
    if (!formValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onPrimaryTap();
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 18,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enableSuggestions: !obscureText,
          autocorrect: false,
          onSubmitted: onSubmitted,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            filled: true,
            fillColor: AppTheme.surfaceSoft,
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormPill extends StatelessWidget {
  const _FormPill({
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
        color: Colors.white.withValues(alpha: 0.78),
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
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoSheetPoint {
  const _InfoSheetPoint({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _LegalPoint extends StatelessWidget {
  const _LegalPoint({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ValidationText extends StatelessWidget {
  const _ValidationText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.danger,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
