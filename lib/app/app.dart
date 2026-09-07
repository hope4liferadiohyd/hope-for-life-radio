import 'dart:async';

import 'package:flutter/material.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_gate.dart';
import 'app_theme.dart';

class HopeForLifeApp extends StatefulWidget {
  const HopeForLifeApp({
    required this.authRepository,
    this.splashDuration = const Duration(milliseconds: 900),
    super.key,
  });

  final AuthRepository authRepository;
  final Duration splashDuration;

  @override
  State<HopeForLifeApp> createState() => _HopeForLifeAppState();
}

class _HopeForLifeAppState extends State<HopeForLifeApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(widget.authRepository);
    unawaited(
      _authController.initialize(
        minimumSplashDuration: widget.splashDuration,
      ),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hope For Life Radio',
      theme: buildAppTheme(),
      home: AuthGate(controller: _authController),
    );
  }
}
