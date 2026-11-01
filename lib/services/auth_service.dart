import 'package:uuid/uuid.dart';

import '../data/mock/mock_user_data.dart';
import '../models/user_profile.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Authentication boundary. Screens only talk to this interface.
abstract class AuthService {
  Future<UserProfile> login({required String email, required String password});

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  /// Google sign-in is a UI placeholder in the static frontend.
  Future<UserProfile> signInWithGoogle();

  Future<void> logout();
}

/// In-memory, frontend-only authentication used for the demo.
///
/// FUTURE BACKEND INTEGRATION:
/// Replace this mock authentication with the actual authentication API
/// (e.g. REST `/auth/login`, `/auth/register` or Firebase Auth). Store the
/// returned token securely (flutter_secure_storage) – never in plain prefs.
class MockAuthService implements AuthService {
  MockAuthService() {
    _accounts[MockUserData.demoEmail] =
        _MockAccount(MockUserData.demoPassword, MockUserData.demoProfile());
  }

  static const _latency = Duration(milliseconds: 600);
  final Map<String, _MockAccount> _accounts = {};
  final _uuid = const Uuid();

  @override
  Future<UserProfile> login(
      {required String email, required String password}) async {
    await Future.delayed(_latency);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null) {
      throw const AuthException(
          'No account found for this email. Sign up, or use the demo account.');
    }
    if (account.password != password) {
      throw const AuthException('Incorrect password. Please try again.');
    }
    return account.profile;
  }

  @override
  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_latency);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    final profile = UserProfile(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: key,
      phone: phone.trim(),
    );
    _accounts[key] = _MockAccount(password, profile);
    return profile;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    // FUTURE BACKEND INTEGRATION: call the password-reset endpoint. Always
    // show the same message whether or not the email exists.
    await Future.delayed(_latency);
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    // FUTURE BACKEND INTEGRATION: integrate google_sign_in and exchange the
    // Google ID token with the backend.
    throw const AuthException(
        'Google sign-in is not connected yet in this demo build.');
  }

  @override
  Future<void> logout() async {
    // FUTURE BACKEND INTEGRATION: revoke the session token on the server.
  }
}

class _MockAccount {
  _MockAccount(this.password, this.profile);
  final String password;
  final UserProfile profile;
}
