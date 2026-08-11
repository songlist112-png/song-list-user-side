import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../database/isar_database.dart';
import '../../data/isar_subscription_repository.dart';
import '../../data/subscription_remote_data_source.dart';
import '../../domain/subscription_entitlement.dart';
import '../../domain/subscription_repository.dart';

enum SubscriptionGateStatus {
  loading,
  entitled,
  expired,
  internetRequired,
  serviceUnavailable,
}

class SubscriptionGateState {
  const SubscriptionGateState(this.status, {this.entitlement});

  const SubscriptionGateState.loading() : this(SubscriptionGateStatus.loading);

  final SubscriptionGateStatus status;
  final SubscriptionEntitlement? entitlement;
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return IsarSubscriptionRepository(
    IsarDatabase.instance,
    SubscriptionRemoteDataSource(Supabase.instance.client),
  );
});

final subscriptionGateProvider =
    StateNotifierProvider.autoDispose<
      SubscriptionGateController,
      SubscriptionGateState
    >((ref) {
      return SubscriptionGateController(
        ref.watch(subscriptionRepositoryProvider),
        () => Supabase.instance.client.auth.currentUser?.id,
      );
    });

class SubscriptionGateController extends StateNotifier<SubscriptionGateState> {
  SubscriptionGateController(
    this._repository,
    this._userId, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const SubscriptionGateState.loading());

  final SubscriptionRepository _repository;
  final String? Function() _userId;
  final DateTime Function() _clock;

  Future<void> validate() async {
    if (state.status != SubscriptionGateStatus.loading) {
      state = const SubscriptionGateState.loading();
    }
    final userId = _userId();
    if (userId == null) {
      state = const SubscriptionGateState(
        SubscriptionGateStatus.serviceUnavailable,
      );
      return;
    }

    try {
      final entitlement = await _repository.validate(userId);
      if (mounted) _setEntitlement(entitlement);
    } catch (error) {
      SubscriptionEntitlement? cached;
      try {
        cached = await _repository.loadCached(userId);
      } catch (_) {
        cached = null;
      }
      if (!mounted) return;
      if (cached != null) {
        _setEntitlement(cached);
        if (state.status == SubscriptionGateStatus.entitled ||
            state.status == SubscriptionGateStatus.expired) {
          return;
        }
      }
      state = SubscriptionGateState(
        _isNetworkFailure(error)
            ? SubscriptionGateStatus.internetRequired
            : SubscriptionGateStatus.serviceUnavailable,
      );
    }
  }

  void _setEntitlement(SubscriptionEntitlement entitlement) {
    final now = _clock();
    final status = entitlement.canAccessAt(now)
        ? SubscriptionGateStatus.entitled
        : entitlement.isExpiredAt(now)
        ? SubscriptionGateStatus.expired
        : SubscriptionGateStatus.internetRequired;
    state = SubscriptionGateState(status, entitlement: entitlement);
  }

  bool _isNetworkFailure(Object error) =>
      error is SocketException ||
      error is TimeoutException ||
      error is HandshakeException ||
      error is HttpException;
}
