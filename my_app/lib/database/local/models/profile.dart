import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  String? fullName;

  String? email;

  String? avatarUrl;

  late String role;

  int? trialMinutesUsed;

  DateTime? lastLoginAt;

  late DateTime createdAt;

  late DateTime updatedAt;

  DateTime? syncedAt;
}
