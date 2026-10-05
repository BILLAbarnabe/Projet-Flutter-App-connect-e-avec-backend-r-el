import 'package:flutter/material.dart';

import '../domain/repositories/auth_repository.dart';

class CarnetConnecteApp extends StatelessWidget {
  const CarnetConnecteApp({
    required this.authRepository,
    required this.homeBuilder,
    required this.loginBuilder,
    super.key,
  });

  final AuthRepository authRepository;
  final Widget Function() homeBuilder;
  final Widget Function() loginBuilder;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Carnet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF315C4B),
            surface: const Color(0xFFF7F6F1),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F6F1),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F6F1),
            surfaceTintColor: Colors.transparent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: StreamBuilder(
          stream: authRepository.authStateChanges,
          builder: (context, snapshot) {
            if (authRepository.currentUser != null ||
                snapshot.data?.session != null) {
              return homeBuilder();
            }
            return loginBuilder();
          },
        ),
      );
}
