import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Set<String> _extractIcuVariables(String text) {
  final vars = <String>{};
  var i = 0;
  while (i < text.length) {
    if (text[i] != '{') {
      i++;
      continue;
    }
    final close = _findMatchingBrace(text, i);
    final inner = text.substring(i + 1, close);
    final comma = inner.indexOf(',');
    if (comma < 0) {
      vars.add(inner.trim());
    } else {
      vars.add(inner.substring(0, comma).trim());
      final rest = inner.substring(comma + 1);
      final secondComma = rest.indexOf(',');
      if (secondComma >= 0) {
        final cases = rest.substring(secondComma + 1);
        var j = 0;
        while (j < cases.length) {
          final openBranch = cases.indexOf('{', j);
          if (openBranch < 0) break;
          final closeBranch = _findMatchingBrace(cases, openBranch);
          vars.addAll(
            _extractIcuVariables(cases.substring(openBranch + 1, closeBranch)),
          );
          j = closeBranch + 1;
        }
      }
    }
    i = close + 1;
  }
  return vars;
}

int _findMatchingBrace(String text, int openIndex) {
  var depth = 0;
  for (var i = openIndex; i < text.length; i++) {
    if (text[i] == '{') {
      depth++;
    } else if (text[i] == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  throw FormatException('Unbalanced braces in "$text"');
}

void main() {
  test('app_ta.arb and app_hi.arb have 100% key and placeholder parity with app_en.arb', () {
    final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
    final ta = jsonDecode(File('lib/l10n/app_ta.arb').readAsStringSync())
        as Map<String, dynamic>;
    final hi = jsonDecode(File('lib/l10n/app_hi.arb').readAsStringSync())
        as Map<String, dynamic>;

    final enKeys = [
      for (final k in en.keys)
        if (!k.startsWith('@')) k,
    ];
    final taKeys = [
      for (final k in ta.keys)
        if (!k.startsWith('@')) k,
    ];
    final hiKeys = [
      for (final k in hi.keys)
        if (!k.startsWith('@')) k,
    ];

    expect(ta['@@locale'], 'ta');
    expect(hi['@@locale'], 'hi');
    expect(taKeys.toSet(), enKeys.toSet());
    expect(hiKeys.toSet(), enKeys.toSet());

    for (final key in enKeys) {
      final enVal = en[key] as String;
      final taVal = ta[key] as String;
      final hiVal = hi[key] as String;

      expect(taVal.trim(), isNotEmpty, reason: 'Empty ta value for $key');
      expect(hiVal.trim(), isNotEmpty, reason: 'Empty hi value for $key');
      expect(
        _extractIcuVariables(taVal),
        _extractIcuVariables(enVal),
        reason: 'Placeholder mismatch in ta for $key',
      );
      expect(
        _extractIcuVariables(hiVal),
        _extractIcuVariables(enVal),
        reason: 'Placeholder mismatch in hi for $key',
      );
    }
  });

  test('AppLocalizations exposes en, hi, and ta and formats sample strings cleanly', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll([
        const Locale('en'),
        const Locale('hi'),
        const Locale('ta'),
      ]),
    );

    final enL10n = lookupAppLocalizations(const Locale('en'));
    final taL10n = lookupAppLocalizations(const Locale('ta'));
    final hiL10n = lookupAppLocalizations(const Locale('hi'));

    expect(enL10n.tabMoney, isNotEmpty);
    expect(taL10n.tabMoney, isNotEmpty);
    expect(hiL10n.tabMoney, isNotEmpty);
    expect(taL10n.tabMoney, isNot(enL10n.tabMoney));
    expect(hiL10n.tabMoney, isNot(enL10n.tabMoney));

    expect(taL10n.billScanSaveCount(1), isNotEmpty);
    expect(taL10n.billScanSaveCount(3), contains('3'));
    expect(hiL10n.billScanSaveCount(1), isNotEmpty);
    expect(hiL10n.billScanSaveCount(3), contains('3'));
  });
}
