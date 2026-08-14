import 'subscription_entitlement.dart';

abstract interface class SubscriptionRepository {
  Future<SubscriptionEntitlement> validate(String userId);

  Future<SubscriptionEntitlement?> loadCached(String userId);
}
