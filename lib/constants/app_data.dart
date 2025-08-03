import 'package:ninjachiken/features/game_screen/view/game_screen.dart';
import 'package:ninjachiken/features/menu_screen/data/models/menu_model.dart';
import 'package:ninjachiken/features/records_screen/view/records_screen.dart';
import 'package:ninjachiken/features/settings_screen/view/settings_screen.dart';

class AppData {
  static final List<MenuModel> menuList = [
    MenuModel(title: 'Start', screenBuilder: (context) => const GameScreen()),
    MenuModel(
      title: 'Records',
      screenBuilder: (context) => const RecordsScreen(),
    ),
    MenuModel(
      title: 'Settings',
      screenBuilder: (context) => const SettingsScreen(),
    ),
  ];
}
