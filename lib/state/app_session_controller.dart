import 'package:flutter/foundation.dart';

enum AuthStage { welcome, signIn, register }

class AppSessionController extends ChangeNotifier {
  AuthStage _stage = AuthStage.welcome;
  bool _isAuthenticated = false;
  bool _isReviewMode = false;
  String _caregiverName = 'Caregiver';
  String _infantName = 'Baby Neo';
  String _email = 'hello@neolife.ai';

  AuthStage get stage => _stage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isReviewMode => _isReviewMode;
  String get caregiverName => _caregiverName;
  String get infantName => _infantName;
  String get email => _email;

  void showWelcome() {
    _stage = AuthStage.welcome;
    notifyListeners();
  }

  void showSignIn() {
    _stage = AuthStage.signIn;
    notifyListeners();
  }

  void showRegister() {
    _stage = AuthStage.register;
    notifyListeners();
  }

  void completeAuthentication({
    required String email,
    String? caregiverName,
    String? infantName,
  }) {
    _isAuthenticated = true;
    _isReviewMode = false;
    _email = email.trim().isEmpty ? _email : email.trim();
    _caregiverName = _normalizeName(
      caregiverName,
      fallback: _deriveNameFromEmail(_email),
    );
    _infantName = _normalizeName(infantName, fallback: _infantName);
    notifyListeners();
  }

  void enterReviewMode({
    String caregiverName = 'Review Caregiver',
    String infantName = 'Baby Neo',
    String email = 'review@neolife.ai',
  }) {
    _stage = AuthStage.welcome;
    _isAuthenticated = true;
    _isReviewMode = true;
    _caregiverName = caregiverName;
    _infantName = infantName;
    _email = email;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _isReviewMode = false;
    _stage = AuthStage.welcome;
    notifyListeners();
  }

  String _normalizeName(String? value, {required String fallback}) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _deriveNameFromEmail(String email) {
    final prefix = email.split('@').first.trim();
    if (prefix.isEmpty) {
      return 'Caregiver';
    }

    final normalized = prefix.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
    if (normalized.isEmpty) {
      return 'Caregiver';
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
