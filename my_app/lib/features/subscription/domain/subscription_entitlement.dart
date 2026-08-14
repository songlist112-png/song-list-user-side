enum SubscriptionStatus { trial, active, expired, canceled }

class SubscriptionEntitlement {
  const SubscriptionEntitlement({
    required this.plan,
    required this.status,
    required this.lastValidatedAt,
    required this.offlineGraceUntil,
    this.expiresAt,
  });

  final String plan;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime lastValidatedAt;
  final DateTime offlineGraceUntil;

  bool canAccessAt(DateTime time) {
    if (status != SubscriptionStatus.trial &&
        status != SubscriptionStatus.active) {
      return false;
    }
    final expiration = expiresAt;
    if (expiration != null && !time.isBefore(expiration)) {
      return false;
    }
    if (time.isBefore(lastValidatedAt.subtract(const Duration(minutes: 5)))) {
      return false;
    }
    return time.isBefore(offlineGraceUntil);
  }

  bool isExpiredAt(DateTime time) {
    final expiration = expiresAt;
    return status == SubscriptionStatus.expired ||
        status == SubscriptionStatus.canceled ||
        (expiration != null && !time.isBefore(expiration));
  }

  static SubscriptionStatus parseStatus(String value) => switch (value) {
    'trial' => SubscriptionStatus.trial,
    'active' => SubscriptionStatus.active,
    'expired' => SubscriptionStatus.expired,
    'canceled' => SubscriptionStatus.canceled,
    _ => throw FormatException('Unsupported subscription status: $value'),
  };
}
