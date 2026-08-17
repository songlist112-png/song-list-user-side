import 'package:isar_community/isar.dart';

part 'subscription.g.dart';

@collection
class Subscription {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  /// Subscription plan:
  /// free, monthly, annual, etc.
  late String plan;

  /// trial, active, expired, canceled
  late String status;

  /// Server-authoritative subscription expiration.
  DateTime? expiresAt;

  /// Trial configuration.
  int trialLimitSeconds = 10800;

  /// Locally tracked trial usage.
  int trialUsedSeconds = 0;

  /// Last time the server successfully validated
  /// this subscription.
  DateTime? lastValidatedAt;

  /// Last successful synchronization with the server.
  DateTime? syncedAt;

  /// Maximum time the cached entitlement can be
  /// trusted while offline.
  DateTime? offlineGraceUntil;
}
