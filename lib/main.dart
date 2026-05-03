import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TemanSoalApp());
}

class TemanSoalApp extends StatelessWidget {
  const TemanSoalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Teman Soal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: scheme.surfaceContainerLow,
          foregroundColor: scheme.onSurface,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
