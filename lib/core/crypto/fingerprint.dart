import 'package:cryptography/dart.dart';

String fingerprintOf(List<int> pub) {
  final digest = const DartSha256().hashSync(pub).bytes;
  final buf = StringBuffer();
  for (var i = 0; i < 6 && i < digest.length; i++) {
    buf.write(digest[i].toRadixString(16).padLeft(2, '0'));
  }
  final hex = buf.toString();
  return '${hex.substring(0, 4)} ${hex.substring(4, 8)} ${hex.substring(8, 12)}';
}
