import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/features/onboarding/create_home_screen.dart';
import 'package:nm_flat/features/onboarding/welcome_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.step});

  final String step;

  @override
  Widget build(BuildContext context) => switch (step) {
    'create' => const CreateHomeScreen(),
    _ => const WelcomeScreen(),
  };
}
