import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/greeting.dart';

void main() {
  test('greetingFor maps hours to greetings', () {
    expect(greetingFor(3), Greeting.late);
    expect(greetingFor(4), Greeting.late);
    expect(greetingFor(5), Greeting.morning);
    expect(greetingFor(11), Greeting.morning);
    expect(greetingFor(12), Greeting.afternoon);
    expect(greetingFor(16), Greeting.afternoon);
    expect(greetingFor(17), Greeting.evening);
    expect(greetingFor(23), Greeting.evening);
  });
}
