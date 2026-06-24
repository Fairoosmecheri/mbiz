import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob ad-unit configuration.
///
/// In debug builds Google's official **test** ad unit ids are returned so we
/// never accidentally serve (or click) live ads during development. Replace the
/// production ids below with your real AdMob unit ids before publishing.
class AdConstants {
  const AdConstants._();

  // ---------------------------------------------------------------------------
  // Production ad unit ids (REPLACE BEFORE RELEASE).
  // ---------------------------------------------------------------------------
  static const String _androidBanner = 'ca-app-pub-0000000000000000/0000000001';
  static const String _androidRewarded = 'ca-app-pub-0000000000000000/0000000002';
  static const String _androidInterstitial = 'ca-app-pub-0000000000000000/0000000003';

  static const String _iosBanner = 'ca-app-pub-0000000000000000/0000000011';
  static const String _iosRewarded = 'ca-app-pub-0000000000000000/0000000012';
  static const String _iosInterstitial = 'ca-app-pub-0000000000000000/0000000013';

  // ---------------------------------------------------------------------------
  // Google test ad unit ids (safe to use in development).
  // ---------------------------------------------------------------------------
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    return _isAndroid ? _androidBanner : _iosBanner;
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _isAndroid ? _testRewardedAndroid : _testRewardedIos;
    }
    return _isAndroid ? _androidRewarded : _iosRewarded;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _isAndroid ? _testInterstitialAndroid : _testInterstitialIos;
    }
    return _isAndroid ? _androidInterstitial : _iosInterstitial;
  }
}
