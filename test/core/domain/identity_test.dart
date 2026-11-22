import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/avatar_colors.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/nav/router.dart';

void main() {
  group('Names', () {
    test('titleCase', () {
      expect(Names.titleCase('meera iyer'), 'Meera Iyer');
      expect(Names.titleCase('anand kumar r'), 'Anand Kumar R');
      expect(Names.titleCase(' priya anand '), 'Priya Anand');
      expect(Names.titleCase('mcDonald'), 'McDonald');
    });

    test('firstName and surname', () {
      expect(Names.firstName('anand kumar'), 'Anand');
      expect(Names.surname('anand kumar'), 'Kumar');
      expect(Names.surname(' '), isNull);
    });
  });

  group('HomeIds', () {
    const expectedJson =
        '{"type":"genesis","homeName":"Anand Home","creatorName":"Anand Kumar",'
        '"creatorDeviceId":"eh7ddx5bksrgcytl",'
        '"signPub":"11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=",'
        '"createdAt":1763600000000,"nonce":"AAECAwQFBgcICQoLDA0ODw=="}';

    test('genesisJson is compact with fixed key order', () {
      expect(
        HomeIds.genesisJson(
          homeName: 'Anand Home',
          creatorName: 'Anand Kumar',
          creatorDeviceId: 'eh7ddx5bksrgcytl',
          signPubB64: '11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=',
          createdAt: 1763600000000,
          nonceB64: 'AAECAwQFBgcICQoLDA0ODw==',
        ),
        expectedJson,
      );
    });

    test('fromGenesis and display', () async {
      expect(await HomeIds.fromGenesis(expectedJson), 'NM-4PJTB35W');
      expect(HomeIds.display('NM-4PJTB35W'), 'NM-4PJT-B35W');
      expect(
        RegExp(r'^NM-[A-Z2-7]{8}$').hasMatch(await HomeIds.fromGenesis('other')),
        isTrue,
      );
    });
  });

  group('AvatarColors', () {
    test('deterministic and within palette', () {
      expect(AvatarColors.pick('abc', {}), AvatarColors.pick('abc', {}));
      for (final id in ['a', 'demo-priya', 'eh7ddx5bksrgcytl']) {
        expect(AvatarColors.palette, contains(AvatarColors.pick(id, {})));
      }
    });

    test('skips used colours', () {
      final first = AvatarColors.pick('abc', {});
      expect(AvatarColors.pick('abc', {first}), isNot(first));

      final free = AvatarColors.palette[3];
      final used = AvatarColors.palette.where((c) => c != free).toSet();
      expect(AvatarColors.pick('abc', used), free);

      expect(
        AvatarColors.pick('abc', AvatarColors.palette.toSet()),
        AvatarColors.pick('abc', {}),
      );
    });
  });

  group('startRedirect', () {
    test('rules', () {
      expect(
        startRedirect(hasHome: false, location: '/today'),
        '/onboarding/welcome',
      );
      expect(startRedirect(hasHome: false, location: '/onboarding/create'), isNull);
      expect(
        startRedirect(hasHome: true, location: '/onboarding/welcome'),
        '/today',
      );
      expect(startRedirect(hasHome: true, location: '/lists'), isNull);
      expect(startRedirect(hasHome: false, location: '/debug/data-lab'), isNull);
    });
  });
}
