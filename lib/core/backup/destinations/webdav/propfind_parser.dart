import 'dart:io' show HttpDate;

/// Parsed entry from a WebDAV `PROPFIND` response.
class DavEntry {
  const DavEntry({
    required this.name,
    required this.size,
    this.modified,
    required this.isFolder,
  });

  final String name;
  final int size;
  final DateTime? modified;
  final bool isFolder;
}

final _responseRe = RegExp(
  r'<(?:[a-zA-Z0-9_-]+:)?response\b[^>]*>(.*?)</(?:[a-zA-Z0-9_-]+:)?response>',
  caseSensitive: false,
  dotAll: true,
);

final _collectionRe = RegExp(
  r'<(?:[a-zA-Z0-9_-]+:)?collection\b[^>]*/?>',
  caseSensitive: false,
);

String? _tag(String body, String name) {
  final re = RegExp(
    '<(?:[a-zA-Z0-9_-]+:)?$name\\b[^>]*>(.*?)</(?:[a-zA-Z0-9_-]+:)?$name>',
    caseSensitive: false,
    dotAll: true,
  );
  return re.firstMatch(body)?.group(1)?.trim();
}

/// Parses a WebDAV `207 Multi-Status` XML body into [DavEntry] items.
List<DavEntry> parsePropfind(String xml) {
  final out = <DavEntry>[];
  for (final match in _responseRe.allMatches(xml)) {
    final body = match.group(1) ?? '';
    final rawHref = _tag(body, 'href') ?? '';
    final href = Uri.decodeFull(rawHref);
    final segments = href.split('/').where((s) => s.isNotEmpty);
    final name = segments.isEmpty ? '' : segments.last;

    final lenRaw = _tag(body, 'getcontentlength') ?? '';
    final size = int.tryParse(lenRaw) ?? 0;

    DateTime? modified;
    final modRaw = _tag(body, 'getlastmodified');
    if (modRaw != null && modRaw.isNotEmpty) {
      try {
        modified = HttpDate.parse(modRaw);
      } on Object {
        modified = null;
      }
    }

    final isFolder = _collectionRe.hasMatch(body);
    out.add(
      DavEntry(
        name: name,
        size: size,
        modified: modified,
        isFolder: isFolder,
      ),
    );
  }
  return out;
}
