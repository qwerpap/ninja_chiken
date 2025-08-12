enum EggType { normal, silver, gold, cracked }

class Egg {
  final double x;
  final double y;
  final EggType eggType;
  final String imagePath;

  Egg({
    required this.x,
    required this.y,
    required this.eggType,
    required this.imagePath,
  });

  Egg copyWith({double? x, double? y, EggType? eggType, String? imagePath}) {
    return Egg(
      x: x ?? this.x,
      y: y ?? this.y,
      eggType: eggType ?? this.eggType,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
