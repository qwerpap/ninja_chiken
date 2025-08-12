import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/settings_screen/bloc/setting_bloc.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settings_event.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';
import 'package:ninjachiken/theme/theme.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = SettingsBloc();
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc..add(InitializeMusic()),
      child: MaterialApp(theme: theme, home: const MenuScreen()),
    );
  }
}
