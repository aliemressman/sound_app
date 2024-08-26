import 'package:flutter/material.dart';
import 'package:sound_app/Ui/premium/premium_view_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(), // Koyu temayı kullan
        home: const PremiumViewLauncher());
  }
}
