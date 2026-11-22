import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/staff_message.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class StaffShareStrip extends StatelessWidget {
  const StaffShareStrip({
    super.key,
    required this.staff,
    required this.jobs,
  });

  final TaskPerson staff;
  final List<RoutineRow> jobs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    return NestCard(
      fill: c.primarySoft,
      borderColor: c.ok,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.ok,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.tasksSendList(staff.firstName),
                  style: TextStyle(
                    fontFamily: NestText.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation.weight(700)],
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tasksJobs(jobs.length),
                  style: NestText.small12.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NestButton(
            label: l10n.tasksPreview,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.sm,
            onPressed: () =>
                showStaffShareSheet(context, staff: staff, jobs: jobs),
          ),
        ],
      ),
    );
  }
}

Future<void> showStaffShareSheet(
  BuildContext context, {
  required TaskPerson staff,
  required List<RoutineRow> jobs,
}) => showNestSheet<void>(
  context,
  (_) => _StaffShareSheet(staff: staff, jobs: jobs),
);

class _StaffShareSheet extends ConsumerStatefulWidget {
  const _StaffShareSheet({required this.staff, required this.jobs});

  final TaskPerson staff;
  final List<RoutineRow> jobs;

  @override
  ConsumerState<_StaffShareSheet> createState() => _StaffShareSheetState();
}

class _StaffShareSheetState extends ConsumerState<_StaffShareSheet> {
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = ref.read(prefsProvider).staffMsgLang(widget.staff.id);
  }

  String _message() => staffDailyMessage(
    lang: _lang,
    name: widget.staff.firstName,
    jobs: [
      for (final r in widget.jobs) (name: r.name, room: r.room),
    ],
  );

  Future<void> _setLang(String lang) async {
    setState(() => _lang = lang);
    await ref.read(prefsProvider).setStaffMsgLang(widget.staff.id, lang);
  }

  Future<void> _copy(AppLocalizations l10n, String msg) async {
    await Clipboard.setData(ClipboardData(text: msg));
    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(snackbarProvider).show(l10n.tasksCopied);
  }

  Future<void> _sendWhatsApp(String msg) async {
    final staffList =
        ref.read(activeStaffProvider).value ?? const <StaffData>[];
    String? phone;
    for (final s in staffList) {
      if (s.id == widget.staff.id) {
        phone = s.phoneE164;
        break;
      }
    }
    if (phone != null && phone.isNotEmpty) {
      final digits = IndianMobile.waDigits(phone);
      final uri = Uri.parse(
        'https://wa.me/$digits?text=${Uri.encodeComponent(msg)}',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await SharePlus.instance.share(ShareParams(text: msg));
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final msg = _message();
    final langs = [
      ('en', l10n.tasksLangEnglish),
      ('hi', l10n.tasksLangHindi),
      ('ta', l10n.tasksLangTamil),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.tasksListFor(widget.staff.firstName),
          lead: l10n.tasksShareLead,
        ),
        Text(
          l10n.tasksLanguage,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (code, label) in langs)
              NestChip(
                label: label,
                selected: _lang == code,
                onTap: () => _setLang(code),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.paper2,
              border: Border(left: BorderSide(color: c.ok, width: 3)),
            ),
            child: SelectableText(
              msg,
              style: TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['monospace', 'sans-serif'],
                fontSize: 13.5,
                height: 1.45,
                color: c.ink,
              ),
            ),
          ),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.tasksCopy,
              kind: NestButtonKind.ghost,
              onPressed: () => _copy(l10n, msg),
            ),
            NestButton(
              label: l10n.tasksWhatsApp,
              kind: NestButtonKind.primary,
              onPressed: () => _sendWhatsApp(msg),
            ),
          ],
        ),
      ],
    );
  }
}
