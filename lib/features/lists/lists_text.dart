import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String channelName(AppLocalizations l10n, String id) => switch (id) {
  'zepto' => l10n.listsChannelZepto,
  'blinkit' => l10n.listsChannelBlinkit,
  'bigbasket' => l10n.listsChannelBigbasket,
  'amazon' => l10n.listsChannelAmazon,
  'flipkart' => l10n.listsChannelFlipkart,
  'meesho' => l10n.listsChannelMeesho,
  'offline' => l10n.listsChannelOffline,
  _ => id,
};

String channelEta(AppLocalizations l10n, String id) => switch (id) {
  'zepto' => l10n.listsEtaZepto,
  'blinkit' => l10n.listsEtaBlinkit,
  'bigbasket' => l10n.listsEtaBigbasket,
  'amazon' => l10n.listsEtaAmazon,
  'flipkart' => l10n.listsEtaFlipkart,
  'meesho' => l10n.listsEtaMeesho,
  'offline' => l10n.listsEtaOffline,
  _ => id,
};

List<ItemSnap> snapsOf(List<ItemRow> rows) => [
  for (final r in rows)
    ItemSnap(
      id: r.id,
      nameKey: r.nameKey,
      unit: r.unit,
      qtyMilli: r.qtyMilli,
      createdAt: r.createdAt,
    ),
];
