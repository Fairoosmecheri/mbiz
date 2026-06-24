import 'dart:async';

/// Product ids offered through the store. Keep in sync with the Play Console /
/// App Store Connect product definitions.
class StoreProducts {
  const StoreProducts._();
  static const String removeAds = 'remove_ads';
  static const Set<String> all = <String>{removeAds};
}

/// Outcome of a purchase attempt.
enum PurchaseStatus { purchased, restored, cancelled, error, pending }

class PurchaseResult {
  const PurchaseResult(this.status, {this.productId, this.message});
  final PurchaseStatus status;
  final String? productId;
  final String? message;
}

/// Abstraction over the in-app-purchase flow.
///
/// The app depends only on this interface, so the modular requirement is met:
/// the non-consumable "Remove Ads" upgrade (and any future products) can be
/// backed by the real `in_app_purchase` plugin or the mock below without
/// touching the UI. Swap the provider in `providers.dart` to go live.
abstract class PurchaseService {
  Future<void> init();

  /// Buy a non-consumable product (e.g. Remove Ads).
  Future<PurchaseResult> buy(String productId);

  /// Restore previously purchased non-consumables.
  Future<List<String>> restore();

  /// Human-readable localized price for display, or a sensible fallback.
  String priceFor(String productId);
}

/// In-memory mock so the store flow is fully exercisable in development without
/// store credentials. Always "succeeds" after a short delay.
class MockPurchaseService implements PurchaseService {
  final Set<String> _owned = <String>{};

  @override
  Future<void> init() async {}

  @override
  Future<PurchaseResult> buy(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _owned.add(productId);
    return PurchaseResult(PurchaseStatus.purchased, productId: productId);
  }

  @override
  Future<List<String>> restore() async => _owned.toList();

  @override
  String priceFor(String productId) {
    switch (productId) {
      case StoreProducts.removeAds:
        return '\$2.99';
      default:
        return '—';
    }
  }
}
