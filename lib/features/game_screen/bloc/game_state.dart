import 'package:ninjachiken/features/game_screen/data/models/egg.dart';

class GameState {
  final double chickenX;
  final List<Egg> eggs;
  final int lives;
  final int score;
  final bool isPaused;
  final bool isGameOver;
  final bool isInvulnerable;
  final double eggFallSpeed;
  final bool showSlowDownIndicator;
  final bool showInvulnerableIndicator;
  final bool isMoving;
  final bool isPicking;
  final double lastDx;

  const GameState({
    required this.chickenX,
    required this.eggs,
    required this.lives,
    required this.score,
    required this.isPaused,
    required this.isGameOver,
    required this.isInvulnerable,
    required this.eggFallSpeed,
    required this.showSlowDownIndicator,
    required this.showInvulnerableIndicator,
    required this.isMoving,
    required this.isPicking,
    required this.lastDx,
  });

  GameState copyWith({
    double? chickenX,
    List<Egg>? eggs,
    int? lives,
    int? score,
    bool? isPaused,
    bool? isGameOver,
    bool? isInvulnerable,
    double? eggFallSpeed,
    bool? showSlowDownIndicator,
    bool? showInvulnerableIndicator,
    bool? isMoving,
    bool? isPicking,
    double? lastDx,
  }) {
    return GameState(
      chickenX: chickenX ?? this.chickenX,
      eggs: eggs ?? this.eggs,
      lives: lives ?? this.lives,
      score: score ?? this.score,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      isInvulnerable: isInvulnerable ?? this.isInvulnerable,
      eggFallSpeed: eggFallSpeed ?? this.eggFallSpeed,
      showSlowDownIndicator:
          showSlowDownIndicator ?? this.showSlowDownIndicator,
      showInvulnerableIndicator:
          showInvulnerableIndicator ?? this.showInvulnerableIndicator,
      isMoving: isMoving ?? this.isMoving,
      isPicking: isPicking ?? this.isPicking,
      lastDx: lastDx ?? this.lastDx,
    );
  }

  factory GameState.initial() {
    return GameState(
      chickenX: 0.5,
      eggs: [],
      lives: 3,
      score: 0,
      isPaused: false,
      isGameOver: false,
      isInvulnerable: false,
      eggFallSpeed: 0.01,
      showSlowDownIndicator: false,
      showInvulnerableIndicator: false,
      isMoving: false,
      isPicking: false,
      lastDx: 0.0,
    );
  }
}
