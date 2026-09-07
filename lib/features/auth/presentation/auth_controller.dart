import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';

enum AppAccess { signedOut, guest, authenticated }

class AuthActionResult {
  const AuthActionResult({required this.succeeded, required this.message});

  final bool succeeded;
  final String message;
}

class AuthController extends ChangeNotifier {
  AuthController(this._repository)
      : _access = _repository.hasSession
            ? AppAccess.authenticated
            : AppAccess.signedOut;

  final AuthRepository _repository;
  StreamSubscription<bool>? _authSubscription;
  AppAccess _access;
  bool _isReady = false;
  bool _isBusy = false;
  bool _disposed = false;

  AppAccess get access => _access;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  bool get emailAuthAvailable => _repository.isConfigured;
  String? get currentUserEmail => _repository.currentUserEmail;

  Future<void> initialize({
    Duration minimumSplashDuration = const Duration(milliseconds: 900),
  }) async {
    _authSubscription = _repository.signedInChanges.listen((signedIn) {
      _access = signedIn ? AppAccess.authenticated : AppAccess.signedOut;
      _safeNotifyListeners();
    });

    if (minimumSplashDuration > Duration.zero) {
      await Future<void>.delayed(minimumSplashDuration);
    }
    _isReady = true;
    _safeNotifyListeners();
  }

  void continueAsGuest() {
    _access = AppAccess.guest;
    _safeNotifyListeners();
  }

  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  }) async {
    return _run(() async {
      await _repository.signIn(
        email: email.trim().toLowerCase(),
        password: password,
      );
      _access = AppAccess.authenticated;
      return const AuthActionResult(
        succeeded: true,
        message: 'Welcome back.',
      );
    });
  }

  Future<AuthActionResult> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final result = await _repository.signUp(
        displayName: displayName.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (result.hasSession) {
        _access = AppAccess.authenticated;
        return const AuthActionResult(
          succeeded: true,
          message: 'Your account is ready.',
        );
      }

      return const AuthActionResult(
        succeeded: true,
        message: 'Account created. Check your email before signing in.',
      );
    });
  }

  Future<AuthActionResult> sendPasswordReset(String email) async {
    return _run(() async {
      await _repository.sendPasswordReset(email.trim().toLowerCase());
      return const AuthActionResult(
        succeeded: true,
        message: 'Password reset instructions were sent to your email.',
      );
    });
  }

  Future<AuthActionResult> signOut() async {
    return _run(() async {
      if (_access == AppAccess.authenticated) {
        await _repository.signOut();
      }
      _access = AppAccess.signedOut;
      return const AuthActionResult(
        succeeded: true,
        message: 'You have been signed out.',
      );
    });
  }

  Future<AuthActionResult> _run(
    Future<AuthActionResult> Function() action,
  ) async {
    if (_isBusy) {
      return const AuthActionResult(
        succeeded: false,
        message: 'Please wait for the current action to finish.',
      );
    }

    _isBusy = true;
    _safeNotifyListeners();
    try {
      return await action();
    } on AuthFailure catch (error) {
      return AuthActionResult(succeeded: false, message: error.message);
    } catch (_) {
      return const AuthActionResult(
        succeeded: false,
        message: 'Something went wrong. Check your internet and try again.',
      );
    } finally {
      _isBusy = false;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final subscription = _authSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
