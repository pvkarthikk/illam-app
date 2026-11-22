/// Time-of-day greeting rule. Pure Dart.
enum Greeting { late, morning, afternoon, evening }

Greeting greetingFor(int hour) {
  if (hour < 5) return Greeting.late;
  if (hour < 12) return Greeting.morning;
  if (hour < 17) return Greeting.afternoon;
  return Greeting.evening;
}
