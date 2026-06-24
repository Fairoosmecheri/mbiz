import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/di/providers.dart';
import '../../features/profile/profile_notifier.dart';

/// A self-contained banner ad slot.
///
/// Collapses to nothing when the user owns "Remove Ads" or while the ad has not
/// loaded, so it never reserves empty space. Used on the Home and Games
/// screens only — never during gameplay.
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final bool adsRemoved = ref.read(profileProvider).adsRemoved;
    if (adsRemoved) return;
    _ad = ref.read(adServiceProvider).createBanner(
          onLoaded: () {
            if (mounted) setState(() => _loaded = true);
          },
        );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool adsRemoved = ref.watch(profileProvider).adsRemoved;
    if (adsRemoved || _ad == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
