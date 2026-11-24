import 'dart:io';

import 'package:drift/native.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:path_provider/path_provider.dart';

/// Encrypts a legacy unencrypted `illam.sqlite` file in place once.
Future<void> encryptExistingDatabase(String keyHex) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}illam.sqlite');
  if (!await file.exists()) return;

  final raf = await file.open();
  final List<int> header;
  try {
    header = await raf.read(15);
  } finally {
    await raf.close();
  }
  if (header.length < 15 || String.fromCharCodes(header) != 'SQLite format 3') {
    return;
  }

  final db = NestDatabase.forTesting(
    NativeDatabase(
      file,
      setup: (raw) {
        raw.execute('PRAGMA journal_mode = DELETE;');
        raw.execute("PRAGMA rekey = '$keyHex';");
      },
    ),
  );
  try {
    await db.customSelect('SELECT 1').get();
  } finally {
    await db.close();
  }
}
