class Egg {
  double x;
  double y;
  String imagePath;
  bool isBroken;

  Egg({
    required this.x,
    required this.y,
    required this.imagePath,
    this.isBroken = false,
  });
}
