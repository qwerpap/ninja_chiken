  import 'package:flutter/material.dart';
  import 'package:ninjachiken/features/global/services/music_service.dart';
  import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';
  import 'package:ninjachiken/theme/theme.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MusicService().init(); // запускаем музыку

    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MenuScreen(),
      );
    }
  }
