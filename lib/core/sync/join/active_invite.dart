import 'dart:typed_data';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';

enum InviteStatus { open, used, expired, void_ }

/// In-memory single-use invite state held by the inviter device.
class ActiveInvite {
  ActiveInvite._(
    this.nameplate,
    this.phrase,
    this.qrSecret,
    this.createdAt,
    this.expiresAt,
  );

  factory ActiveInvite.create(String phrase, {DateTime? now}) {
    final created = now ?? DateTime.now();
    return ActiveInvite._(
      JoinPhrase.nameplate(phrase),
      phrase,
      randomBytes(16),
      created,
      created.add(const Duration(minutes: 10)),
    );
  }

  final String nameplate;
  final String phrase;
  final Uint8List qrSecret;
  final DateTime createdAt;
  final DateTime expiresAt;
  int failedAttempts = 0;
  InviteStatus status = InviteStatus.open;
  bool busy = false;

  bool isOpen(DateTime now) =>
      status == InviteStatus.open && now.isBefore(expiresAt);

  void registerFailure() {
    failedAttempts++;
    if (failedAttempts >= 3) {
      status = InviteStatus.void_;
    }
  }
}
