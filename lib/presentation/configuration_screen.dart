import 'package:flutter/material.dart';

class ConfigurationApp extends StatelessWidget {
  const ConfigurationApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Configuration du Carnet',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C4B)),
        ),
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_stories, size: 48),
                    const SizedBox(height: 20),
                    Text(
                      'Connectez votre backend',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Créez un projet Supabase, exécutez le script '
                      'supabase/schema.sql puis relancez l’application avec '
                      'SUPABASE_URL et SUPABASE_ANON_KEY. Les étapes complètes '
                      'sont décrites dans le README.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
