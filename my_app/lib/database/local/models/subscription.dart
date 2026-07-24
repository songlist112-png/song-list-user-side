import 'package:isar/isar.dart';

part 'subscription.g.dart';

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String plan;

  late String status;

  DateTime? expiresAt;

  DateTime? lastValidatedAt;

  DateTime? syncedAt;
}
