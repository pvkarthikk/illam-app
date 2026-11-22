import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_presets.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/servers/server_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/server_error_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showS3Sheet(
  BuildContext context,
  WidgetRef ref,
  ConnectMode mode, {
  DestinationConfig? existing,
  VoidCallback? onPicked,
}) {
  ref.read(serverConnectControllerProvider.notifier).reset();
  return showNestSheet<void>(
    context,
    (ctx) => _S3Sheet(
      pageContext: context,
      sheetContext: ctx,
      mode: mode,
      existing: existing,
      onPicked: onPicked,
    ),
  );
}

class _S3Sheet extends ConsumerStatefulWidget {
  const _S3Sheet({
    required this.pageContext,
    required this.sheetContext,
    required this.mode,
    this.existing,
    this.onPicked,
  });

  final BuildContext pageContext;
  final BuildContext sheetContext;
  final ConnectMode mode;
  final DestinationConfig? existing;
  final VoidCallback? onPicked;

  @override
  ConsumerState<_S3Sheet> createState() => _S3SheetState();
}

class _S3SheetState extends ConsumerState<_S3Sheet> {
  late S3Preset _preset;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _endpointCtrl;
  late final TextEditingController _bucketCtrl;
  late final TextEditingController _keyIdCtrl;
  final _secretCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final savedPreset = widget.existing?.settings['preset'] as String?;
    _preset = S3Preset.values.firstWhere(
      (p) => p.name == savedPreset,
      orElse: () => S3Preset.b2,
    );
    _regionCtrl = TextEditingController(
      text:
          (widget.existing?.settings['region'] as String?) ??
          s3DefaultRegion(_preset) ??
          '',
    );
    final savedEp = (widget.existing?.settings['endpoint'] as String?) ?? '';
    final savedHttps = (widget.existing?.settings['https'] as bool?) ?? true;
    _endpointCtrl = TextEditingController(
      text: (s3ShowEndpoint(_preset) && savedEp.isNotEmpty)
          ? '${savedHttps ? 'https' : 'http'}://$savedEp'
          : '',
    );
    _bucketCtrl = TextEditingController(
      text: (widget.existing?.settings['bucket'] as String?) ?? '',
    );
    _keyIdCtrl = TextEditingController(
      text: (widget.existing?.settings['accessKeyId'] as String?) ?? '',
    );
  }

  @override
  void dispose() {
    _regionCtrl.dispose();
    _endpointCtrl.dispose();
    _bucketCtrl.dispose();
    _keyIdCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  String _presetLabel(AppLocalizations l, S3Preset p) => switch (p) {
    S3Preset.aws => l.bkSrvPresetAws,
    S3Preset.b2 => l.bkSrvPresetB2,
    S3Preset.wasabi => l.bkSrvPresetWasabi,
    S3Preset.r2 => l.bkSrvPresetR2,
    S3Preset.minio => l.bkSrvPresetMinio,
    S3Preset.other => l.bkSrvPresetOther,
  };

  void _selectPreset(S3Preset p) {
    setState(() {
      _preset = p;
      _regionCtrl.text = s3DefaultRegion(p) ?? '';
    });
  }

  Future<void> _connect() async {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(serverConnectControllerProvider.notifier);

    final region = _preset == S3Preset.r2 ? 'auto' : _regionCtrl.text.trim();
    final bucket = _bucketCtrl.text.trim();
    final accessKeyId = _keyIdCtrl.text.trim();
    final secretKey = _secretCtrl.text.trim();
    final ep = s3EndpointFor(
      _preset,
      region: region,
      userEndpoint: _endpointCtrl.text.trim(),
    );

    if (!ep.https && !kDebugMode) {
      ctrl.setErrorKey(DestError.httpsRequired.name);
      return;
    }
    if (ep.endpoint.isEmpty ||
        region.isEmpty ||
        bucket.isEmpty ||
        accessKeyId.isEmpty) {
      ctrl.setErrorKey(DestError.other.name);
      return;
    }

    final serviceName = _presetLabel(l, _preset);
    final cfg = DestinationConfig(
      destId: widget.existing?.destId ?? Ids.newId(),
      kind: 's3',
      label: l.bkSrvS3Account(bucket, serviceName),
      settings: {
        'preset': _preset.name,
        'endpoint': ep.endpoint,
        'region': region,
        'bucket': bucket,
        'accessKeyId': accessKeyId,
        'virtualHost': s3VirtualHost(_preset),
        'https': ep.https,
      },
    );

    final ok = await ctrl.connect(
      config: cfg,
      secret: secretKey,
      mode: widget.mode,
    );
    if (ok && widget.pageContext.mounted && widget.sheetContext.mounted) {
      await finishServerConnectSheet(
        widget.pageContext,
        widget.sheetContext,
        ref,
        onPicked: widget.onPicked,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final state = ref.watch(serverConnectControllerProvider);
    final errKey = state.errorKey;
    final errMsg = errKey == null
        ? null
        : serverErrorText(
            l,
            DestError.values.byName(errKey),
            _presetLabel(l, _preset),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(title: l.bkSrvS3Title),
        Text(
          l.bkSrvService,
          style: NestText.meta13.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in S3Preset.values)
              NestChip(
                label: _presetLabel(l, p),
                selected: _preset == p,
                onTap: () => _selectPreset(p),
              ),
          ],
        ),
        if (s3ShowRegion(_preset)) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _regionCtrl,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: l.bkSrvRegion),
          ),
        ],
        if (s3ShowEndpoint(_preset)) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _endpointCtrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l.bkSrvEndpoint,
              hintText: _preset == S3Preset.r2
                  ? 'https://account-id.r2.cloudflarestorage.com'
                  : 'https://s3.example.com',
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _bucketCtrl,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvBucket),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keyIdCtrl,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvAccessKeyId),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _secretCtrl,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvSecretKey),
        ),
        const SizedBox(height: 12),
        Text(l.bkSrvS3Hint, style: NestText.meta13.copyWith(color: c.ink3)),
        if (errMsg != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              errMsg,
              style: NestText.meta13.copyWith(color: c.danger),
            ),
          ),
        ],
        if (state.busy) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.backupChecking,
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ),
            ],
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(widget.sheetContext).pop(),
            ),
            NestButton(
              label: l.bkSrvConnect,
              kind: NestButtonKind.primary,
              onPressed: state.busy ? null : _connect,
            ),
          ],
        ),
      ],
    );
  }
}
