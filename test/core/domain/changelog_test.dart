import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/changelog.dart';

void main() {
  test('compareSemver compares major.minor.patch cleanly', () {
    expect(compareSemver('1.7.0', '1.6.0'), greaterThan(0));
    expect(compareSemver('v1.7.0+1', '1.7.0'), 0);
    expect(compareSemver('1.5.0', '1.7.0'), lessThan(0));
  });

  test('unseenReleaseNotes shows only when upgraded after onboarding', () {
    expect(
      unseenReleaseNotes(
        currentVersion: '1.7.0',
        lastSeenVersion: null,
        hasCompletedOnboarding: false,
      ),
      isEmpty,
    );

    expect(
      unseenReleaseNotes(
        currentVersion: '1.0.0',
        lastSeenVersion: null,
        hasCompletedOnboarding: true,
      ),
      isEmpty,
    );

    final firstUpgrade = unseenReleaseNotes(
      currentVersion: '1.7.0',
      lastSeenVersion: null,
      hasCompletedOnboarding: true,
    );
    expect(firstUpgrade.map((e) => e.version), ['1.7.0']);

    final multiSkip = unseenReleaseNotes(
      currentVersion: '1.7.0',
      lastSeenVersion: '1.4.0',
      hasCompletedOnboarding: true,
    );
    expect(multiSkip.map((e) => e.version), ['1.7.0', '1.6.0', '1.5.0']);

    expect(
      unseenReleaseNotes(
        currentVersion: '1.7.0',
        lastSeenVersion: '1.7.0',
        hasCompletedOnboarding: true,
      ),
      isEmpty,
    );

    final patchUpgrade = unseenReleaseNotes(
      currentVersion: '1.7.1',
      lastSeenVersion: '1.7.0',
      hasCompletedOnboarding: true,
    );
    expect(patchUpgrade.map((e) => e.version), ['1.7.1']);
  });
}
