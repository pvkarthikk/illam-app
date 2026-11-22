import 'package:nm_flat/core/domain/channels.dart';

class UsualStore {
  const UsualStore(this.channel, this.learned);

  final String channel;
  final bool learned;
}

UsualStore usualStore({
  required String list,
  required String nameKey,
  required Map<String, String> usualByKey,
  String? lastChosen,
}) {
  final valid = listChannels[list]!;
  var found = usualByKey[nameKey];
  if (found == null) {
    final digitIdx = nameKey.indexOf(RegExp(r'\d'));
    if (digitIdx > 0) {
      final cut = nameKey.substring(0, digitIdx).trim();
      if (cut.isNotEmpty) {
        found = usualByKey[cut];
      }
    }
  }
  if (found != null && valid.contains(found)) {
    return UsualStore(found, true);
  }
  if (lastChosen != null && valid.contains(lastChosen)) {
    return UsualStore(lastChosen, false);
  }
  return UsualStore(valid.first, false);
}
