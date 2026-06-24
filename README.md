# 🕹️ Pocket Arcade

A polished, extensible **mobile gaming platform** built with Flutter. One app,
many quick-play mini-games, wrapped in an RPG-style progression layer (XP,
levels, coins), daily rewards, achievements, challenges, statistics,
leaderboards and AdMob monetization.

The whole thing is designed around a single principle: **adding a new game
should never require touching existing game code.** Implement one interface,
register one line, and the game appears automatically across the games grid,
statistics, challenges, achievements and leaderboards.

---

## ✨ Features

| Area | What's included |
|------|-----------------|
| **5 games** | Reaction Test, Speed Tap, Stack Tower, Ball Dodge, Memory Match |
| **Progression** | XP curve with increasing requirements, levels, animated XP bar |
| **Economy** | Coins earned from play, wins, daily rewards, achievements & rewarded ads |
| **Daily rewards** | 7-day streak table (50 → 500 coins) with streak tracking |
| **Achievements** | Data-driven, expandable catalogue with automatic evaluation |
| **Daily challenges** | Auto-generated each day from the registered games |
| **Statistics** | Lifetime games, time played, win rate + per-game breakdown |
| **Leaderboards** | Global / Friends / Weekly scopes (Firebase-ready, mocked backend) |
| **Monetization** | AdMob banner + rewarded ads, modular IAP "Remove Ads" upgrade |
| **UX** | Light/Dark/System themes, responsive layout, bottom-nav shell |

---

## 🏛️ Architecture

Clean Architecture + feature-based folders + SOLID, with **Riverpod** for state
management/DI and **Hive** for local persistence.

```
lib/
├── main.dart                      # Boot: Hive + AdMob, eager providers, daily login
├── app.dart                       # MaterialApp.router + theme wiring
│
├── core/                          # Cross-cutting infrastructure
│   ├── constants/                 # App constants, colours, AdMob ids
│   ├── theme/                     # Light/Dark ThemeData
│   ├── router/                    # go_router route table
│   ├── di/                        # providers.dart — the composition root
│   ├── services/                  # Storage(Hive), Ads, Audio, Firebase, Purchases
│   └── utils/                     # XpCalculator (pure level/XP math)
│
├── data/                          # Models + repositories (persistence gateways)
│   ├── models/                    # PlayerProfile, GameStats, Achievement, …
│   └── repositories/              # Profile, Stats, Achievement, Challenge, …
│
├── shared/widgets/                # Reusable UI (XpBar, CoinBadge, BannerAd, Avatar…)
│
└── features/                      # One folder per feature
    ├── game_framework/            # ★ MiniGame interface, GameController, Registry
    ├── games/                     # The 5 games + host page + result overlay
    │   ├── reaction_test/
    │   ├── speed_tap/
    │   ├── stack_tower/
    │   ├── ball_dodge/
    │   ├── memory_match/
    │   ├── built_in_games.dart    # ★ the single registration point
    │   └── game_host_page.dart    # game-agnostic host
    ├── progression/               # ProgressionService (turns results into rewards)
    ├── profile/  achievements/  challenges/  daily_rewards/
    ├── statistics/  leaderboard/  shop/  settings/
    ├── home/  games_list/         # primary screens
    └── navigation/                # bottom-nav RootShell
```

### Layer responsibilities

- **models** — immutable, `Equatable`, JSON-serialisable (no generated Hive
  adapters, so the same maps drop straight into Firestore later).
- **repositories** — the only code that talks to Hive / the backend.
- **Riverpod notifiers** — reactive state, one per domain (`profileProvider`,
  `statsProvider`, `challengesProvider`, …).
- **ProgressionService** — the single orchestrator that converts a
  `GameResult` into XP, coins, stat updates, challenge progress, achievement
  unlocks and a leaderboard submission. Games know nothing about rewards.

---

## 🧩 The extensible game framework

Every game implements `MiniGame` (`lib/features/game_framework/mini_game.dart`):

```dart
abstract class MiniGame {
  String get id;                 // stable, unique, snake_case
  String get name;
  String get description;
  IconData get icon;
  Color get accentColor;
  GameDifficulty get difficulty;
  bool get higherIsBetter => true;        // Reaction Test overrides to false
  String get scoreUnit => 'pts';
  String formatScore(int score) => '$score $scoreUnit';

  Widget build(BuildContext context, GameController controller);
}
```

A game reports its outcome exactly once via the injected `GameController`:

```dart
controller.submit(GameResult(
  gameId: id, score: 284, won: true, durationSeconds: 1,
));
```

### Adding a new game (the entire process)

1. Create `features/games/my_game/my_game.dart` implementing `MiniGame`.
2. Add one line to `registerBuiltInGames` in
   `features/games/built_in_games.dart`:

```dart
registry.registerAll(<MiniGame>[
  ReactionTestGame(),
  SpeedTapGame(),
  StackTowerGame(),
  BallDodgeGame(),
  MemoryMatchGame(),
  MyGame(),            // 👈 that's it
]);
```

The new game now appears in the **games grid**, gets **statistics**, can be
targeted by **daily challenges**, contributes to **achievements** and has a
**leaderboard** — with zero changes to any of those systems, because each one
iterates the `GameRegistry` rather than a hard-coded list.

---

## 🎮 The games

| Game | Goal | Score | Win condition |
|------|------|-------|---------------|
| **Reaction Test** | Tap when the screen turns green | milliseconds (lower better) | always |
| **Speed Tap** | Most taps in 10s | taps | always |
| **Stack Tower** | Drop blocks accurately, endless | blocks stacked | ≥ 10 blocks |
| **Ball Dodge** | Dodge falling balls, ramping speed | obstacles dodged | survive ≥ 30s |
| **Memory Match** | Match all pairs (Easy/Medium/Hard) | time + efficiency | all matched |

---

## 💰 Progression & economy tuning

All balancing values live in `core/constants/app_constants.dart`:

- **XP curve** — `xpForLevel(n) = baseXpPerLevel * growthFactorⁿ⁻¹`
  (easy early levels, steeper later). See `core/utils/xp_calculator.dart`.
- **Rewards** — XP/coins for play, win, new high score, daily login.
- **Daily rewards** — `[50, 75, 100, 150, 200, 300, 500]` (day 7 special).

---

## 📺 Monetization (AdMob + IAP)

- **Banner ads** — Home & Games screens only, via `BannerAdWidget`. Collapse to
  nothing when `Remove Ads` is owned. Never shown during gameplay.
- **Rewarded ads** — "Double rewards" on the results screen, through
  `AdService.showRewarded()`.
- **Remove Ads** — one-time non-consumable behind the modular `PurchaseService`
  interface (mock implementation ships; swap in `in_app_purchase` for release).

> Debug builds automatically use Google's **test** ad unit ids. Replace the
> production ids in `core/constants/ad_constants.dart`, plus the AdMob App IDs
> in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`,
> before publishing.

---

## ☁️ Backend-ready (Firebase)

The app depends only on the `FirebaseService` abstraction
(`core/services/firebase_service.dart`). `MockFirebaseService` generates
believable leaderboard data offline. To go live, implement a Firestore-backed
`FirebaseService` and swap it in `core/di/providers.dart` — no UI changes.
Models are already JSON-shaped to match Firestore documents.

---

## 🚀 Build & run

See **[BUILD.md](BUILD.md)** for full, step-by-step instructions. Quick start:

```bash
# 1. Generate the native scaffolding this repo doesn't commit (gradle wrapper,
#    launcher icons, iOS Runner project). This will NOT overwrite lib/ or the
#    customised AndroidManifest / Info.plist already in the repo.
flutter create .

# 2. Fetch packages
flutter pub get

# 3. Run on a connected device / emulator
flutter run

# 4. Release build (Android)
flutter build apk --release        # or: flutter build appbundle --release
```

Requirements: Flutter ≥ 3.29, Dart ≥ 3.7, Android SDK (minSdk 23).

---

## 🧪 Tests

```bash
flutter test
```

Includes unit tests for the XP curve and the game registry.

---

## 📦 Tech stack

`flutter_riverpod` · `hive` / `hive_flutter` · `go_router` ·
`google_mobile_ads` · `in_app_purchase` · `equatable` · `uuid` · `intl`

---

## 🗺️ Roadmap

- Real Firestore backend + Firebase Auth
- Cloud save / cross-device sync
- Theme shop (coins already support it)
- More games (just implement `MiniGame`!)
