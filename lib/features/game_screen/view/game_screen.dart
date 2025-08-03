import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/game_screen/data/models/egg.dart';
import 'package:ninjachiken/features/game_screen/widgets/custom_alert_dialog.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int lives = 3;
  int score = 0;
  double eggFallSpeed = 0.01;
  double chickenX = 0.5; // от 0.0 до 1.0
  List<Egg> eggs = [];

  late Timer gameLoop;
  late Timer eggSpawner;
  late Timer difficultyTimer;

  final double chickenWidth = 128.0;
  final double eggWidth = 48.0;
  final double chickenBottomOffset = 80.0; // отступ снизу для курицы

  @override
  void initState() {
    super.initState();
    _startGameLoop();
    _startEggSpawner();
    _startDifficultyTimer();
  }

  @override
  void dispose() {
    gameLoop.cancel();
    eggSpawner.cancel();
    difficultyTimer.cancel();
    super.dispose();
  }

  void _startGameLoop() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateEggs();
    });
  }

  void _startEggSpawner() {
    eggSpawner = Timer.periodic(const Duration(seconds: 1), (_) {
      _spawnEgg();
    });
  }

  void _startDifficultyTimer() {
    difficultyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        eggFallSpeed += 0.005;
      });
    });
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomAlertDialog(),
    );
  }

  void _spawnEgg() {
    final newEgg = Egg(
      imagePath: ImageSource.eggDefault,
      x: Random().nextDouble(),
      y: 0,
      isBroken: false,
    );
    setState(() => eggs.add(newEgg));
  }

  void _updateEggs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final chickenLeft = chickenX * screenWidth - chickenWidth / 2;
    final chickenRight = chickenLeft + chickenWidth;
    final chickenTop = screenHeight - chickenBottomOffset - chickenWidth;

    final floorY =
        (screenHeight - eggWidth) /
        screenHeight; // нормализованное положение пола для яйца

    List<Egg> eggsToRemove = [];

    for (var egg in List<Egg>.from(eggs)) {
      if (!egg.isBroken) {
        // Обычное яйцо падает
        egg.y += eggFallSpeed;
      } else {
        // Разбитое яйцо не падает, застывает на месте
        // Но можно, если нужно, немного "опустить" его ниже, например egg.y = floorY,
        // чтобы визуально оно было на земле
        egg.y = floorY;
      }

      final eggTopPx = egg.y * screenHeight;
      final eggLeftPx = egg.x * screenWidth;
      final eggRightPx = eggLeftPx + eggWidth;

      final isOverChicken =
          eggRightPx > chickenLeft && eggLeftPx < chickenRight;
      final isCatchZone =
          eggTopPx + eggWidth >= chickenTop &&
          eggTopPx <= screenHeight - chickenBottomOffset;

      if (isCatchZone && isOverChicken) {
        if (egg.isBroken) {
          // Поймали разбитое яйцо — теряем жизнь
          lives--;
          if (lives <= 0) {
            _gameOver();
            break;
          }
        } else {
          // Поймали обычное яйцо — добавляем очки
          score += 10;
        }
        eggsToRemove.add(egg);
        continue;
      }

      final isOutside = eggTopPx > screenHeight;

      if (isOutside) {
        if (!egg.isBroken) {
          // Обычное яйцо упало мимо — становится разбитым и отнимаем жизнь
          lives--;
          if (lives <= 0) {
            _gameOver();
            break;
          }

          egg.isBroken = true;
          egg.imagePath = 'assets/png/egg_broken.png';

          // Зафиксируем яйцо на полу
          egg.y = floorY;

          // Через 0.5 секунды удаляем разбитое яйцо
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                eggs.remove(egg);
              });
            }
          });

          // Не удаляем сейчас, чтобы разбитое яйцо успело показаться
        } else {
          // Если уже разбитое яйцо вышло за экран — удаляем сразу
          eggsToRemove.add(egg);
        }
      }
    }

    if (eggsToRemove.isNotEmpty) {
      setState(() {
        eggs.removeWhere((egg) => eggsToRemove.contains(egg));
      });
    }
  }

  void _gameOver() {
    gameLoop.cancel();
    eggSpawner.cancel();
    difficultyTimer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false, // нельзя закрыть по тапу вне окна
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрыть диалог
                _restartGame(); // Перезапустить игру
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрыть диалог
                Navigator.pop(context); // Вернуться в главное меню
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      lives = 3;
      score = 0;
      eggs.clear();
      eggFallSpeed = 0.01;
    });

    _startGameLoop();
    _startEggSpawner();
    _startDifficultyTimer();
  }

  Widget _buildChicken() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: chickenBottomOffset,
      left: screenWidth * chickenX - chickenWidth / 2,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            chickenX += details.delta.dx / screenWidth;
            chickenX = chickenX.clamp(0.0, 1.0);
          });
        },
        child: Image.asset(
          ImageSource.chiken,
          width: chickenWidth,
          height: chickenWidth,
        ),
      ),
    );
  }

  Widget _buildEggs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children:
          eggs.map((egg) {
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/png/game_bg.png', fit: BoxFit.cover),

          // UI: AppBar
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showPauseDialog(context),
                    child: Image.asset(ImageSource.pause, height: 60),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.4),
                        child: Image.asset(
                          index < lives
                              ? 'assets/png/active_heart.png'
                              : 'assets/png/broken_heart.png',
                          height: 38,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: SizeHelper.getRelativeWidth(context, 149),
                    height: 62,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      left: SizeHelper.getRelativeWidth(context, 35),
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageSource.scoreBg),
                      ),
                    ),
                    child: Text('$score', style: AppTextStyles.poppins26s600w),
                  ),
                ],
              ),
            ),
          ),

          _buildEggs(),
          _buildChicken(),
        ],
      ),
    );
  }
}
