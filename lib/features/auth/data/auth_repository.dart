class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SignUpResult {
  const SignUpResult({required this.hasSession});

  final bool hasSession;
}

abstract class AuthRepository {
  bool get isConfigured;

  bool get hasSession;

  String? get currentUserEmail;

  Stream<bool> get signedInChanges;

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _message =
      'Email accounts are not connected yet. Continue as a guest, or add the '
      'Supabase settings described in STEP_1_SETUP.md.';

  @override
  bool get isConfigured => false;

  @override
  bool get hasSession => false;

  @override
  String? get currentUserEmail => null;

  @override
  Stream<bool> get signedInChanges => const Stream<bool>.empty();

  @override
  Future<void> sendPasswordReset(String email) =>
      Future<void>.error(const AuthFailure(_message));

  @override
  Future<void> signIn({required String email, required String password}) =>
      Future<void>.error(const AuthFailure(_message));

  @override
  Future<void> signOut() async {}

  @override
  Future<SignUpResult> signUp({
    required String displayName,
    required String email,
    required String password,
  }) => Future<SignUpResult>.error(const AuthFailure(_message));
}
