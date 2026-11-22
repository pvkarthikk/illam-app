import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class _NestCheckBoxBase extends StatelessWidget {
  const _NestCheckBoxBase({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    required this.round,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Semantics(
      checked: value,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 48,
        height: 48,
        child: InkResponse(
          onTap: () => onChanged(!value),
          radius: 24,
          child: Center(
            child: AnimatedScale(
              scale: value ? 1.0 : 0.96,
              duration: duration,
              child: AnimatedContainer(
                duration: duration,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: value ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(round ? 13 : 9),
                  border: value ? null : Border.all(color: c.line2, width: 2),
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NestCheckbox extends StatelessWidget {
  const NestCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return _NestCheckBoxBase(
      value: value,
      onChanged: onChanged,
      semanticLabel: semanticLabel,
      round: false,
    );
  }
}

class RoundCheck extends StatelessWidget {
  const RoundCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return _NestCheckBoxBase(
      value: value,
      onChanged: onChanged,
      semanticLabel: semanticLabel,
      round: true,
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
    required this.semanticLabel,
    this.minusTooltip,
    this.plusTooltip,
  });

  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  final String semanticLabel;
  final String? minusTooltip;
  final String? plusTooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final l10n = AppLocalizations.of(context);
    final btnStyle = IconButton.styleFrom(
      fixedSize: const Size(38, 38),
      minimumSize: const Size(38, 38),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: c.line2, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: btnStyle,
            icon: const Icon(Icons.remove_rounded),
            tooltip: minusTooltip ?? l10n.commonDecrease,
            onPressed: onMinus,
          ),
          Semantics(
            label: semanticLabel,
            value: valueText,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  valueText,
                  textAlign: TextAlign.center,
                  style: NestText.figures16.copyWith(
                    fontSize: 14,
                    color: c.ink,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            style: btnStyle,
            icon: const Icon(Icons.add_rounded),
            tooltip: plusTooltip ?? l10n.commonIncrease,
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }
}
