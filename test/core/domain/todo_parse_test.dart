import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/todo_parse.dart';

void main() {
  const today = '2026-11-20'; // Friday
  const priya = PersonRef('m-priya', 'Priya', 'member');
  const arjun = PersonRef('m-arjun', 'Arjun', 'member');
  const selvi = PersonRef('s-selvi', 'Selvi', 'staff');
  const people = [priya, arjun, selvi];

  test('parseTodo handles tomorrow + for Person', () {
    final r = parseTodo(
      'Pay water bill tomorrow for Priya',
      today: today,
      people: people,
    );
    expect(r.title, 'Pay water bill');
    expect(r.due, '2026-11-21');
    expect(r.assignee, priya);
  });

  test('parseTodo handles same weekday -> +7 days', () {
    final r = parseTodo(
      'Book AC service friday',
      today: today,
      people: people,
    );
    expect(r.title, 'Book AC service');
    expect(r.due, '2026-11-27');
    expect(r.assignee, isNull);
  });

  test('parseTodo handles on weekday', () {
    final r = parseTodo(
      'Call plumber on monday',
      today: today,
      people: people,
    );
    expect(r.title, 'Call plumber');
    expect(r.due, '2026-11-23');
    expect(r.assignee, isNull);
  });

  test('parseTodo handles tonight', () {
    final r = parseTodo(
      'Return books tonight',
      today: today,
      people: people,
    );
    expect(r.title, 'Return books');
    expect(r.due, '2026-11-20');
    expect(r.assignee, isNull);
  });

  test('parseTodo keeps bare person name in title while matching assignee', () {
    final r = parseTodo(
      'call Selvi about dinner',
      today: today,
      people: people,
    );
    expect(r.title, 'Call Selvi about dinner');
    expect(r.due, '2026-11-20');
    expect(r.assignee, selvi);
  });

  test('parseTodo defaults to today and me', () {
    final r = parseTodo('pay rent', today: today, people: people);
    expect(r.title, 'Pay rent');
    expect(r.due, '2026-11-20');
    expect(r.assignee, isNull);
  });
}
