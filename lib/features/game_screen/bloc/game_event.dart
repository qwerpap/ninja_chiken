import 'package:ninjachiken/features/game_screen/data/models/egg.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {}

class PauseGame extends GameEvent {}

class ResumeGame extends GameEvent {}

class StopMoving extends GameEvent {}

class RestartGame extends GameEvent {}

class StopPicking extends GameEvent {}

class Tick extends GameEvent {}

class SpawnEgg extends GameEvent {}

class MoveChicken extends GameEvent {
  final double dx;
  MoveChicken(this.dx);
}

class CatchEgg extends GameEvent {
  final Egg egg;
  CatchEgg(this.egg);
}

class EggMissed extends GameEvent {
  final Egg egg;
  EggMissed(this.egg);
}

class IncreaseDifficulty extends GameEvent {}

class SlowDownEggs extends GameEvent {}

class MakeInvulnerable extends GameEvent {}

class EndInvulnerability extends GameEvent {}

class EndSlowDown extends GameEvent {}