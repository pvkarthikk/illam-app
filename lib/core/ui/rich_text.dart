import 'package:material_ui/material_ui.dart';

/// Splits [full] at the first occurrence of [part] and styles it with
/// [partStyle]. If [part] is missing, one plain child.
TextSpan emphasise(String full, String part, TextStyle partStyle) {
  final i = part.isEmpty ? -1 : full.indexOf(part);
  if (i < 0) {
    return TextSpan(children: [TextSpan(text: full)]);
  }
  return TextSpan(
    children: [
      TextSpan(text: full.substring(0, i)),
      TextSpan(text: part, style: partStyle),
      TextSpan(text: full.substring(i + part.length)),
    ],
  );
}
