class Song {
  final String id;
  final String title;
  final String? artistName;
  final int? tempo;
  final String? key; // C, D, E, F, G, A, B
  final String? keyType; // Major, Minor
  final List<String> labels;
  final String? lyrics;
  final List<String> attachments;

  const Song({
    required this.id,
    required this.title,
    this.artistName,
    this.tempo,
    this.key,
    this.keyType,
    this.labels = const [],
    this.lyrics,
    this.attachments = const [],
  });

  String get keyDisplay {
    if (key == null || key!.isEmpty) return '';
    final type = keyType ?? '';
    return type.isNotEmpty ? '$key $type' : key!;
  }

  Song copyWith({
    String? id,
    String? title,
    String? artistName,
    int? tempo,
    String? key,
    String? keyType,
    List<String>? labels,
    String? lyrics,
    List<String>? attachments,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      tempo: tempo ?? this.tempo,
      key: key ?? this.key,
      keyType: keyType ?? this.keyType,
      labels: labels ?? this.labels,
      lyrics: lyrics ?? this.lyrics,
      attachments: attachments ?? this.attachments,
    );
  }
}
