class SongAttachment {
  const SongAttachment({
    this.id,
    required this.name,
    this.storagePath,
    this.localPath,
    required this.fileType,
    required this.fileSize,
  });

  final String? id;
  final String name;
  final String? storagePath;
  final String? localPath;
  final String fileType;
  final int fileSize;

  bool get needsUpload => storagePath == null && localPath != null;
}
