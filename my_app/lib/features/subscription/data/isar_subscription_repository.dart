import 'package:isar_community/isar.dart';

import '../../../database/local/models/subscription.dart';
import '../domain/subscription_entitlement.dart';
import '../domain/subscription_repository.dart';
import 'subscription_remote_data_source.dart';

class IsarSubscriptionRepository implements SubscriptionRepository {
  IsarSubscriptionRepository(
    this._isar,
    this._remote, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const offlineGracePeriod = Duration(minutes: 3);

  final Isar _isar;
  final SubscriptionRemoteDataSource _remote;
  final DateTime Function() _clock;

  @override
  Future<SubscriptionEntitlement> validate(String userId) async {
    final payload = await _remote.validateOrStartTrial();
    final validatedAt = _requiredDate(payload, 'last_validated_at');
    final expiresAt = _optionalDate(payload, 'expires_at');
    final graceLimit = validatedAt.add(offlineGracePeriod);
    final offlineGraceUntil =
        expiresAt != null && expiresAt.isBefore(graceLimit)
        ? expiresAt
        : graceLimit;
    final entitlement = SubscriptionEntitlement(
      plan: _requiredString(payload, 'plan'),
      status: SubscriptionEntitlement.parseStatus(
        _requiredString(payload, 'status'),
      ),
      expiresAt: expiresAt,
      lastValidatedAt: validatedAt,
      offlineGraceUntil: offlineGraceUntil,
    );
    await _cache(userId, entitlement);
    return entitlement;
  }

  @override
  Future<SubscriptionEntitlement?> loadCached(String userId) async {
    final record = await _isar.subscriptions.getByUserId(userId);
    final validatedAt = record?.lastValidatedAt;
    final graceUntil = record?.offlineGraceUntil;
    if (record == null || validatedAt == null || graceUntil == null) {
      return null;
    }
    try {
      return SubscriptionEntitlement(
        plan: record.plan,
        status: SubscriptionEntitlement.parseStatus(record.status),
        expiresAt: record.expiresAt,
        lastValidatedAt: validatedAt,
        offlineGraceUntil: graceUntil,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> _cache(
    String userId,
    SubscriptionEntitlement entitlement,
  ) async {
    final existing = await _isar.subscriptions.getByUserId(userId);
    final record = existing ?? Subscription()
      ..userId = userId
      ..trialLimitSeconds = 10800
      ..trialUsedSeconds = 0;
    record
      ..plan = entitlement.plan
      ..status = entitlement.status.name
      ..expiresAt = entitlement.expiresAt
      ..lastValidatedAt = entitlement.lastValidatedAt
      ..syncedAt = _clock()
      ..offlineGraceUntil = entitlement.offlineGraceUntil;
    await _isar.writeTxn(() => _isar.subscriptions.putByUserId(record));
  }

  static String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Missing subscription field: $key');
    }
    return value;
  }

  static DateTime _requiredDate(Map<String, dynamic> data, String key) {
    final value = _optionalDate(data, key);
    if (value == null) {
      throw FormatException('Missing subscription field: $key');
    }
    return value;
  }

  static DateTime? _optionalDate(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('Invalid date field: $key');
    return DateTime.parse(value).toLocal();
  }
}
