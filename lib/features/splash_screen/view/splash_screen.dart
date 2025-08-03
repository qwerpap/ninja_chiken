import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Запускаем таймер на 2 секунды, потом переходим на MenuScreen
    Timer(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MenuScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
