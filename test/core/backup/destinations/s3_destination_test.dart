import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_destination.dart';

void main() {
  test('s3ErrorKind maps S3 error XML codes and fallback HTTP statuses', () {
    expect(s3ErrorKind('NoSuchBucket', 404), DestError.bucketNotFound);
    expect(s3ErrorKind('InvalidAccessKeyId', 403), DestError.auth);
    expect(s3ErrorKind('SignatureDoesNotMatch', 403), DestError.auth);
    expect(s3ErrorKind('AccessDenied', 403), DestError.noPermission);
    expect(s3ErrorKind('QuotaExceeded', 403), DestError.full);
    expect(
      s3ErrorKind('AuthorizationHeaderMalformed', 400),
      DestError.bucketNotFound,
    );
    expect(s3ErrorKind('PermanentRedirect', 301), DestError.bucketNotFound);
    expect(s3ErrorKind(null, 503), DestError.unreachable);
    expect(s3ErrorKind(null, 200), isNull);
  });

  test('parseS3List filters backup filenames and parses metadata', () {
    const validName = 'NestMojo_ab12cd34_20261120-101500Z_0f1e2d3c.nmbak';
    const oneItemXml = '''
<ListBucketResult><IsTruncated>false</IsTruncated><Contents><Key>nestmojo/$validName</Key><LastModified>2026-11-20T10:15:02.000Z</LastModified><Size>2457600</Size></Contents></ListBucketResult>''';

    final res1 = parseS3List(oneItemXml);
    expect(res1.truncated, isFalse);
    expect(res1.files.length, 1);
    expect(res1.files.single.name, validName);
    expect(res1.files.single.size, 2457600);

    const withTmpXml = '''
<ListBucketResult><IsTruncated>false</IsTruncated><Contents><Key>nestmojo/$validName</Key><LastModified>2026-11-20T10:15:02.000Z</LastModified><Size>2457600</Size></Contents><Contents><Key>nestmojo/NestMojo_test_ab12.tmp</Key><LastModified>2026-11-20T10:15:02.000Z</LastModified><Size>9</Size></Contents></ListBucketResult>''';

    final res2 = parseS3List(withTmpXml);
    expect(res2.files.length, 1);
    expect(res2.files.single.name, validName);
  });

  test('debugUrl formats virtual-hosted vs path-style URLs', () {
    final aws = S3Destination(
      endpoint: 's3.ap-south-1.amazonaws.com',
      region: 'ap-south-1',
      bucket: 'mybucket',
      accessKeyId: 'k',
      secretKey: 's',
      virtualHost: true,
      https: true,
    );
    expect(
      aws.debugUrl('nestmojo/x.nmbak').toString(),
      'https://mybucket.s3.ap-south-1.amazonaws.com/nestmojo/x.nmbak',
    );

    final b2 = S3Destination(
      endpoint: 's3.us-east-005.backblazeb2.com',
      region: 'us-east-005',
      bucket: 'mybucket',
      accessKeyId: 'k',
      secretKey: 's',
      virtualHost: false,
      https: true,
    );
    expect(
      b2.debugUrl('nestmojo/x.nmbak').toString(),
      'https://s3.us-east-005.backblazeb2.com/mybucket/nestmojo/x.nmbak',
    );
  });
}
