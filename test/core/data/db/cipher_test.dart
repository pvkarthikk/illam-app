import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('SQLite3MultipleCiphers is linked', () async {
    var hasCipher = false;
    final db = NestDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          hasCipher = raw.select('PRAGMA cipher;').isNotEmpty;
        },
      ),
    );
    try {
      await db.customSelect('SELECT 1').get();
      expect(hasCipher, isTrue);
    } finally {
      await db.close();
    }
  });

  test('an encrypted file needs the key', () async {
    const key =
        '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
    final dir = await Directory.systemTemp.createTemp('nm_cipher');
    final file = File('${dir.path}${Platform.pathSeparator}t.sqlite');

    NestDatabase open([String? k]) => NestDatabase.forTesting(
      NativeDatabase(
        file,
        setup: (raw) {
          if (k != null) {
            raw.execute("PRAGMA key = '$k';");
          }
        },
      ),
    );

    try {
      final db1 = open(key);
      try {
        await db1.customStatement(
          'CREATE TABLE IF NOT EXISTS probe (v TEXT)',
        );
        await db1.customStatement("INSERT INTO probe (v) VALUES ('hello')");
      } finally {
        await db1.close();
      }

      final raf = await file.open();
      final List<int> header;
      try {
        header = await raf.read(15);
      } finally {
        await raf.close();
      }
      expect(String.fromCharCodes(header), isNot('SQLite format 3'));

      final db2 = open();
      try {
        await expectLater(
          db2.customSelect('SELECT v FROM probe').get(),
          throwsA(anything),
        );
      } finally {
        await db2.close();
      }

      final db3 = open(key);
      try {
        final row = await db3.customSelect('SELECT v FROM probe').getSingle();
        expect(row.read<String>('v'), 'hello');
      } finally {
        await db3.close();
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
