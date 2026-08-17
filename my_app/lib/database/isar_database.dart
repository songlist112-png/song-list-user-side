import 'package:isar_community/isar.dart';
import 'package:my_app/database/local/models/attachment.dart';
import 'package:my_app/database/local/models/cached_board.dart';
import 'package:my_app/database/local/models/profile.dart';
import 'package:my_app/database/local/models/personal_song_edit.dart';
import 'package:my_app/database/local/models/song.dart';
import 'package:my_app/database/local/models/subscription.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/database/local/models/sync_metadata.dart';
import 'package:path_provider/path_provider.dart';

import '../features/support/data/models/support_records.dart';

class IsarDatabase {
  static late Isar instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();

    instance = await Isar.open([
      SongCollectionSchema,
      ProfileSchema,
      SubscriptionSchema,
      AttachmentSchema,
      SyncQueueSchema,
      SyncMetadataSchema,
      CachedBoardSchema,
      PersonalSongEditRecordSchema,
      SupportTicketRecordSchema,
      SupportMessageRecordSchema,
    ], directory: dir.path);
    _initialized = true;
  }
}
