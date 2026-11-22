import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/rich_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final nameParts = l10n.appName.split(' : ');
    final em = l10n.welcomeHeadlineEm;

    return Scaffold(
      body: KolamBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onLongPress: kDebugMode
                            ? () => context.push(Routes.debug)
                            : null,
                        child: ExcludeSemantics(
                          child: Transform.rotate(
                            angle: -6 * 3.1415926535 / 180,
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.accent,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.primary.withValues(alpha: 0.25),
                                    offset: const Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                l10n.appName[0],
                                style: const TextStyle(
                                  fontFamily: NestText.serif,
                                  fontSize: 28,
                                  color: Color(0xFF1B140A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            style: NestText.title22,
                            children: [
                              TextSpan(
                                text: nameParts.first,
                                style: TextStyle(color: c.primary),
                              ),
                              if (nameParts.length > 1)
                                TextSpan(
                                  text: ' : ${nameParts.sublist(1).join(' : ')}',
                                  style: TextStyle(color: c.accent),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: NestText.display34.copyWith(color: c.ink),
                    children: [
                      emphasise(
                        l10n.welcomeHeadline(em),
                        em,
                        TextStyle(color: c.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.welcomeSub,
                  style: NestText.body15.copyWith(color: c.ink2),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeStartLabel.toUpperCase(),
                  style: NestText.eyebrow12.copyWith(color: c.ink3),
                ),
                const SizedBox(height: 12),
                _ChoiceCard(
                  icon: Icons.home_outlined,
                  tileBg: c.primarySoft,
                  tileFg: c.primary,
                  title: l10n.welcomeCreateTitle,
                  body: l10n.welcomeCreateBody,
                  onTap: () => context.push(Routes.onboardingStep('create')),
                ),
                const SizedBox(height: 12),
                _ChoiceCard(
                  icon: Icons.group_outlined,
                  tileBg: c.accentSoft,
                  tileFg: c.accentInk,
                  title: l10n.welcomeJoinTitle,
                  body: l10n.welcomeJoinBody,
                  onTap: () => context.go(Routes.onboardingStep('join')),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: c.ink3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.welcomeHint,
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 13,
                          color: c.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextButton.icon(
                        onPressed: () => ref
                            .read(snackbarProvider)
                            .show(l10n.commonArrivesIn('P18')),
                        icon: Icon(Icons.restore_rounded, color: c.ink2),
                        label: Text(
                          l10n.welcomeRestore,
                          style: NestText.button15.copyWith(color: c.ink2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: c.ink3),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.welcomeFine,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: NestText.sans,
                                fontSize: 12.5,
                                color: c.ink3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: c.line),
                      ),
                      Semantics(
                        container: true,
                        label: l10n.welcomeCreditA11y,
                        excludeSemantics: true,
                        child: Column(
                          children: [
                            Text(
                              l10n.welcomeCreditLine1,
                              textAlign: TextAlign.center,
                              style: NestText.body15.copyWith(
                                fontFamily: NestText.serif,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                                color: c.ink2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                style: NestText.small12.copyWith(color: c.ink3),
                                children: [
                                  emphasise(
                                    l10n.welcomeCreditLine2('♥'),
                                    '♥',
                                    TextStyle(color: c.danger),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef ChoiceCard = _ChoiceCard;

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.tileBg,
    required this.tileFg,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color tileBg;
  final Color tileFg;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Semantics(
      button: true,
      container: true,
      child: Material(
        color: c.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: c.line, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: tileFg),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: NestText.title22.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 14,
                          color: c.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: c.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
