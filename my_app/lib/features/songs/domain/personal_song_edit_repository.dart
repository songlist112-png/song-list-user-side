abstract interface class PersonalSongEditRepository {
  Future<void> save({required String songId, required String lyrics});
  Future<void> remove(String songId);
}
