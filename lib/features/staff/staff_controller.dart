import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

class StaffController extends Notifier<String> {
  StaffController(this.staffId);

  final String staffId;

  @override
  String build() => Dates.month(Dates.today(ref.read(clockProvider)));

  void prev() {
    final start = ref.read(staffByIdProvider(staffId)).value?.startDate;
    final candidate = Dates.addMonths(state, -1);
    if (start != null &&
        start.length >= 7 &&
        candidate.compareTo(Dates.month(start)) < 0) {
      return;
    }
    state = candidate;
  }

  void next() {
    final curMonth = Dates.month(Dates.today(ref.read(clockProvider)));
    final candidate = Dates.addMonths(state, 1);
    if (candidate.compareTo(curMonth) > 0) return;
    state = candidate;
  }

  Future<void> call(StaffData s) async {
    final phone = s.phoneE164;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> whatsapp(StaffData s) async {
    final phone = s.phoneE164;
    if (phone == null || phone.isEmpty) return;
    await launchUrl(
      Uri.parse('https://wa.me/${IndianMobile.waDigits(phone)}'),
      mode: LaunchMode.externalApplication,
    );
  }
}

final staffControllerProvider =
    NotifierProvider.family<StaffController, String, String>(
      StaffController.new,
    );
