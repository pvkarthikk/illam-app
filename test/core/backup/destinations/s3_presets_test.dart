import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_presets.dart';

void main() {
  test('s3EndpointFor builds AWS endpoint over https', () {
    final res = s3EndpointFor(S3Preset.aws, region: 'ap-south-1');
    expect(res.endpoint, 's3.ap-south-1.amazonaws.com');
    expect(res.https, isTrue);
  });

  test('s3EndpointFor parses local MinIO http URL with port', () {
    final res = s3EndpointFor(
      S3Preset.minio,
      region: 'us-east-1',
      userEndpoint: 'http://192.168.1.23:9000',
    );
    expect(res.endpoint, '192.168.1.23:9000');
    expect(res.https, isFalse);
  });
}
