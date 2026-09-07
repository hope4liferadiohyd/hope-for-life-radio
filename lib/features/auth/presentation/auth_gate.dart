import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isReady) {
          return const SplashScreen();
        }

        if (controller.access == AppAccess.signedOut) {
          return LoginScreen(controller: controller);
        }

        return HomeScreen(
          isGuest: controller.access == AppAccess.guest,
          userEmail: controller.currentUserEmail,
          onSignOut: controller.signOut,
        );
      },
    );
  }
}
