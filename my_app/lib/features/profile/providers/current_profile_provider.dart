import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../database/isar_database.dart';
import '../../../database/local/models/profile.dart';

/// Emits the active Supabase user whenever authentication changes.
final currentAuthUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (state) => state.session?.user,
  );
});

/// Reactive current-user profile sourced exclusively from Isar.
final currentProfileProvider = StreamProvider<Profile?>((ref) {
  final authUser = ref.watch(currentAuthUserProvider);
  final userId = authUser.when(
    data: (user) => user?.id,
    loading: () => Supabase.instance.client.auth.currentUser?.id,
    error: (_, _) => Supabase.instance.client.auth.currentUser?.id,
  );
  if (userId == null) return Stream<Profile?>.value(null);

  return IsarDatabase.instance.profiles
      .filter()
      .userIdEqualTo(userId)
      .watch(fireImmediately: true)
      .map((rows) => rows.firstOrNull);
});
