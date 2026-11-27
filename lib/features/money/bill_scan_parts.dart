import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bill_scan_controller.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Opens a compact sheet to pick or define a spend category for one scanned item.
Future<String?> pickBillItemCategory(
  BuildContext context, {
  required String currentCategory,
  required List<String> allCategories,
}) => showNestSheet<String>(
  context,
  (_) => _ItemCategorySheet(
    initialCategory: currentCategory,
    allCategories: allCategories,
  ),
);

class _ItemCategorySheet extends StatefulWidget {
  const _ItemCategorySheet({
    required this.initialCategory,
    required this.allCategories,
  });

  final String initialCategory;
  final List<String> allCategories;

  @override
  State<_ItemCategorySheet> createState() => _ItemCategorySheetState();
}

class _ItemCategorySheetState extends State<_ItemCategorySheet> {
  late String _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.moneyCategory),
        SpendCategoryPicker(
          value: _selected,
          categories: widget.allCategories,
          errorText: _error,
          onChanged: (cat) => setState(() {
            _selected = cat;
            _error = null;
          }),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.moneySave,
              onPressed: () {
                final clean = _selected.trim();
                if (clean.isEmpty) {
                  setState(() => _error = l10n.moneyErrCategory);
                  return;
                }
                Navigator.of(context).pop(clean);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class BillScanItemRow extends StatelessWidget {
  const BillScanItemRow({
    super.key,
    required this.item,
    required this.nameCtrl,
    required this.amountCtrl,
    required this.onToggleIncluded,
    required this.onNameChanged,
    required this.onAmountChanged,
    required this.onPickCategory,
    required this.onRemove,
  });

  final EditableBillItem item;
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  final VoidCallback onToggleIncluded;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback onPickCategory;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final dotColor = NestPalette.categoryColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.included ? c.line : c.line.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NestCheckbox(
                value: item.included,
                semanticLabel: item.name.isEmpty
                    ? l10n.billScanItemNameHint
                    : item.name,
                onChanged: (_) => onToggleIncluded(),
              ),
              Expanded(
                child: TextField(
                  controller: nameCtrl,
                  enabled: item.included,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: onNameChanged,
                  decoration: InputDecoration(
                    hintText: l10n.billScanItemNameHint,
                    counterText: '',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.billScanDeleteItemTooltip,
                icon: Icon(Icons.close_rounded, size: 18, color: c.ink3),
                onPressed: onRemove,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 4),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 112,
                  child: TextField(
                    controller: amountCtrl,
                    enabled: item.included,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (raw) =>
                        onAmountChanged(Money.parseRupees(raw) ?? 0),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      hintText: l10n.billScanItemAmountHint,
                      isDense: true,
                    ),
                  ),
                ),
                NestChip(
                  label: item.category,
                  dotColor: dotColor,
                  selected: false,
                  onTap: item.included ? onPickCategory : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
