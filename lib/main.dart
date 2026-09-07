import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'config/app_config.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/supabase_auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepository = await _createAuthRepository();
  runApp(HopeForLifeApp(authRepository: authRepository));
}

Future<AuthRepository> _createAuthRepository() async {
  if (!AppConfig.hasSupabaseConfiguration) {
    return const UnconfiguredAuthRepository();
  }

  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
    return SupabaseAuthRepository(Supabase.instance.client);
  } catch (_) {
    // A configuration problem must not prevent listeners from using guest mode.
    return const UnconfiguredAuthRepository();
  }
}
