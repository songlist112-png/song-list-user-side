import 'package:isar/isar.dart';
import 'package:my_app/database/local/models/attachment.dart';
import 'package:my_app/database/local/models/profile.dart';
import 'package:my_app/database/local/models/song.dart';
import 'package:my_app/database/local/models/subscription.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  static late Isar instance;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    instance = await Isar.open([
      SongCollectionSchema,
      ProfileSchema,
      SubscriptionSchema,
      AttachmentSchema,
      SyncQueueSchema,
    ], directory: dir.path);
  }
}
