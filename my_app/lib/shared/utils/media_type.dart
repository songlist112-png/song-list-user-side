/// Converts picker extensions and legacy values into valid MIME media types.
String normalizeMediaType(String value, {String? fileName}) {
  final normalized = value.trim().toLowerCase();
  final slash = normalized.indexOf('/');
  if (slash > 0 && slash < normalized.length - 1) return normalized;

  var extension = normalized.replaceFirst(RegExp(r'^\.'), '');
  if (extension.isEmpty || extension.contains('.')) {
    final name = fileName ?? value;
    extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  }
  return switch (extension) {
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt' => 'text/plain',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'heif' => 'image/heif',
    _ => 'application/octet-stream',
  };
}
