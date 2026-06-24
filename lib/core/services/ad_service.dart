import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';

/// Result returned to callers that request a rewarded ad.
enum RewardedAdResult { earned, dismissed, failed, adsRemoved }

/// Centralised AdMob facade.
///
/// All ad logic lives here so the rest of the app never imports the AdMob SDK
/// directly. Banner widgets are created on demand; rewarded ads are preloaded
/// and recycled. When the user owns the "Remove Ads" upgrade, every method
/// becomes a no-op via [adsRemoved].
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _initialised = false;

  /// Toggled by the purchase/profile layer. When `true` no ads are shown.
  bool adsRemoved = false;

  RewardedAd? _rewardedAd;
  bool _loadingRewarded = false;

  Future<void> init() async {
    if (_initialised) return;
    await MobileAds.instance.initialize();
    _initialised = true;
    _preloadRewarded();
  }

  // ---------------------------------------------------------------------------
  // Banner ads
  // ---------------------------------------------------------------------------

  /// Creates (but does not load) a banner ad. Returns `null` when ads are
  /// removed so callers can collapse the slot. The caller owns disposal.
  BannerAd? createBanner({void Function()? onLoaded}) {
    if (adsRemoved) return null;
    return BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error');
        },
      ),
    )..load();
  }

  // ---------------------------------------------------------------------------
  // Rewarded ads
  // ---------------------------------------------------------------------------

  void _preloadRewarded() {
    if (adsRemoved || _loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _loadingRewarded = false;
          debugPrint('Rewarded failed to load: $error');
        },
      ),
    );
  }

  /// Shows a rewarded ad, resolving with the outcome. Always preloads the next
  /// ad afterwards so the feature stays responsive.
  Future<RewardedAdResult> showRewarded() async {
    if (adsRemoved) return RewardedAdResult.adsRemoved;

    final RewardedAd? ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      return RewardedAdResult.failed;
    }

    bool earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) =>
          ad.dispose(),
    );

    await ad.show(
      onUserEarnedReward: (_, RewardItem reward) => earned = true,
    );

    _rewardedAd = null;
    _preloadRewarded();
    return earned ? RewardedAdResult.earned : RewardedAdResult.dismissed;
  }
}
