abstract class Clock {
  DateTime now();
  int get nowMs => now().millisecondsSinceEpoch;
}

class SystemClock extends Clock {
  @override
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  FixedClock(this.current);
  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration d) => current = current.add(d);
}
