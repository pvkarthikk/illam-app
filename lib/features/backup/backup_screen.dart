import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_more_parts.dart';
import 'package:nm_flat/features/backup/backup_password_sheet.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/backup_status_parts.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _showDontSeeSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(title: l.backupDontSee, lead: l.backupDontSeeBody),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final home = ref.watch(currentHomeProvider).value;
    final homeId = home?.id ?? ref.watch(prefsProvider).currentHomeId ?? '';
    final homeName = home?.name ?? '';
    final cfgAsync = ref.watch(backupConfigProvider);
    final healthAsync = ref.watch(backupHealthProvider);
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;

    return Scaffold(
      appBar: NestTopBar.sub(title: l.backupTitle, subtitle: homeName),
      body: cfgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l.syncReasonOther,
              style: NestText.body15.copyWith(color: c.danger),
            ),
          ),
        ),
        data: (config) {
          final hasDestinations =
              config != null && config.destinations.isNotEmpty;
          if (hasDestinations) {
            final pw = config.password;
            if (pw == null || pw.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  AlertLine(
                    icon: Icons.warning_amber_rounded,
                    danger: true,
                    text: l.backupPwMissing,
                  ),
                  const SizedBox(height: 12),
                  NestButton(
                    label: l.backupPwTitle,
                    size: NestButtonSize.block,
                    onPressed: () => showBackupPasswordSheet(context, ref),
                  ),
                  const SizedBox(height: 20),
                  BackupPlacesSection(
                    homeId: homeId,
                    homeName: homeName,
                    config: config,
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                BackupStatusCard(config: config),
                const SizedBox(height: 20),
                BackupPlacesSection(
                  homeId: homeId,
                  homeName: homeName,
                  config: config,
                ),
                const SizedBox(height: 20),
                BackupScheduleSection(homeId: homeId, config: config),
                const SizedBox(height: 20),
                BackupMoreSection(
                  homeId: homeId,
                  homeName: homeName,
                  config: config,
                ),
              ],
            );
          }

          final others = healthAsync.value?.others ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              if (healthAsync.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l.syncReasonOther,
                    style: NestText.meta13.copyWith(color: c.danger),
                  ),
                ),
              for (final o in others)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l.backupAlsoIn(
                      homeName,
                      o.name,
                      providerShort(l, o.providerKind),
                      backupAgo(l, nowMs, o.lastSuccessAt),
                    ),
                    style: NestText.body15.copyWith(color: c.ink2),
                  ),
                ),
              NestCard(
                child: KolamBackground(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.backupHeroTitle(homeName),
                          style: NestText.display30.copyWith(color: c.ink),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.backupHeroLead,
                          style: NestText.body15.copyWith(color: c.ink2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PromiseRow(
                icon: Icons.lock_outline,
                title: l.backupPromise1Title,
                body: l.backupPromise1,
              ),
              const SizedBox(height: 12),
              _PromiseRow(
                icon: Icons.schedule,
                title: l.backupPromise2Title,
                body: l.backupPromise2,
              ),
              const SizedBox(height: 12),
              _PromiseRow(
                icon: Icons.restore,
                title: l.backupPromise3Title,
                body: l.backupPromise3,
              ),
              const SizedBox(height: 20),
              SectionHeader(title: l.backupWhere),
              const ProviderList(mode: ConnectMode.add),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _showDontSeeSheet(context),
                  child: Text(
                    l.backupDontSee,
                    style: NestText.button15.copyWith(color: c.primary),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PromiseRow extends StatelessWidget {
  const _PromiseRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: c.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: NestText.itemTitle16.copyWith(color: c.ink)),
              const SizedBox(height: 2),
              Text(body, style: NestText.body15.copyWith(color: c.ink2)),
            ],
          ),
        ),
      ],
    );
  }
}
