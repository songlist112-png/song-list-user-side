import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/data/board_codec.dart';
import 'package:my_app/shared/models/label.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_attachment.dart';
import 'package:my_app/shared/models/song_column.dart';
import 'package:my_app/shared/models/song_list.dart';

void main() {
  test('round-trips complete offline board graph', () {
    final source = SongList(
      id: 'board-1',
      ownerId: 'user-1',
      name: 'Sunday',
      labels: const [
        Label(id: 'label-1', name: 'Opening', color: Color(0xFF123456)),
      ],
      columns: const [
        SongColumn(
          id: 'column-1',
          title: 'Set 1',
          songs: [
            Song(
              id: 'song-1',
              title: 'Grace',
              labels: ['label-1'],
              attachments: [
                SongAttachment(
                  id: 'attachment-1',
                  name: 'chart.pdf',
                  storagePath: 'user-1/song-1/chart.pdf',
                  localPath: 'cache/chart.pdf',
                  fileType: 'application/pdf',
                  fileSize: 42,
                ),
              ],
            ),
          ],
        ),
      ],
      createdAt: DateTime.utc(2026, 8, 1),
    );

    final decoded = BoardCodec.decode(BoardCodec.encode(source));

    expect(decoded.id, source.id);
    expect(decoded.labels.single.color.toARGB32(), 0xFF123456);
    expect(decoded.columns.single.songs.single.labels, ['label-1']);
    expect(
      decoded.columns.single.songs.single.attachments.single.localPath,
      'cache/chart.pdf',
    );
  });
}
