import 'package:nm_flat/core/time/dates.dart';

class PersonRef {
  const PersonRef(this.id, this.firstName, this.type);

  final String id;
  final String firstName;
  final String type;
}

class ParsedTodo {
  const ParsedTodo(this.title, this.due, this.assignee);

  final String title;
  final String due;
  final PersonRef? assignee;
}

const _weekdays = {
  'monday': 1,
  'tuesday': 2,
  'wednesday': 3,
  'thursday': 4,
  'friday': 5,
  'saturday': 6,
  'sunday': 7,
};

final _tomorrowRe = RegExp(r'\btomorrow\b', caseSensitive: false);
final _weekdayRe = RegExp(
  r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
  caseSensitive: false,
);
final _onWeekdayRe = RegExp(
  r'\bon\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
  caseSensitive: false,
);
final _whenWordsRe = RegExp(
  r'\b(?:tomorrow|today|tonight|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
  caseSensitive: false,
);

ParsedTodo parseTodo(
  String text, {
  required String today,
  required List<PersonRef> people,
}) {
  late final String due;
  if (_tomorrowRe.hasMatch(text)) {
    due = Dates.addDays(today, 1);
  } else if (_weekdayRe.firstMatch(text) case final m?) {
    final targetIso = _weekdays[m.group(1)!.toLowerCase()]!;
    var diff = (targetIso - Dates.weekdayIso(today)) % 7;
    if (diff <= 0) diff += 7;
    due = Dates.addDays(today, diff);
  } else {
    due = today;
  }

  PersonRef? assignee;
  for (final m in RegExp(r'\b[A-Za-z]+\b').allMatches(text)) {
    final word = m.group(0)!.toLowerCase();
    for (final p in people) {
      if (p.firstName.toLowerCase() == word) {
        assignee = p;
        break;
      }
    }
    if (assignee != null) break;
  }

  var cleaned = text;
  if (assignee != null) {
    cleaned = cleaned.replaceAll(
      RegExp(
        '\\b(?:for|by|to)\\s+${RegExp.escape(assignee.firstName)}\\b',
        caseSensitive: false,
      ),
      ' ',
    );
  }
  cleaned = cleaned.replaceAll(_onWeekdayRe, ' ');
  cleaned = cleaned.replaceAll(_whenWordsRe, ' ');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isNotEmpty) {
    cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  return ParsedTodo(cleaned, due, assignee);
}
