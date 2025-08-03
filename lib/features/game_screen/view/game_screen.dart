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

  bool isInvulnerable = false; // в состоянии игры

  final double chickenWidth = 128.0;
  final double eggWidth = 48.0;
  final double chickenBottomOffset = 80.0; // отступ снизу для курицы

  Duration currentSpawnInterval = const Duration(milliseconds: 800);
  final Duration minSpawnInterval = const Duration(milliseconds: 300);

  final int maxEggsOnScreen = 20;
  double? lastEggX; // чтобы не было повторной позиции
  final int eggSpawnColumns = 8; // сколько "дорожек" для яиц

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
    eggSpawner = Timer(currentSpawnInterval, () {
      _spawnEgg();
      _startEggSpawner(); // запускаем снова
    });
  }

  void _startDifficultyTimer() {
    difficultyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        // ускоряем падение
        eggFallSpeed += 0.0025;

        // увеличиваем частоту спавна
        final nextMs = currentSpawnInterval.inMilliseconds - 100;
        if (nextMs > minSpawnInterval.inMilliseconds) {
          currentSpawnInterval = Duration(milliseconds: nextMs);
          // перезапускаем спавнер с новым интервалом
          eggSpawner.cancel();
          _startEggSpawner();
        }
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
    if (eggs.length >= maxEggsOnScreen) return;

    final r = Random().nextDouble();
    EggType type;
    String imagePath;

    if (r < 0.7) {
      type = EggType.normal;
      imagePath = ImageSource.eggDefault;
    } else if (r < 0.85) {
      type = EggType.silver;
      imagePath = ImageSource.eggSliver;
    } else if (r < 0.95) {
      type = EggType.gold;
      imagePath = ImageSource.eggGold;
    } else {
      type = EggType.cracked;
      imagePath = ImageSource.eggBroken;
    }

    // Расчёт допустимого диапазона колонок, чтобы не спавнилось на краях
    final screenWidth = MediaQuery.of(context).size.width;
    final columnsToAvoid = (eggWidth / screenWidth * eggSpawnColumns).ceil();

    final minColumn = columnsToAvoid;
    final maxColumn = eggSpawnColumns - columnsToAvoid - 1;

    if (minColumn > maxColumn) {
      // Если яйцо слишком большое для сетки — просто не спавним
      return;
    }

    double newX;
    do {
      final column = Random().nextInt(maxColumn - minColumn + 1) + minColumn;
      newX = (column + 0.5) / eggSpawnColumns;
    } while (newX == lastEggX);

    lastEggX = newX;

    final newEgg = Egg(x: newX, y: 0, eggType: type, imagePath: imagePath);

    setState(() {
      eggs.add(newEgg);
    });
  }

  void _onEggCaught(Egg egg) {
    switch (egg.eggType) {
      case EggType.normal:
        score += 1;
        break;
      case EggType.silver:
        score += 5;
        _slowDownEggs();
        break;
      case EggType.gold:
        score += 10;
        _makeInvulnerable();
        break;
      case EggType.cracked:
        if (!isInvulnerable) {
          lives--;
          _showSplashEffect();
          if (lives <= 0) _gameOver();
        }
        break;
    }
  }

  void _slowDownEggs() {
    final originalSpeed = eggFallSpeed;
    setState(() {
      eggFallSpeed = eggFallSpeed * 0.7;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          eggFallSpeed = originalSpeed;
        });
      }
    });
  }

  void _makeInvulnerable() {
    setState(() {
      isInvulnerable = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isInvulnerable = false;
        });
      }
    });
  }

  void _showSplashEffect() {
    // TODO: реализовать эффект брызг (можно анимацию, Overlay и т.п.)
  }

  void _updateEggs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final chickenLeft = chickenX * screenWidth - chickenWidth / 2;
    final chickenRight = chickenLeft + chickenWidth;
    final chickenTop = screenHeight - chickenBottomOffset - chickenWidth;

    List<Egg> eggsToRemove = [];

    for (var egg in List<Egg>.from(eggs)) {
      // Все яйца падают вниз
      egg.y += eggFallSpeed;

      final eggTopPx = egg.y * screenHeight;
      final eggLeftPx = egg.x * screenWidth;
      final eggRightPx = eggLeftPx + eggWidth;

      final isOverChicken =
          eggRightPx > chickenLeft && eggLeftPx < chickenRight;

      final catchDelayPx = -50;
      final eggBottomPx = eggTopPx + eggWidth + catchDelayPx;

      final isCatchZone =
          eggBottomPx >= chickenTop &&
          eggTopPx <= screenHeight - chickenBottomOffset;

      if (isCatchZone && isOverChicken) {
        // Яйцо поймано
        _onEggCaught(egg);
        eggsToRemove.add(egg);
        continue;
      }

      final isOutside = eggTopPx > screenHeight;
      if (isOutside) {
        // Яйцо упало за экран — если это НЕ треснутое (cracked), теряем жизнь
        if (egg.eggType != EggType.cracked && !isInvulnerable) {
          lives--;
          if (lives <= 0) {
            _gameOver();
            return;
          }
        }
        eggsToRemove.add(egg);
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
