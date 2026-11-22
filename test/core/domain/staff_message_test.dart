import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/staff_message.dart';

void main() {
  const jobs = [
    (name: 'Clean bathrooms', room: 'Bathrooms'),
    (name: 'Sweep & mop floors', room: 'Whole house'),
  ];

  test('staffDailyMessage renders English, Hindi, and Tamil', () {
    expect(
      staffDailyMessage(lang: 'en', name: 'Lakshmi', jobs: jobs),
      'Lakshmi, today’s work:\n'
      '1. Clean bathrooms (Bathrooms)\n'
      '2. Sweep & mop floors (Whole house)\n'
      'Thank you!',
    );

    final hi = staffDailyMessage(lang: 'hi', name: 'Lakshmi', jobs: jobs)
        .split('\n');
    expect(hi.first, 'Lakshmi जी, आज के काम:');
    expect(hi.last, 'धन्यवाद!');

    final ta = staffDailyMessage(lang: 'ta', name: 'Lakshmi', jobs: jobs)
        .split('\n');
    expect(ta.first, 'Lakshmi, இன்றைய வேலைகள்:');
    expect(ta.last, 'நன்றி!');
  });
}
