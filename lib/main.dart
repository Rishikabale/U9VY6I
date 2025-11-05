// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(' Firebase initialization failed: $e');
  }

  // Wrap the app in a ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      title: 'Assignment App',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[50],
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.green[800],
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      home: const HomePage(), // This remains the same
    );
  }
}