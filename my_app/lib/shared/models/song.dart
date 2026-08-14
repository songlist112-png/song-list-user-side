import 'song_attachment.dart';

enum SongCreatorType { admin, user }

class Song {
  final String id;
  final String? createdBy;
  final SongCreatorType creatorType;
  final bool canEdit;
  final String title;
  final String? artistName;
  final int? tempo;
  final String? key; // C, D, E, F, G, A, B
  final String? keyType; // Major, Minor
  final List<String> labels;
  final String? lyrics;
  final String? personalLyrics;
  final DateTime? personalEditUpdatedAt;
  final List<SongAttachment> attachments;

  const Song({
    required this.id,
    required this.title,
    this.createdBy,
    this.creatorType = SongCreatorType.user,
    this.canEdit = true,
    this.artistName,
    this.tempo,
    this.key,
    this.keyType,
    this.labels = const [],
    this.lyrics,
    this.personalLyrics,
    this.personalEditUpdatedAt,
    this.attachments = const [],
  });

  String get keyDisplay {
    if (key == null || key!.isEmpty) return '';
    final type = keyType ?? '';
    return type.isNotEmpty ? '$key $type' : key!;
  }

  String? get displayedLyrics => personalLyrics ?? lyrics;

  bool get hasPersonalEdit => personalLyrics != null;

  Song copyWith({
    String? id,
    String? createdBy,
    SongCreatorType? creatorType,
    bool? canEdit,
    String? title,
    String? artistName,
    int? tempo,
    String? key,
    String? keyType,
    List<String>? labels,
    String? lyrics,
    String? personalLyrics,
    DateTime? personalEditUpdatedAt,
    List<SongAttachment>? attachments,
  }) {
    return Song(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      creatorType: creatorType ?? this.creatorType,
      canEdit: canEdit ?? this.canEdit,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      tempo: tempo ?? this.tempo,
      key: key ?? this.key,
      keyType: keyType ?? this.keyType,
      labels: labels ?? this.labels,
      lyrics: lyrics ?? this.lyrics,
      personalLyrics: personalLyrics ?? this.personalLyrics,
      personalEditUpdatedAt:
          personalEditUpdatedAt ?? this.personalEditUpdatedAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
