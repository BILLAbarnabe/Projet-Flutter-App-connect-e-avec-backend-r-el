import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/backend_config.dart';
import 'data/auth/supabase_auth_repository.dart';
import 'data/local/sqlite_content_cache.dart';
import 'data/remote/auth_token_interceptor.dart';
import 'data/remote/supabase_content_api.dart';
import 'data/repositories/content_repository_impl.dart';
import 'presentation/app.dart';
import 'presentation/configuration_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!BackendConfig.isConfigured) {
    runApp(const ConfigurationApp());
    return;
  }

  await Supabase.initialize(
    url: BackendConfig.supabaseUrl,
    publishableKey: BackendConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;
  final dio = createContentDio(
    client,
    baseUrl: BackendConfig.supabaseUrl,
    apiKey: BackendConfig.supabaseAnonKey,
  );
  final authRepository = SupabaseAuthRepository(client);
  final contentRepository = ContentRepositoryImpl(
    remote: SupabaseContentApi(dio),
    cache: SqliteContentCache(),
  );

  runApp(
    CarnetConnecteApp(
      authRepository: authRepository,
      homeBuilder: () => HomeScreen(
        authRepository: authRepository,
        contentRepository: contentRepository,
      ),
      loginBuilder: () => LoginScreen(authRepository: authRepository),
    ),
  );
}
