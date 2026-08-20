class SyncStructureDelta {
  const SyncStructureDelta({
    required this.currentUserIsAdmin,
    required this.boards,
    required this.columns,
    required this.labels,
    required this.artists,
    required this.tombstones,
  });

  factory SyncStructureDelta.fromJson(Map<String, dynamic> json) =>
      SyncStructureDelta(
        currentUserIsAdmin: json['current_user_is_admin'] as bool? ?? false,
        boards: _maps(json['boards']),
        columns: _maps(json['columns']),
        labels: _maps(json['labels']),
        artists: _maps(json['artists']),
        tombstones: _maps(json['tombstones']),
      );

  final bool currentUserIsAdmin;
  final List<Map<String, dynamic>> boards;
  final List<Map<String, dynamic>> columns;
  final List<Map<String, dynamic>> labels;
  final List<Map<String, dynamic>> artists;
  final List<Map<String, dynamic>> tombstones;

  static List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List? ?? const [])
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList(growable: false);
}

class SyncSongPage {
  const SyncSongPage({
    required this.rows,
    required this.pageSize,
    this.totalCount,
  });

  factory SyncSongPage.fromJson(Object? json, {required int pageSize}) {
    final payload = switch (json) {
      Map() => json.cast<String, dynamic>(),
      List() => <String, dynamic>{'rows': json},
      _ => throw const FormatException('Invalid song sync page response'),
    };
    return SyncSongPage(
      rows: (payload['rows'] as List? ?? const [])
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList(growable: false),
      pageSize: pageSize,
      totalCount: (payload['total_count'] as num?)?.toInt(),
    );
  }

  final List<Map<String, dynamic>> rows;
  final int pageSize;
  final int? totalCount;

  bool get hasMore => rows.length == pageSize;
  DateTime? get nextUpdatedAt => rows.isEmpty
      ? null
      : DateTime.parse(rows.last['updated_at'] as String).toUtc();
  String? get nextId => rows.isEmpty ? null : rows.last['id'] as String;
}
