import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/router.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class NestApp extends ConsumerWidget {
  const NestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      theme: NestTheme.light(),
      darkTheme: NestTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: ref.watch(snackbarProvider).messengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
