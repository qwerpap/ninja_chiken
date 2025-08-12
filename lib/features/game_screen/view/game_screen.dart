import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/game_screen/bloc/game_bloc.dart';
import 'package:ninjachiken/features/game_screen/bloc/game_event.dart';
import 'package:ninjachiken/features/game_screen/bloc/game_state.dart';
import 'package:ninjachiken/features/game_screen/widgets/widgets.dart';
import 'package:ninjachiken/features/menu_screen/view/menu_screen.dart';
import 'package:ninjachiken/theme/app_colors.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame()),
      child: const GameScreenView(),
    );
  }
}

class GameScreenView extends StatefulWidget {
  const GameScreenView({super.key});

  @override
  State<GameScreenView> createState() => _GameScreenViewState();
}

class _GameScreenViewState extends State<GameScreenView> {
  final double chickenWidth = 128.0;
  final double eggWidth = 64.0;
  final double chickenBottomOffset = 80.0;
  bool _isGameOverDialogShown = false;

  void _showPauseDialog(BuildContext context) {
    context.read<GameBloc>().add(PauseGame());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => PauseAlert(
            score: context.read<GameBloc>().state.score,
            onResume: () {
              print(
                'Current pause state: ${context.read<GameBloc>().state.isPaused}',
              );
              Navigator.pop(dialogContext);
              context.read<GameBloc>().add(ResumeGame());
            },
            onBackToMenu: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
                (route) => false,
              );
            },
          ),
    );
  }

  Future<bool?> _showGameOverDialog(BuildContext context, int score) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blurAlertBg,
      builder:
          (dialogContext) => GameOverAlert(
            score: score,
            onRestart: () {
              Navigator.of(
                dialogContext,
              ).pop(true); // Возвращаем true при рестарте
            },
            onBackToMenu: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
                (route) => false,
              );
            },
          ),
    );
  }

  Widget _buildChicken(GameState state) {
    if (state.isGameOver) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: chickenBottomOffset,
      left: screenWidth * state.chickenX - chickenWidth / 2,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          context.read<GameBloc>().add(
            MoveChicken(0.01),
          ); // минимальное движение для запуска анимации
        },

        onHorizontalDragUpdate: (details) {
          final dx = details.delta.dx / screenWidth;
          context.read<GameBloc>().add(MoveChicken(dx));
        },

        onHorizontalDragEnd: (_) {
          context.read<GameBloc>().add(StopMoving());
        },

        onTapDown: (details) {
          final tapX = details.localPosition.dx;
          final centerX = chickenWidth / 2;
          final direction = tapX > centerX ? 0.02 : -0.02;
          context.read<GameBloc>().add(MoveChicken(direction));
        },

        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()..rotateY(state.lastDx >= 0 ? 0 : pi),
              child: AnimatedChicken(
                isMoving: state.isMoving,
                isPicking: state.isPicking,
                width: chickenWidth,
                height: chickenWidth,
              ),
            ),
            if (state.showInvulnerableIndicator)
              Container(
                width: chickenWidth + 20,
                height: chickenWidth + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellowAccent.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEggs(GameState state) {
    if (state.isGameOver) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children:
          state.eggs.map((egg) {
            return Positioned(
              top: screenHeight * egg.y,
              left: screenWidth * egg.x,
              child: Image.asset(
                egg.imagePath,
                width: eggWidth,
                height: eggWidth,
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.isGameOver && !_isGameOverDialogShown) {
          _isGameOverDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final restart = await _showGameOverDialog(context, state.score);
            _isGameOverDialogShown = false;

            if (restart == true) {
              context.read<GameBloc>().add(RestartGame());
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Фон
              Image.asset('assets/png/game_bg.png', fit: BoxFit.cover),

              // Верхняя панель с элементами управления
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PauseButton(onTap: () => _showPauseDialog(context)),
                      RowLives(lives: state.lives),
                      ScoreContainer(score: state.score),
                    ],
                  ),
                ),
              ),

              // Яйца
              _buildEggs(state),

              // Курица
              _buildChicken(state),

              // Индикатор замедления
              if (state.showSlowDownIndicator)
                Positioned(
                  top: 120,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Slow down!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
