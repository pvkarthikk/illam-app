import 'dart:typed_data';

/// Web stand-in for `SafNewFile` from `package:saf_stream`.
class SafNewFile {
  const SafNewFile(this.uri, [this.fileName]);

  final Uri uri;
  final String? fileName;
}

/// Web stand-in for `SafStream` from `package:saf_stream`.
class SafStream {
  Future<Uint8List> readFileBytes(String uri, {int? start, int? count}) async {
    throw UnsupportedError('Folder backups are not available on the web.');
  }

  Future<SafNewFile> writeFileBytes(
    String treeUri,
    String fileName,
    String mime,
    Uint8List data, {
    bool? overwrite,
    bool? append,
  }) async {
    throw UnsupportedError('Folder backups are not available on the web.');
  }
}
