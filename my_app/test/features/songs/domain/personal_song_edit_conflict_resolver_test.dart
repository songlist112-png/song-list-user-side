import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/songs/domain/personal_song_edit_conflict_resolver.dart';

void main() {
  final older = DateTime.utc(2026, 8, 4, 10);
  final newer = DateTime.utc(2026, 8, 4, 11);

  test('keeps newer pending local mutation', () {
    expect(
      PersonalSongEditConflictResolver.resolve(
        localUpdatedAt: newer,
        remoteUpdatedAt: older,
        hasPendingLocalMutation: true,
      ),
      PersonalSongEditConflictWinner.local,
    );
  });

  test('uses remote edit when local is clean or not newer', () {
    expect(
      PersonalSongEditConflictResolver.resolve(
        localUpdatedAt: newer,
        remoteUpdatedAt: older,
        hasPendingLocalMutation: false,
      ),
      PersonalSongEditConflictWinner.remote,
    );
    expect(
      PersonalSongEditConflictResolver.resolve(
        localUpdatedAt: older,
        remoteUpdatedAt: newer,
        hasPendingLocalMutation: true,
      ),
      PersonalSongEditConflictWinner.remote,
    );
  });
}
