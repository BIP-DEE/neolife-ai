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
  final _signInEmailController =
      TextEditingController(text: 'hello@neolife.ai');
  final _signInPasswordController = TextEditingController(text: 'neolife-demo');
  final _registerCaregiverController = TextEditingController(text: 'Chanda');
  final _registerInfantController = TextEditingController(text: 'Baby Neo');
  final _registerEmailController =
      TextEditingController(text: 'hello@neolife.ai');
  final _registerPasswordController =
      TextEditingController(text: 'neolife-demo');

  bool _signInAcceptedTerms = true;
  bool _acceptedTerms = true;

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
        return Scaffold(
          body: AmbientBackdrop(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const BrandMark(showTagline: false),
                  const SizedBox(height: 24),
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
                        ),
                      AuthStage.signIn => _AuthStageScaffold(
                          key: const ValueKey('signin'),
                          imagePath: 'assets/images/baby_crib.jpeg',
                          title: 'Welcome back',
                          subtitle:
                              'Sign in to open your live monitoring demo.',
                          form: _AuthFormCard(
                            mode: _AuthMode.signIn,
                            title: 'Sign in',
                            subtitle:
                                'Use any valid demo credentials to continue.',
                            primaryLabel: 'Enter dashboard',
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
                          title: 'Create an account',
                          subtitle:
                              'Create a local caregiver profile for the demo.',
                          form: _AuthFormCard(
                            mode: _AuthMode.register,
                            title: 'Create account',
                            subtitle:
                                'Add caregiver and infant details to begin.',
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
                  'Terms & Privacy',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This prototype stores data locally only. No personal or infant data is transmitted to a backend in this demo build.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                const _LegalPoint(
                  title: 'Demo-only access',
                  body:
                      'Authentication is simulated for presentation and does not create a real cloud account.',
                ),
                const SizedBox(height: 12),
                const _LegalPoint(
                  title: 'Wellness guidance',
                  body:
                      'The mock alerts and charts are illustrative only and not a medical diagnosis.',
                ),
                const SizedBox(height: 12),
                const _LegalPoint(
                  title: 'Future sensor path',
                  body:
                      'The architecture is ready to swap the mock stream with BLE integration in a later phase.',
                ),
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
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 980),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final visual = const _HeroVisual(
            imagePath: 'assets/images/baby_crib.jpeg',
            title: 'Quiet, trustworthy monitoring.',
            subtitle: 'A softer demo experience for infant wellness.',
          );
          final story = _WelcomeCard(
            onSignIn: onSignIn,
            onRegister: onRegister,
          );

          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: visual),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: story),
                  ],
                )
              : Column(
                  children: [
                    visual,
                    const SizedBox(height: 16),
                    story,
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
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
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
              'Local caregiver demo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryDeep,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Infant wellness, clearly presented.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'NeoLife AI keeps live signals calm, readable, and demo-ready.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRegister,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Create caregiver account'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSignIn,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign in to the demo'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _WelcomeTag(label: 'No backend required'),
              _WelcomeTag(label: 'Mock live feed'),
              _WelcomeTag(label: 'BLE-ready architecture'),
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
                    visual,
                    const SizedBox(height: 16),
                    form,
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
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryDeep.withValues(alpha: 0.08),
                      AppTheme.primaryDeep.withValues(alpha: 0.76),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const Positioned(
                top: 18,
                left: 18,
                child: _HeroVisualChip(),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _HeroVisualStat(label: '1 sec updates'),
                          _HeroVisualStat(label: 'Local demo'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
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
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
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
