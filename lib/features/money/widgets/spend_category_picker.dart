import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Category chip selector with an inline `＋ Custom` option for user-defined
/// categories alongside built-in household categories.
class SpendCategoryPicker extends StatefulWidget {
  const SpendCategoryPicker({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
    this.errorText,
    this.showDots = true,
  });

  final String value;
  final List<String> categories;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool showDots;

  @override
  State<SpendCategoryPicker> createState() => _SpendCategoryPickerState();
}

class _SpendCategoryPickerState extends State<SpendCategoryPicker> {
  final _customCtrl = TextEditingController();
  final _customFocus = FocusNode();
  bool _customMode = false;

  @override
  void dispose() {
    _customCtrl.dispose();
    _customFocus.dispose();
    super.dispose();
  }

  void _enterCustomMode() {
    final trimmed = widget.value.trim();
    final isExistingCustom =
        trimmed.isNotEmpty && !spendCategories.contains(widget.value);
    if (!_customMode) {
      setState(() {
        _customMode = true;
        _customCtrl.text = isExistingCustom ? trimmed : '';
        _customCtrl.selection = TextSelection.collapsed(
          offset: _customCtrl.text.length,
        );
      });
      if (!isExistingCustom) {
        widget.onChanged('');
      }
    }
    _customFocus.requestFocus();
  }

  void _selectChip(String cat) {
    if (_customMode) {
      setState(() => _customMode = false);
      _customFocus.unfocus();
    }
    widget.onChanged(cat);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final options = mergeSpendCategories([
      ...widget.categories,
      if (!_customMode && widget.value.trim().isNotEmpty) widget.value,
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final cat in options)
              NestChip(
                label: cat,
                selected: !_customMode && widget.value == cat,
                dotColor: widget.showDots
                    ? NestPalette.categoryColor(cat)
                    : null,
                onTap: () => _selectChip(cat),
              ),
            NestChip(
              label: l10n.moneyCustomCategoryChip,
              selected: _customMode,
              onTap: _enterCustomMode,
            ),
          ],
        ),
        if (_customMode) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customCtrl,
            focusNode: _customFocus,
            maxLength: maxSpendCategoryLength,
            textCapitalization: TextCapitalization.words,
            onChanged: (text) => widget.onChanged(text.trim()),
            decoration: InputDecoration(
              labelText: l10n.moneyCustomCategoryLabel,
              hintText: l10n.moneyCustomCategoryHint,
              counterText: '',
              errorText: widget.errorText,
            ),
          ),
        ] else if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: NestText.small12.copyWith(color: c.danger),
          ),
        ],
      ],
    );
  }
}
