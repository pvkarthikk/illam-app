abstract final class MergeRules {
  /// Last writer wins per field: apply a "set" only if its HLC is newer than the field's clock.
  static bool shouldApplySet(String? currentClock, String opHlc) =>
      currentClock == null || opHlc.compareTo(currentClock) > 0;

  /// Counters always add up.
  static int applyInc(int current, int delta) => current + delta;
}
