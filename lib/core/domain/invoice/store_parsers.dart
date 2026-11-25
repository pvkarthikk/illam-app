import 'package:nm_flat/core/domain/invoice/html_text_extractor.dart';
import 'package:nm_flat/core/domain/invoice/invoice_line_parser.dart';
import 'package:nm_flat/core/domain/invoice/parsed_invoice.dart';

/// Identifies which supported store sent an email/invoice, or returns `null`.
InvoiceChannel? detectInvoiceChannel({
  String? fromEmail,
  String? subject,
  String? bodyText,
}) {
  final from = (fromEmail ?? '').toLowerCase();
  final subj = (subject ?? '').toLowerCase();
  final body = (bodyText ?? '').toLowerCase();
  final headerCombined = '$from $subj';

  if (headerCombined.contains('zepto') ||
      from.contains('zeptonow') ||
      body.contains('kiranakart') ||
      body.contains('zeptonow.com')) {
    return InvoiceChannel.zepto;
  }
  if (headerCombined.contains('blinkit') ||
      from.contains('grofers') ||
      body.contains('blink commerce') ||
      body.contains('blinkit.com')) {
    return InvoiceChannel.blinkit;
  }
  if (from.contains('amazon.') ||
      subj.contains('amazon.in') ||
      subj.contains('amazon order') ||
      body.contains('amazon seller services') ||
      body.contains('amazon.in/gp/')) {
    return InvoiceChannel.amazon;
  }
  if (from.contains('flipkart') ||
      subj.contains('flipkart') ||
      body.contains('flipkart internet') ||
      body.contains('flipkart.com')) {
    return InvoiceChannel.flipkart;
  }

  // Fallback for pasted invoice text without email headers.
  final all = '$headerCombined $body';
  if (all.contains('zepto')) return InvoiceChannel.zepto;
  if (all.contains('blinkit')) return InvoiceChannel.blinkit;
  if (all.contains('amazon')) return InvoiceChannel.amazon;
  if (all.contains('flipkart')) return InvoiceChannel.flipkart;
  return null;
}

/// Parses an invoice from email HTML/plain text and optional PDFBox text.
///
/// Returns `null` when the message is not from a supported store or has no
/// identifiable order/invoice total (e.g., marketing newsletters).
ParsedInvoice? parseOrderInvoice({
  String? fromEmail,
  String? subject,
  String? htmlBody,
  String? plainBody,
  String? pdfText,
  required String fallbackDate,
  InvoiceChannel? channelOverride,
}) {
  final htmlLines = htmlBody != null && htmlBody.trim().isNotEmpty
      ? htmlToStructuredLines(htmlBody)
      : const <String>[];
  final plainLines = plainBody != null && plainBody.trim().isNotEmpty
      ? plainTextToLines(plainBody)
      : const <String>[];
  final pdfLines = pdfText != null && pdfText.trim().isNotEmpty
      ? plainTextToLines(pdfText)
      : const <String>[];

  final combinedPreview = [
    ...pdfLines.take(30),
    ...plainLines.take(30),
    ...htmlLines.take(30),
  ].join(' ');

  final channel = channelOverride ??
      detectInvoiceChannel(
        fromEmail: fromEmail,
        subject: subject,
        bodyText: combinedPreview,
      );
  if (channel == null) return null;

  // Prefer structured PDF invoice text first when present, then HTML table lines,
  // then plain-text email body.
  ParsedInvoice? best;
  if (pdfLines.isNotEmpty) {
    best = _parseLinesForChannel(
      channel: channel,
      lines: pdfLines,
      subject: subject,
      fallbackDate: fallbackDate,
    );
  }
  if (best == null || (best.items.isEmpty && htmlLines.isNotEmpty)) {
    final fromHtml = _parseLinesForChannel(
      channel: channel,
      lines: htmlLines.isNotEmpty ? htmlLines : plainLines,
      subject: subject,
      fallbackDate: fallbackDate,
    );
    if (fromHtml != null) {
      if (best == null ||
          fromHtml.items.length > best.items.length ||
          (fromHtml.totalPaise > best.totalPaise && best.items.isEmpty)) {
        best = fromHtml;
      }
    }
  }
  if (best == null && htmlLines.isNotEmpty && plainLines.isNotEmpty) {
    best = _parseLinesForChannel(
      channel: channel,
      lines: plainLines,
      subject: subject,
      fallbackDate: fallbackDate,
    );
  }
  return best;
}

ParsedInvoice? _parseLinesForChannel({
  required InvoiceChannel channel,
  required List<String> lines,
  String? subject,
  required String fallbackDate,
}) {
  if (lines.isEmpty) return null;

  final orderId = _extractOrderId(channel, [
    ?subject,
    ...lines,
  ]);
  final date = _extractInvoiceDate(lines) ?? fallbackDate;

  int? grandTotal;
  int? standaloneTotal;
  int? subtotal;
  var feesPaise = 0;
  var discountPaise = 0;

  final candidateItems = <ParsedInvoiceItem>[];
  var pendingDescription = '';
  var pendingQty = 1;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Check product-card bridge lines (`Sold by: ...`, `Qty: 2`) before summary
    // classification so a pending title reaches its standalone price line.
    if (pendingDescription.isNotEmpty && _isMetadataBridgeLine(line)) {
      if (RegExp(r'^(?:qty|quantity)\b', caseSensitive: false).hasMatch(line)) {
        pendingQty = extractLineQuantity(line);
      }
      continue;
    }

    final summaryKind = classifySummaryLine(line);
    if (summaryKind != null) {
      pendingDescription = '';
      pendingQty = 1;
      switch (summaryKind) {
        case SummaryLineKind.grandTotal:
          final amt = extractRowTotalPaise(line);
          if (amt != null && amt > 0) grandTotal = amt;
          break;
        case SummaryLineKind.subtotal:
          final amt = extractRowTotalPaise(line);
          if (amt != null && amt > 0) subtotal = amt;
          break;
        case SummaryLineKind.fee:
          if (!line.toLowerCase().contains('free')) {
            final amt = extractRowTotalPaise(line);
            if (amt != null && amt > 0) feesPaise += amt;
          }
          break;
        case SummaryLineKind.discount:
          final amt = extractRowTotalPaise(line);
          if (amt != null && amt > 0) discountPaise += amt;
          break;
        case SummaryLineKind.taxOnly:
        case SummaryLineKind.headerOrNoise:
          break;
      }
      continue;
    }

    // Standalone "Total | ₹..." or "TOTAL: ₹..." row in GST tables.
    if (RegExp(
      r'^(?:total|net total|order value)(?:\s*\||\s*:|\s+₹|\s+Rs|\s+INR|\s+[0-9])',
      caseSensitive: false,
    ).hasMatch(line)) {
      pendingDescription = '';
      pendingQty = 1;
      final amt = extractRowTotalPaise(line);
      if (amt != null && amt > 0) standaloneTotal = amt;
      continue;
    }

    // Skip lines that look like tax/shipping totals or address headers without
    // product descriptions.
    final lineTotal = extractRowTotalPaise(line);
    if (lineTotal != null && lineTotal > 0) {
      var name = cleanProductDescription(line);
      final usedPending = name.isEmpty && pendingDescription.isNotEmpty;
      if (usedPending) {
        name = cleanProductDescription(pendingDescription);
      } else if (pendingDescription.isNotEmpty &&
          name.split(' ').length <= 2 &&
          !line.contains('|') &&
          RegExp(r'[A-Za-z]').hasMatch(pendingDescription)) {
        // Combine wrapped PDF line prefix (`1 Apple iPhone`) + continuation.
        final combined = '$pendingDescription $name'.trim();
        name = cleanProductDescription(combined);
      }
      final fallbackQty = usedPending ? pendingQty : 1;
      pendingDescription = '';
      pendingQty = 1;

      if (_isPlausibleProductName(name)) {
        final lineQty = extractLineQuantity(line);
        final qty = lineQty > 1 ? lineQty : fallbackQty;
        candidateItems.add(
          ParsedInvoiceItem(
            name: name,
            quantity: qty,
            amountPaise: lineTotal,
            category: inferItemCategory(name, channel),
          ),
        );
      }
      continue;
    }

    // Multi-line email card pattern (e.g. Amazon/Flipkart product block) or
    // wrapped serial-numbered PDF invoice title (`1 Apple iPhone Case -`).
    if (_looksLikeProductTitleCandidate(line)) {
      if (RegExp(r'^\d{1,2}[.)]?\s+').hasMatch(pendingDescription) &&
          pendingDescription.length < 60) {
        pendingDescription = '$pendingDescription $line';
      } else {
        pendingDescription = line;
        pendingQty = 1;
      }
    } else {
      pendingDescription = '';
      pendingQty = 1;
    }
  }

  final total = grandTotal ?? standaloneTotal ?? subtotal;
  if (total == null || total <= 0) {
    // Reject newsletters / alerts that only list promo numbers without an
    // explicit order/invoice total.
    return null;
  }

  final itemsWithFees = <ParsedInvoiceItem>[...candidateItems];
  final rawItemSum = candidateItems.fold<int>(
    0,
    (sum, item) => sum + item.amountPaise,
  );
  if (itemsWithFees.isNotEmpty && feesPaise > 0) {
    itemsWithFees.add(
      ParsedInvoiceItem(
        name: 'Delivery & fees',
        quantity: 1,
        amountPaise: feesPaise,
        category: channel.defaultCategory,
      ),
    );
  }

  final reconciled = reconcileItemsWithTotal(itemsWithFees, total);
  return ParsedInvoice(
    channel: channel,
    orderId: orderId,
    date: date,
    totalPaise: total,
    items: reconciled,
    feesPaise: feesPaise,
    discountPaise: discountPaise,
    rawSubtotalPaise: subtotal ?? rawItemSum,
  );
}

String? _extractOrderId(InvoiceChannel channel, List<String> lines) {
  final joined = lines.take(40).join('\n');
  if (channel == InvoiceChannel.amazon) {
    final amz = RegExp(r'\b(\d{3}-\d{7}-\d{7})\b').firstMatch(joined);
    if (amz != null) return amz.group(1);
  }
  if (channel == InvoiceChannel.flipkart) {
    final fk = RegExp(r'\b(OD\d{12,24})\b').firstMatch(joined);
    if (fk != null) return fk.group(1);
  }
  final labeled = RegExp(
    r'\b(?:order\s*(?:id|no\.?|number|#)|invoice\s*(?:id|no\.?|number))\s*[:#\-]?\s*([A-Z0-9][A-Z0-9\-]{4,28})\b',
    caseSensitive: false,
  ).firstMatch(joined);
  return labeled?.group(1);
}

String? _extractInvoiceDate(List<String> lines) {
  for (final line in lines.take(50)) {
    final lower = line.toLowerCase();
    if (lower.contains('invoice date') ||
        lower.contains('order date') ||
        lower.contains('ordered on') ||
        lower.contains('delivered on') ||
        lower.contains('date:')) {
      final parsed = parseInvoiceDate(line);
      if (parsed != null) return parsed;
    }
  }
  for (final line in lines.take(30)) {
    final parsed = parseInvoiceDate(line);
    if (parsed != null) return parsed;
  }
  return null;
}

bool _isPlausibleProductName(String name) {
  if (name.length < 3 || name.length > 140) return false;
  if (!RegExp(r'[A-Za-z]{2,}').hasMatch(name)) return false;
  if (classifySummaryLine(name) != null) return false;
  final lower = name.toLowerCase();
  if (lower == 'total' ||
      lower == 'amount' ||
      lower == 'price' ||
      lower == 'description' ||
      lower == 'item' ||
      lower == 'qty') {
    return false;
  }
  return true;
}

bool _looksLikeProductTitleCandidate(String line) {
  if (line.length < 4 || line.length > 120) return false;
  if (line.contains('@') || line.startsWith('http')) return false;
  if (classifySummaryLine(line) != null) return false;
  if (!RegExp(r'[A-Za-z]{3,}').hasMatch(line)) return false;
  if (extractAmountsOnLine(line).isNotEmpty) return false;
  return true;
}

bool _isMetadataBridgeLine(String line) {
  final lower = line.toLowerCase();
  return lower.startsWith('sold by') ||
      lower.startsWith('seller:') ||
      lower.startsWith('qty') ||
      lower.startsWith('quantity') ||
      lower.startsWith('condition:') ||
      lower.startsWith('color:') ||
      lower.startsWith('size:');
}
