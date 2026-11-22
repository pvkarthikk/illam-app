const staffMessageLanguages = ['en', 'hi', 'ta'];

String staffDailyMessage({
  required String lang,
  required String name,
  required List<({String name, String room})> jobs,
}) {
  final (String header, String footer) = switch (lang) {
    'hi' => ('$name जी, आज के काम:', 'धन्यवाद!'),
    'ta' => ('$name, இன்றைய வேலைகள்:', 'நன்றி!'),
    _ => ('$name, today’s work:', 'Thank you!'),
  };
  return [
    header,
    for (var i = 0; i < jobs.length; i++)
      '${i + 1}. ${jobs[i].name} (${jobs[i].room})',
    footer,
  ].join('\n');
}
