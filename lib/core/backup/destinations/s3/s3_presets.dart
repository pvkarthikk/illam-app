/// Supported S3-compatible provider presets.
enum S3Preset { aws, b2, wasabi, r2, minio, other }

/// Default region pre-filled when switching to [preset] (`null` for B2).
String? s3DefaultRegion(S3Preset preset) => switch (preset) {
  S3Preset.aws => 'ap-south-1',
  S3Preset.b2 => null,
  S3Preset.wasabi => 'ap-southeast-1',
  S3Preset.r2 => 'auto',
  S3Preset.minio || S3Preset.other => 'us-east-1',
};

/// Whether the Region field should be shown for [preset].
bool s3ShowRegion(S3Preset preset) => preset != S3Preset.r2;

/// Whether the custom Endpoint field should be shown for [preset].
bool s3ShowEndpoint(S3Preset preset) =>
    preset == S3Preset.r2 ||
    preset == S3Preset.minio ||
    preset == S3Preset.other;

/// Whether [preset] uses virtual-hosted-style bucket URLs (`{bucket}.{endpoint}`).
bool s3VirtualHost(S3Preset preset) => preset == S3Preset.aws;

/// Computes the host-only `endpoint` (plus optional `:port`) and `https` flag.
({String endpoint, bool https}) s3EndpointFor(
  S3Preset p, {
  required String region,
  String userEndpoint = '',
}) {
  switch (p) {
    case S3Preset.aws:
      return (endpoint: 's3.$region.amazonaws.com', https: true);
    case S3Preset.b2:
      return (endpoint: 's3.$region.backblazeb2.com', https: true);
    case S3Preset.wasabi:
      return (endpoint: 's3.$region.wasabisys.com', https: true);
    case S3Preset.r2:
    case S3Preset.minio:
    case S3Preset.other:
      final uri = Uri.tryParse(userEndpoint.trim());
      if (uri == null || uri.host.isEmpty) {
        return (endpoint: '', https: false);
      }
      final endpoint = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
      return (endpoint: endpoint, https: uri.scheme.toLowerCase() == 'https');
  }
}
