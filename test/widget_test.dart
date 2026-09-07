import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hope_for_life_radio/app/app.dart';
import 'package:hope_for_life_radio/features/auth/data/auth_repository.dart';
import 'package:hope_for_life_radio/features/auth/presentation/auth_controller.dart';

void main() {
  group('authentication foundation', () {
    testWidgets('shows the login screen after splash initialization', (tester) async {
      final repository = FakeAuthRepository();

      await tester.pumpWidget(
        HopeForLifeApp(
          authRepository: repository,
          splashDuration: Duration.zero,
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('loginScreen')), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);

      await repository.close();
    });

    test('guest access and sign out return to the correct states', () async {
      final repository = FakeAuthRepository();
      final controller = AuthController(repository);

      await controller.initialize(minimumSplashDuration: Duration.zero);
      expect(controller.access, AppAccess.signedOut);

      controller.continueAsGuest();
      expect(controller.access, AppAccess.guest);

      final result = await controller.signOut();
      expect(result.succeeded, isTrue);
      expect(controller.access, AppAccess.signedOut);

      controller.dispose();
      await repository.close();
    });

    test('successful email sign in grants authenticated access', () async {
      final repository = FakeAuthRepository();
      final controller = AuthController(repository);
      await controller.initialize(minimumSplashDuration: Duration.zero);

      final result = await controller.signIn(
        email: 'listener@example.com',
        password: 'correct-password',
      );

      expect(result.succeeded, isTrue);
      expect(controller.access, AppAccess.authenticated);
      expect(controller.currentUserEmail, 'listener@example.com');

      controller.dispose();
      await repository.close();
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  final StreamController<bool> _authChanges = StreamController<bool>.broadcast();
  bool _hasSession = false;
  String? _email;

  @override
  bool get isConfigured => true;

  @override
  bool get hasSession => _hasSession;

  @override
  String? get currentUserEmail => _email;

  @override
  Stream<bool> get signedInChanges => _authChanges.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _hasSession = true;
    _email = email;
    _authChanges.add(true);
  }

  @override
  Future<SignUpResult> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    return const SignUpResult(hasSession: false);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _hasSession = false;
    _email = null;
    _authChanges.add(false);
  }

  Future<void> close() => _authChanges.close();
}
