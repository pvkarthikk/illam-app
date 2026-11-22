/// Scales [qty] from [baseServes] to [newServes], rounded to 2 decimals with a 0.01 floor.
double scaleQty(double qty, int baseServes, int newServes) {
  final raw = qty * newServes / baseServes;
  final rounded = (raw * 100).round() / 100;
  return rounded < 0.01 ? 0.01 : rounded;
}
