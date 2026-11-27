/// One shipped release entry shown in the What's New and Version History sheet.
class ReleaseNoteEntry {
  const ReleaseNoteEntry({
    required this.version,
    required this.date,
    required this.highlightKeys,
  });

  final String version;
  final String date;
  final List<String> highlightKeys;
}

/// Ordered newest-first release notes shipped offline with the app.
const kAppReleases = <ReleaseNoteEntry>[
  ReleaseNoteEntry(
    version: '1.7.1',
    date: '2026-11-27',
    highlightKeys: ['v171TodoDoneNotif', 'v171TodoWidgetMine'],
  ),
  ReleaseNoteEntry(
    version: '1.7.0',
    date: '2026-11-27',
    highlightKeys: ['v170Changelog', 'v170SpendWidget', 'v170Languages'],
  ),
  ReleaseNoteEntry(
    version: '1.6.0',
    date: '2026-11-27',
    highlightKeys: ['v160BillScan'],
  ),
  ReleaseNoteEntry(
    version: '1.5.0',
    date: '2026-11-27',
    highlightKeys: ['v150Trips'],
  ),
  ReleaseNoteEntry(
    version: '1.4.0',
    date: '2026-11-26',
    highlightKeys: ['v140MoneyCharts'],
  ),
  ReleaseNoteEntry(
    version: '1.3.2',
    date: '2026-11-26',
    highlightKeys: ['v132SmsParser'],
  ),
  ReleaseNoteEntry(
    version: '1.3.1',
    date: '2026-11-25',
    highlightKeys: ['v131Routines'],
  ),
  ReleaseNoteEntry(
    version: '1.3.0',
    date: '2026-11-24',
    highlightKeys: ['v130SmsImport'],
  ),
  ReleaseNoteEntry(
    version: '1.2.0',
    date: '2026-11-23',
    highlightKeys: ['v120GmailImport'],
  ),
];

(int, int, int)? _parseSemver(String raw) {
  var s = raw.trim();
  if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
  final plus = s.indexOf('+');
  if (plus >= 0) s = s.substring(0, plus);
  final dash = s.indexOf('-');
  if (dash >= 0) s = s.substring(0, dash);
  final parts = s.split('.');
  if (parts.length != 3) return null;
  final major = int.tryParse(parts[0]);
  final minor = int.tryParse(parts[1]);
  final patch = int.tryParse(parts[2]);
  if (major == null || minor == null || patch == null) return null;
  return (major, minor, patch);
}

/// Compares semantic versions `a` and `b` (`major.minor.patch`, ignoring prefixes
/// like `v` and build metadata like `+1`).
int compareSemver(String a, String b) {
  final pa = _parseSemver(a);
  final pb = _parseSemver(b);
  if (pa == null || pb == null) return 0;
  if (pa.$1 != pb.$1) return pa.$1.compareTo(pb.$1);
  if (pa.$2 != pb.$2) return pa.$2.compareTo(pb.$2);
  return pa.$3.compareTo(pb.$3);
}

/// Returns the unseen release notes to show after an app update, or empty if none
/// should be shown automatically (e.g., fresh onboarding, already seen, or dev `1.0.0`).
List<ReleaseNoteEntry> unseenReleaseNotes({
  required String currentVersion,
  required String? lastSeenVersion,
  required bool hasCompletedOnboarding,
}) {
  if (!hasCompletedOnboarding) return const [];
  if (_parseSemver(currentVersion) == null) return const [];

  final publishedUpToCurrent = [
    for (final entry in kAppReleases)
      if (compareSemver(entry.version, currentVersion) <= 0) entry,
  ];
  if (publishedUpToCurrent.isEmpty) return const [];

  final seen = (lastSeenVersion ?? '').trim();
  if (seen.isEmpty || _parseSemver(seen) == null) {
    // Existing user upgrading onto the first version with changelog sees the current release only.
    return [
      for (final entry in publishedUpToCurrent)
        if (compareSemver(entry.version, currentVersion) == 0) entry,
    ];
  }

  if (compareSemver(currentVersion, seen) <= 0) return const [];
  return [
    for (final entry in publishedUpToCurrent)
      if (compareSemver(entry.version, seen) > 0) entry,
  ];
}
