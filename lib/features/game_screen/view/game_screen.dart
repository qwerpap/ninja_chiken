import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/game_screen/data/models/egg.dart';
import 'package:ninjachiken/features/game_screen/widgets/pause_alert.dart';
import 'package:ninjachiken/features/game_screen/widgets/game_over_alert.dart';
import 'package:ninjachiken/features/game_screen/widgets/pause_button.dart';
import 'package:ninjachiken/features/game_screen/widgets/row_lives.dart';
import 'package:ninjachiken/features/game_screen/widgets/score_container.dart';
import 'package:ninjachiken/features/global/services/record_service.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';
import 'package:ninjachiken/theme/app_colors.dart';

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
  bool isPaused = false;
  bool isGameOver = false;

  late Timer gameLoop;
  late Timer eggSpawner;
  late Timer difficultyTimer;

  bool isInvulnerable = false; // в состоянии игры

  final double chickenWidth = 128.0;
  final double eggWidth = 48.0;
  final double chickenBottomOffset = 80.0; // отступ снизу для курицы

  Duration currentSpawnInterval = const Duration(milliseconds: 900);
  final Duration minSpawnInterval = const Duration(milliseconds: 300);

  final int maxEggsOnScreen = 20;
  double? lastEggX; // чтобы не было повторной позиции
  final int eggSpawnColumns = 8; // сколько "дорожек" для яиц

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool showSlowDownIndicator = false;
  bool showInvulnerableIndicator = false;

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

  Future<void> _playSound(String filename) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$filename'));
    } catch (e) {
      // Ошибка при воспроизведении звука (можно вывести в консоль)
      print('Error playing sound: $e');
    }
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
    setState(() {
      isPaused = true;
    });

    gameLoop.cancel();
    eggSpawner.cancel();
    difficultyTimer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PauseAlert(
            score: score,
            onResume: () {
              Navigator.pop(context);
              _resumeGame();
            },
            onBackToMenu: () {
              Navigator.pop(context); // закрыть диалог
              Navigator.pop(context); // выйти в меню
            },
          ),
    );
  }

  void _resumeGame() {
    setState(() {
      isPaused = false;
    });
    _startGameLoop();
    _startEggSpawner();
    _startDifficultyTimer();
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
        _playSound('egg_catch.mp3');
        break;
      case EggType.silver:
        score += 5;
        _playSound('bonus.mp3');
        _slowDownEggs();
        break;
      case EggType.gold:
        score += 10;
        _playSound('bonus.mp3');
        _makeInvulnerable();
        break;
      case EggType.cracked:
        if (!isInvulnerable) {
          lives--;
          _playSound('egg_breaks.mp3');
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
      showSlowDownIndicator = true; // Включаем индикатор
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          eggFallSpeed = originalSpeed;
          showSlowDownIndicator = false; // Выключаем индикатор
        });
      }
    });
  }

  void _makeInvulnerable() {
    setState(() {
      isInvulnerable = true;
      showInvulnerableIndicator = true; // Включаем индикатор
    });
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isInvulnerable = false;
          showInvulnerableIndicator = false; // Выключаем индикатор
        });
      }
    });
  }

  void _showSplashEffect() {
    // TODO: реализовать эффект брызг (можно анимацию, Overlay и т.п.)
  }

  void _updateEggs() {
    if (isPaused) return;
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

  void _gameOver() async {
    gameLoop.cancel();
    eggSpawner.cancel();
    difficultyTimer.cancel();

    setState(() {
      isGameOver = true; // 🟡 скрываем курицу и яйца
    });

    if (score == 0) {
      // Если 0 очков — не сохраняем запись, просто показываем GameOver диалог
      _showGameOverDialog();
      return;
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    final record = RecordModel(score: score.toString(), date: formattedDate);

    final records = await RecordsService().getRecords();

    // Поиск существующей записи с таким же score
    final existingIndex = records.indexWhere((r) => r.score == record.score);

    if (existingIndex >= 0) {
      // Обновляем дату у существующей записи
      records[existingIndex] = RecordModel(
        score: record.score,
        date: formattedDate,
      );
      await RecordsService().setRecords(records);
    } else {
      // Добавляем новую запись
      await RecordsService().addRecord(record);
    }

    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blurAlertBg,
      builder: (context) {
        return GameOverAlert(
          score: score,
          onRestart: () {
            Navigator.pop(context); // закрыть диалог
            _restartGame(); // рестарт игры
          },
          onBackToMenu: () {
            Navigator.pop(context); // закрыть диалог
            Navigator.pop(context); // выйти в меню
          },
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
      chickenX = 0.5; // ← центр экрана
      isGameOver = false; // ✅ восстанавливаем элементы
    });

    _startGameLoop();
    _startEggSpawner();
    _startDifficultyTimer();
  }

  Widget _buildChicken() {
    if (isGameOver) return const SizedBox.shrink(); // 🟥 скрываем курицу
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              ImageSource.chiken,
              width: chickenWidth,
              height: chickenWidth,
            ),
            if (showInvulnerableIndicator)
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

  Widget _buildEggs() {
    if (isGameOver) return const SizedBox.shrink(); // 🟥 скрываем яйца
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
                  PauseButton(onTap: () => _showPauseDialog(context)),
                  RowLives(lives: lives),
                  ScoreContainer(score: score),
                ],
              ),
            ),
          ),

          _buildEggs(),
          _buildChicken(),
          if (showSlowDownIndicator)
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
  }
}
