import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:globaledu_ai/core/config/env_config.dart';
import 'package:globaledu_ai/core/constants/subscription_constants.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

class RevenueCatService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final apiKey = (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
        ? EnvConfig.revenueCatAppleKey
        : EnvConfig.revenueCatGoogleKey;

    if (apiKey.isEmpty) {
      AppLogger.warning('RevenueCat API key not configured');
      return;
    }

    await Purchases.configure(
      PurchasesConfiguration(apiKey),
    );

    _initialized = true;
    AppLogger.info('RevenueCat initialized');
  }

  /// Login user for RevenueCat tracking.
  Future<void> login(String userId) async {
    if (!_initialized) return;
    await Purchases.logIn(userId);
  }

  /// Logout user from RevenueCat.
  Future<void> logout() async {
    if (!_initialized) return;
    await Purchases.logOut();
  }

  /// Get available subscription packages.
  Future<List<Package>> getOfferings() async {
    if (!_initialized) return [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      AppLogger.error('Failed to get offerings', e);
      return [];
    }
  }

  /// Purchase a package.
  Future<bool> purchase(Package package) async {
    if (!_initialized) return false;
    try {
      final result = await Purchases.purchasePackage(package);
      final isPro = result.entitlements.all[SubscriptionConstants.proEntitlement]
              ?.isActive ??
          false;
      final isPremium = result
              .entitlements.all[SubscriptionConstants.premiumEntitlement]
              ?.isActive ??
          false;
      return isPro || isPremium;
    } catch (e) {
      AppLogger.error('Purchase failed', e);
      return false;
    }
  }

  /// Restore previous purchases.
  Future<bool> restorePurchases() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.restorePurchases();
      return _hasActiveSubscription(info);
    } catch (e) {
      AppLogger.error('Restore purchases failed', e);
      return false;
    }
  }

  /// Check current subscription status.
  Future<String> getCurrentPlan() async {
    if (!_initialized) return SubscriptionConstants.freePlanId;
    try {
      final info = await Purchases.getCustomerInfo();
      if (info.entitlements.all[SubscriptionConstants.premiumEntitlement]
              ?.isActive ??
          false) {
        return SubscriptionConstants.premiumPlanId;
      }
      if (info.entitlements.all[SubscriptionConstants.proEntitlement]
              ?.isActive ??
          false) {
        return SubscriptionConstants.proPlanId;
      }
      return SubscriptionConstants.freePlanId;
    } catch (e) {
      AppLogger.error('Failed to get customer info', e);
      return SubscriptionConstants.freePlanId;
    }
  }

  /// Check if user has any active subscription.
  Future<bool> hasActiveSubscription() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return _hasActiveSubscription(info);
    } catch (e) {
      return false;
    }
  }

  bool _hasActiveSubscription(CustomerInfo info) {
    return info.entitlements.active.isNotEmpty;
  }
}
