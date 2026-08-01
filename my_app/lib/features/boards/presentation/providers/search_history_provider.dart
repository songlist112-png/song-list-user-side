import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      return SearchHistoryNotifier();
    });

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super(const []) {
    _loadHistory();
  }

  static const _key = 'board_search_history';
  static const _maxHistory = 20;

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(state);
    current.removeWhere((q) => q == trimmed);
    current.insert(0, trimmed);
    if (current.length > _maxHistory) {
      current.removeLast();
    }
    state = current;
    await prefs.setStringList(_key, current);
  }

  Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(state)..removeWhere((q) => q == query);
    state = current;
    await prefs.setStringList(_key, current);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = [];
    await prefs.remove(_key);
  }
}
