import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final lastBoardStoreProvider = Provider<LastBoardStore>(
  (_) => LastBoardStore(),
);

class LastBoardStore {
  LastBoardStore({
    Future<SharedPreferences> Function()? preferences,
    String? Function()? userId,
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _userId =
           userId ?? (() => Supabase.instance.client.auth.currentUser?.id);

  static const _keyPrefix = 'last_open_board_id';
  static const _columnKeyPrefix = 'last_open_board_column_index';

  final Future<SharedPreferences> Function() _preferences;
  final String? Function() _userId;

  Future<String?> read() async {
    final key = _key;
    if (key == null) return null;
    final boardId = (await _preferences()).getString(key)?.trim();
    return boardId == null || boardId.isEmpty ? null : boardId;
  }

  Future<void> save(String boardId) async {
    final key = _key;
    final columnKey = _columnKey;
    final normalizedBoardId = boardId.trim();
    if (key == null || columnKey == null || normalizedBoardId.isEmpty) return;
    final preferences = await _preferences();
    if (preferences.getString(key) != normalizedBoardId) {
      await preferences.setInt(columnKey, 0);
    }
    await preferences.setString(key, normalizedBoardId);
  }

  Future<int> readColumnIndex() async {
    final key = _columnKey;
    if (key == null) return 0;
    final index = (await _preferences()).getInt(key) ?? 0;
    return index < 0 ? 0 : index;
  }

  Future<void> saveColumnIndex(int index) async {
    final key = _columnKey;
    if (key == null) return;
    await (await _preferences()).setInt(key, index < 0 ? 0 : index);
  }

  Future<void> clear() async {
    final key = _key;
    final columnKey = _columnKey;
    if (key == null || columnKey == null) return;
    final preferences = await _preferences();
    await preferences.remove(key);
    await preferences.remove(columnKey);
  }

  String? get _key {
    final userId = _userId()?.trim();
    return userId == null || userId.isEmpty ? null : '$_keyPrefix:$userId';
  }

  String? get _columnKey {
    final userId = _userId()?.trim();
    return userId == null || userId.isEmpty
        ? null
        : '$_columnKeyPrefix:$userId';
  }
}
