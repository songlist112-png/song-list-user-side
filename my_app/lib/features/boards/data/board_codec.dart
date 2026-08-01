import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../shared/models/artist.dart';
import '../../../shared/models/label.dart';
import '../../../shared/models/song.dart';
import '../../../shared/models/song_attachment.dart';
import '../../../shared/models/song_column.dart';
import '../../../shared/models/song_list.dart';

class BoardCodec {
  const BoardCodec._();

  static String encode(SongList board) => jsonEncode(toJson(board));

  static SongList decode(String value) =>
      fromJson((jsonDecode(value) as Map).cast<String, dynamic>());

  static Map<String, dynamic> toJson(SongList board) => {
    'id': board.id,
    'owner_id': board.ownerId,
    'name': board.name,
    'show_artist': board.showArtist,
    'show_bpm': board.showBpm,
    'dark_mode': board.darkMode,
    'is_published': board.isPublished,
    'can_edit': board.canEdit,
    'creator_type': board.creatorType.name,
    'created_at': board.createdAt.toUtc().toIso8601String(),
    'columns': board.columns.map(_columnToJson).toList(),
    'artists': board.artists.map(_artistToJson).toList(),
    'labels': board.labels.map(_labelToJson).toList(),
  };

  static SongList fromJson(Map<String, dynamic> json) => SongList(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String? ?? '',
    name: json['name'] as String,
    showArtist: json['show_artist'] as bool? ?? true,
    showBpm: json['show_bpm'] as bool? ?? false,
    darkMode: json['dark_mode'] as bool? ?? false,
    isPublished: json['is_published'] as bool? ?? false,
    canEdit: json['can_edit'] as bool? ?? false,
    creatorType: BoardCreatorType.values.byName(
      json['creator_type'] as String? ?? BoardCreatorType.user.name,
    ),
    createdAt: DateTime.parse(json['created_at'] as String),
    columns: _maps(json['columns']).map(_columnFromJson).toList(),
    artists: _maps(json['artists']).map(_artistFromJson).toList(),
    labels: _maps(json['labels']).map(_labelFromJson).toList(),
  );

  static Map<String, dynamic> _columnToJson(SongColumn column) => {
    'id': column.id,
    'title': column.title,
    'order': column.order,
    'songs': column.songs.map(_songToJson).toList(),
  };

  static SongColumn _columnFromJson(Map<String, dynamic> json) => SongColumn(
    id: json['id'] as String,
    title: json['title'] as String,
    order: json['order'] as int? ?? 0,
    songs: _maps(json['songs']).map(_songFromJson).toList(),
  );

  static Map<String, dynamic> _songToJson(Song song) => {
    'id': song.id,
    'created_by': song.createdBy,
    'creator_type': song.creatorType.name,
    'can_edit': song.canEdit,
    'title': song.title,
    'artist_name': song.artistName,
    'tempo': song.tempo,
    'key': song.key,
    'key_type': song.keyType,
    'labels': song.labels,
    'lyrics': song.lyrics,
    'attachments': song.attachments.map(_attachmentToJson).toList(),
  };

  static Song _songFromJson(Map<String, dynamic> json) => Song(
    id: json['id'] as String,
    createdBy: json['created_by'] as String?,
    creatorType: SongCreatorType.values.byName(
      json['creator_type'] as String? ?? SongCreatorType.user.name,
    ),
    canEdit: json['can_edit'] as bool? ?? false,
    title: json['title'] as String,
    artistName: json['artist_name'] as String?,
    tempo: json['tempo'] as int?,
    key: json['key'] as String?,
    keyType: json['key_type'] as String?,
    labels: (json['labels'] as List? ?? const []).cast<String>(),
    lyrics: json['lyrics'] as String?,
    attachments: _maps(json['attachments']).map(_attachmentFromJson).toList(),
  );

  static Map<String, dynamic> _artistToJson(Artist artist) => {
    'id': artist.id,
    'created_by': artist.createdBy,
    'name': artist.name,
    'can_edit': artist.canEdit,
  };

  static Artist _artistFromJson(Map<String, dynamic> json) => Artist(
    id: json['id'] as String,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String,
    canEdit: json['can_edit'] as bool? ?? false,
  );

  static Map<String, dynamic> _labelToJson(Label label) => {
    'id': label.id,
    'created_by': label.createdBy,
    'name': label.name,
    'color': label.color.toARGB32(),
    'can_edit': label.canEdit,
  };

  static Label _labelFromJson(Map<String, dynamic> json) => Label(
    id: json['id'] as String,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String,
    color: Color(json['color'] as int),
    canEdit: json['can_edit'] as bool? ?? false,
  );

  static Map<String, dynamic> _attachmentToJson(SongAttachment attachment) => {
    'id': attachment.id,
    'name': attachment.name,
    'storage_path': attachment.storagePath,
    'local_path': attachment.localPath,
    'file_type': attachment.fileType,
    'file_size': attachment.fileSize,
  };

  static SongAttachment _attachmentFromJson(Map<String, dynamic> json) =>
      SongAttachment(
        id: json['id'] as String?,
        name: json['name'] as String,
        storagePath: json['storage_path'] as String?,
        localPath: json['local_path'] as String?,
        fileType: json['file_type'] as String,
        fileSize: json['file_size'] as int,
      );

  static List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List? ?? const [])
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList(growable: false);
}
