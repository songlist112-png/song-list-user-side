import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  String? fullName;

  String? email;

  String? avatarUrl;

  /// Local-only cached avatar file. Never uploaded as a profile column.
  String? avatarLocalPath;

  late String role;

  int? trialMinutesUsed;

  DateTime? lastLoginAt;

  late DateTime createdAt;

  late DateTime updatedAt;

  DateTime? syncedAt;
}
