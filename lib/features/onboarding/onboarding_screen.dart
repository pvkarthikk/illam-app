import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/features/onboarding/connect_step.dart';
import 'package:nm_flat/features/onboarding/create_home_screen.dart';
import 'package:nm_flat/features/onboarding/join_step.dart';
import 'package:nm_flat/features/onboarding/phrase_step.dart';
import 'package:nm_flat/features/onboarding/scan_step.dart';
import 'package:nm_flat/features/onboarding/welcome_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.step});

  final String step;

  @override
  Widget build(BuildContext context) => switch (step) {
    'create' => const CreateHomeScreen(),
    'join' => const JoinStep(),
    'phrase' => const PhraseStep(),
    'scan' => const ScanStep(),
    'connect' => const ConnectStep(),
    _ => const WelcomeScreen(),
  };
}
