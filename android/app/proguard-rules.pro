# Flutter / play-core wrappers used for deferred components.
-keep class io.flutter.** { *; }
-keep class com.google.android.play.core.** { *; }

# Google Mobile Ads (AdMob).
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# in_app_purchase / billing.
-keep class com.android.billingclient.** { *; }
