import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/game_screen/data/models/egg.dart';
import 'package:ninjachiken/features/global/services/record_service.dart';
import 'package:ninjachiken/features/global/services/sounds_effect_service.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _gameLoop;
  Timer? _eggSpawner;
  Timer? _difficultyTimer;
  Timer? _slowDownTimer;
  Timer? _invulnerabilityTimer;
  Timer? _movementTimer; // НОВЫЙ ТАЙМЕР

  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  double? lastEggX;
  Duration currentSpawnInterval = const Duration(milliseconds: 600);
  final Duration minSpawnInterval = const Duration(milliseconds: 300);
  final int maxEggsOnScreen = 15;
  final int eggSpawnColumns = 10;

  double originalSpeed = 0.01;

  // Константы для размеров и позиционирования
  final double chickenWidth = 128.0;
  final double eggWidth = 48.0;
  final double chickenBottomOffset = 80.0;

  GameBloc() : super(GameState.initial()) {
    on<StartGame>(_onStartGame);
    on<Tick>(_onTick);
    on<SpawnEgg>(_onSpawnEgg);
    on<MoveChicken>(_onMoveChicken);
    on<CatchEgg>(_onCatchEgg);
    on<EggMissed>(_onEggMissed);
    on<PauseGame>(_onPauseGame);
    on<ResumeGame>(_onResumeGame);
    on<RestartGame>(_onRestartGame);
    on<IncreaseDifficulty>(_onIncreaseDifficulty);
    on<StopMoving>(_onStopMoving); // Изменено на метод
    on<StopPicking>(_onStopPicking);
    on<SlowDownEggs>(_onSlowDownEggs);
    on<MakeInvulnerable>(_onMakeInvulnerable);
    on<EndInvulnerability>(_onEndInvulnerability);
    on<EndSlowDown>(_onEndSlowDown);
  }

  void _onMoveChicken(MoveChicken event, Emitter<GameState> emit) {
    final newX = (state.chickenX + event.dx).clamp(0.0, 1.0);

    // Всегда включаем анимацию при движении
    final isMoving = event.dx.abs() > 0.0001;

    emit(state.copyWith(chickenX: newX, isMoving: isMoving, lastDx: event.dx));

    // Сбрасываем таймер движения
    _movementTimer?.cancel();

    // Если есть движение, запускаем таймер для автоматического выключения анимации
    if (isMoving) {
      _movementTimer = Timer(const Duration(milliseconds: 200), () {
        if (!isClosed) {
          add(StopMoving());
        }
      });
    }
  }

  // Правильный метод StopMoving
  void _onStopMoving(StopMoving event, Emitter<GameState> emit) {
    _movementTimer?.cancel();
    emit(state.copyWith(isMoving: false));
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    _cancelTimers();

    // Сбрасываем все параметры
    currentSpawnInterval = const Duration(milliseconds: 900);
    originalSpeed = 0.01;
    lastEggX = null;

    emit(GameState.initial()); // isGameOver должно быть false в initial()

    // Запускаем таймеры без проверки старого state
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!isClosed && !state.isPaused && !state.isGameOver) {
        add(Tick());
      }
    });
    _startEggSpawner();
    _difficultyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed && !state.isPaused && !state.isGameOver) {
        add(IncreaseDifficulty());
      }
    });
  }

  void _onRestartGame(RestartGame event, Emitter<GameState> emit) {
    _cancelTimers();
    emit(GameState.initial());
    add(StartGame());
  }

  void _startEggSpawner() {
    _eggSpawner?.cancel();
    _eggSpawner = Timer.periodic(currentSpawnInterval, (_) {
      if (!isClosed && !state.isPaused && !state.isGameOver) {
        add(SpawnEgg());
      }
    });
  }

  void _onTick(Tick event, Emitter<GameState> emit) {
    if (state.isPaused || state.isGameOver) return;

    final updatedEggs = <Egg>[];
    final eggsToProcess = <Egg>[];

    for (final egg in state.eggs) {
      final newY = egg.y + state.eggFallSpeed;

      // Радиусы ловли слева и справа
      double chickenCatchRadiusLeft = 0.2;
      double chickenCatchRadiusRight = 0.18;
      const catchZoneY = 0.8; // зона ловли по Y

      final dx = egg.x - state.chickenX;

      final isInCatchZone =
          newY >= catchZoneY &&
          ((dx < 0 && dx.abs() < chickenCatchRadiusLeft) ||
              (dx >= 0 && dx.abs() < chickenCatchRadiusRight));

      if (isInCatchZone) {
        eggsToProcess.add(egg);
        add(CatchEgg(egg));
      } else if (newY > 1.0) {
        // Яйцо упало за экран
        eggsToProcess.add(egg);
        add(EggMissed(egg));
      } else {
        updatedEggs.add(egg.copyWith(y: newY));
      }
    }

    // Обновляем позиции яиц
    emit(state.copyWith(eggs: updatedEggs));
  }

  void _onSpawnEgg(SpawnEgg event, Emitter<GameState> emit) {
    if (state.eggs.length >= maxEggsOnScreen) return;

    final r = _random.nextDouble();
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

    // Избегаем краевых колонок
    const columnsToAvoid = 1;
    const minColumn = columnsToAvoid;
    var maxColumn = eggSpawnColumns - columnsToAvoid - 1;

    if (minColumn > maxColumn) return;

    double newX;
    int attempts = 0;
    do {
      final column = _random.nextInt(maxColumn - minColumn + 1) + minColumn;
      newX = (column + 0.5) / eggSpawnColumns;
      attempts++;
    } while (newX == lastEggX && attempts < 10);

    lastEggX = newX;

    final newEgg = Egg(x: newX, y: 0, eggType: type, imagePath: imagePath);
    emit(state.copyWith(eggs: [...state.eggs, newEgg]));
  }

  void _onCatchEgg(CatchEgg event, Emitter<GameState> emit) {
    final updatedEggs = List<Egg>.from(state.eggs)..remove(event.egg);

    int scoreIncrease = 0;

    switch (event.egg.eggType) {
      case EggType.normal:
        scoreIncrease = 1;
        _playSound('egg_catch.mp3');
        break;
      case EggType.silver:
        scoreIncrease = 5;
        _playSound('bonus.mp3');
        add(SlowDownEggs());
        break;
      case EggType.gold:
        scoreIncrease = 10;
        _playSound('bonus.mp3');
        add(MakeInvulnerable());
        break;
      case EggType.cracked:
        if (!state.isInvulnerable) {
          final newLives = state.lives - 1;
          _playSound('egg_breaks.mp3');

          emit(
            state.copyWith(eggs: updatedEggs, lives: newLives, isPicking: true),
          );

          if (newLives <= 0) {
            _gameOver();
          }
        } else {
          emit(state.copyWith(eggs: updatedEggs, isPicking: true));
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!isClosed) add(StopPicking());
        });
        return;
    }

    emit(
      state.copyWith(
        eggs: updatedEggs,
        score: state.score + scoreIncrease,
        isPicking: true,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isClosed) add(StopPicking());
    });
  }

  void _onEggMissed(EggMissed event, Emitter<GameState> emit) {
    final updatedEggs = List<Egg>.from(state.eggs)..remove(event.egg);

    if (event.egg.eggType != EggType.cracked && !state.isInvulnerable) {
      final newLives = state.lives - 1;
      emit(state.copyWith(eggs: updatedEggs, lives: newLives));

      if (newLives <= 0) {
        _gameOver();
      }
    } else {
      emit(state.copyWith(eggs: updatedEggs));
    }
  }

  void _onSlowDownEggs(SlowDownEggs event, Emitter<GameState> emit) {
    originalSpeed = state.eggFallSpeed;

    emit(
      state.copyWith(
        eggFallSpeed: state.eggFallSpeed * 0.7,
        showSlowDownIndicator: true,
      ),
    );

    _slowDownTimer?.cancel();
    _slowDownTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isClosed) add(EndSlowDown());
    });
  }

  void _onEndSlowDown(EndSlowDown event, Emitter<GameState> emit) {
    emit(
      state.copyWith(eggFallSpeed: originalSpeed, showSlowDownIndicator: false),
    );
  }

  void _onMakeInvulnerable(MakeInvulnerable event, Emitter<GameState> emit) {
    emit(state.copyWith(isInvulnerable: true, showInvulnerableIndicator: true));

    _invulnerabilityTimer?.cancel();
    _invulnerabilityTimer = Timer(const Duration(seconds: 1), () {
      if (!isClosed) add(EndInvulnerability());
    });
  }

  void _onEndInvulnerability(
    EndInvulnerability event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(isInvulnerable: false, showInvulnerableIndicator: false),
    );
  }

  void _onStopPicking(StopPicking event, Emitter<GameState> emit) {
    emit(state.copyWith(isPicking: false));
  }

  void _onPauseGame(PauseGame event, Emitter<GameState> emit) {
    _cancelTimers();
    emit(state.copyWith(isPaused: true));
  }

  void _onResumeGame(ResumeGame event, Emitter<GameState> emit) {
    if (!state.isPaused) return;

    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!isClosed && !state.isPaused && !state.isGameOver) {
        add(Tick());
      }
    });
    _startEggSpawner();
    _difficultyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed && !state.isPaused && !state.isGameOver) {
        add(IncreaseDifficulty());
      }
    });

    emit(state.copyWith(isPaused: false));
  }

  void _onIncreaseDifficulty(
    IncreaseDifficulty event,
    Emitter<GameState> emit,
  ) {
    final newSpeed = state.eggFallSpeed + 0.0025;
    originalSpeed = newSpeed; // Обновляем базовую скорость

    final nextMs = currentSpawnInterval.inMilliseconds - 100;
    if (nextMs > minSpawnInterval.inMilliseconds) {
      currentSpawnInterval = Duration(milliseconds: nextMs);
      _startEggSpawner(); // Перезапускаем спавнер с новым интервалом
    }

    emit(state.copyWith(eggFallSpeed: newSpeed));
  }

  Future<void> _playSound(String filename) async {
    try {
      await SoundEffectService().play('sounds/$filename');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _gameOver() async {
    _cancelTimers();

    emit(state.copyWith(isGameOver: true));

    if (state.score > 0) {
      await _saveScore();
    }
  }

  Future<void> _saveScore() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    final record = RecordModel(
      score: state.score.toString(),
      date: formattedDate,
    );
    final records = await RecordsService().getRecords();

    final existingIndex = records.indexWhere((r) => r.score == record.score);

    if (existingIndex >= 0) {
      records[existingIndex] = RecordModel(
        score: record.score,
        date: formattedDate,
      );
      await RecordsService().setRecords(records);
    } else {
      await RecordsService().addRecord(record);
    }
  }

  void _cancelTimers() {
    _gameLoop?.cancel();
    _eggSpawner?.cancel();
    _difficultyTimer?.cancel();
    _slowDownTimer?.cancel();
    _invulnerabilityTimer?.cancel();
    _movementTimer?.cancel(); // ДОБАВИТЬ НОВЫЙ ТАЙМЕР
  }

  @override
  Future<void> close() {
    _cancelTimers();
    _audioPlayer.dispose();
    return super.close();
  }
}
