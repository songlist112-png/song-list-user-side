import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/database/local/models/subscription.dart';

void main() {
  test('local trial limit matches fourteen days', () {
    expect(
      Subscription.defaultTrialLimitSeconds,
      const Duration(days: 14).inSeconds,
    );
    expect(Subscription().trialLimitSeconds, 1209600);
  });

  test(
    'latest migration extends active and future trials to fourteen days',
    () async {
      final migration = await File(
        'supabase/migrations/20260822010000_extend_trial_to_14_days.sql',
      ).readAsString();

      expect(migration, contains("interval '14 days'"));
      expect(migration, contains("status = 'trial'"));
      expect(migration, contains('now() + trial_duration'));
    },
  );
}
