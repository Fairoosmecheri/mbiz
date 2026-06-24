import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/services/purchase_service.dart';
import '../../shared/widgets/avatar_view.dart';
import '../../shared/widgets/coin_badge.dart';
import '../profile/profile_notifier.dart';

/// Cosmetic items priced in coins, keyed by the id they unlock.
const Map<String, ({String name, int price})> _avatarShop =
    <String, ({String name, int price})>{
  'avatar_02': (name: 'Fox', price: 200),
  'avatar_03': (name: 'Panda', price: 200),
  'avatar_04': (name: 'Lion', price: 350),
  'avatar_05': (name: 'Frog', price: 350),
  'avatar_06': (name: 'Octopus', price: 500),
  'avatar_07': (name: 'Unicorn', price: 800),
  'avatar_08': (name: 'Dragon', price: 1000),
};

/// The Shop: spend coins on avatars and buy the one-time "Remove Ads" upgrade.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final purchases = ref.read(purchaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: CoinBadge(coins: profile.coins)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Remove Ads premium upgrade.
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.block_rounded, color: Colors.white),
              ),
              title: const Text('Remove Ads',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('One-time purchase. Removes all banner ads.'),
              trailing: profile.adsRemoved
                  ? const Chip(label: Text('Owned'))
                  : ElevatedButton(
                      onPressed: () => _buyRemoveAds(context, ref, purchases),
                      child: Text(purchases.priceFor(StoreProducts.removeAds)),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Avatars',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: <Widget>[
              for (final entry in _avatarShop.entries)
                _AvatarShopCard(
                  avatarId: entry.key,
                  name: entry.value.name,
                  price: entry.value.price,
                  owned: profile.ownedAvatars.contains(entry.key),
                  onBuy: () => _buyAvatar(
                      context, ref, entry.key, entry.value.price),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _buyAvatar(
      BuildContext context, WidgetRef ref, String avatarId, int price) {
    final notifier = ref.read(profileProvider.notifier);
    if (notifier.spendCoins(price)) {
      notifier.unlockAvatar(avatarId);
      _toast(context, 'Unlocked! Equip it from your Profile.');
    } else {
      _toast(context, 'Not enough coins.');
    }
  }

  Future<void> _buyRemoveAds(
      BuildContext context, WidgetRef ref, PurchaseService purchases) async {
    final PurchaseResult result = await purchases.buy(StoreProducts.removeAds);
    if (!context.mounted) return;
    if (result.status == PurchaseStatus.purchased ||
        result.status == PurchaseStatus.restored) {
      ref.read(profileProvider.notifier).removeAds();
      _toast(context, 'Ads removed. Thank you! 💜');
    } else if (result.status == PurchaseStatus.cancelled) {
      _toast(context, 'Purchase cancelled.');
    } else {
      _toast(context, 'Purchase failed. Please try again.');
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AvatarShopCard extends StatelessWidget {
  const _AvatarShopCard({
    required this.avatarId,
    required this.name,
    required this.price,
    required this.owned,
    required this.onBuy,
  });

  final String avatarId;
  final String name;
  final int price;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            AvatarView(avatarId: avatarId, size: 52),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (owned)
                    const Text('Owned',
                        style: TextStyle(color: AppColors.success))
                  else
                    OutlinedButton(
                      onPressed: onBuy,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.monetization_on_rounded,
                              size: 14, color: AppColors.coin),
                          Text(' $price'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
