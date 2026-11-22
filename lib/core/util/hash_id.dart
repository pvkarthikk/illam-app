import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/util/ids.dart';

String sha1Hex(String s) =>
    Ids.hex(Sha1().toSync().hashSync(utf8.encode(s)).bytes);

String itemHistoryId(String list, String nameKey) => sha1Hex('$list:$nameKey');
