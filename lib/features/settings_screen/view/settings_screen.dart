import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/global/widgets/custom_app_bar.dart';
import 'package:ninjachiken/features/global/widgets/custom_divider.dart';
import 'package:ninjachiken/features/global/widgets/gradiend_scaffold.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settgins_state.dart';
import 'package:ninjachiken/features/settings_screen/bloc/setting_bloc.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settings_event.dart';
import 'package:ninjachiken/features/settings_screen/widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreenView();
  }
}

class SettingsScreenView extends StatelessWidget {
  const SettingsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            // Показываем ошибку если она есть
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const CustomAppBar(title: 'Settings'),
                const SizedBox(height: 10),
                const CustomDivider(),

                // Показываем индикатор загрузки во время инициализации
                if (state.isLoading && !state.isInitialized)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Initializing music...'),
                        ],
                      ),
                    ),
                  )
                else
                  SettingsCard(
                    title: 'Music',
                    value: state.isMusicEnabled,
                    onChanged:
                        state.isLoading
                            ? null // Отключаем переключатель во время загрузки
                            : (val) {
                              context.read<SettingsBloc>().add(
                                ToggleMusic(val),
                              );
                            },
                  ),

                // // Показываем статус воспроизведения для отладки (можно убрать)
                // if (state.isInitialized)
                //   Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Text(
                //       'Music Status: ${state.isPlaying ? "Playing" : "Stopped"}',
                //       style: const TextStyle(color: Colors.grey),
                //     ),
                //   ),
              ],
            );
          },
        ),
      ),
    );
  }
}
