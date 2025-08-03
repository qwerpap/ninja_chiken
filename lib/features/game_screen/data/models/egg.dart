enum EggType { normal, silver, gold, cracked }

class Egg {
  double x;
  double y;
  EggType eggType;
  String imagePath;

  Egg({
    required this.x,
    required this.y,
    required this.eggType,
    required this.imagePath,
  });
}
