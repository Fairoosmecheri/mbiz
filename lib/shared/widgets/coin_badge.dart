import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Small pill showing a coin icon + amount. Used in app bars and headers.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.coins, this.onTap});

  final int coins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.coin.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.monetization_on_rounded,
                color: AppColors.coin, size: 18),
            const SizedBox(width: 6),
            Text(
              '$coins',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.coin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
