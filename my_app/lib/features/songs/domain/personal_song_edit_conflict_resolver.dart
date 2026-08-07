enum PersonalSongEditConflictWinner { local, remote }

class PersonalSongEditConflictResolver {
  const PersonalSongEditConflictResolver._();

  static PersonalSongEditConflictWinner resolve({
    required DateTime? localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required bool hasPendingLocalMutation,
  }) {
    if (!hasPendingLocalMutation || localUpdatedAt == null) {
      return PersonalSongEditConflictWinner.remote;
    }
    return localUpdatedAt.isAfter(remoteUpdatedAt)
        ? PersonalSongEditConflictWinner.local
        : PersonalSongEditConflictWinner.remote;
  }
}
