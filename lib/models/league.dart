import 'package:flutter/material.dart';

class League {
  final int tier;
  final String name;
  final Color color;
  final String iconAsset;
  final int promotionZoneSize;
  final int demotionZoneSize;

  const League({
    required this.tier,
    required this.name,
    required this.color,
    required this.iconAsset,
    required this.promotionZoneSize,
    required this.demotionZoneSize,
  });

  static const bronze = League(
    tier: 0,
    name: 'Bronze League',
    color: Color(0xFFCD7F32),
    iconAsset: 'assets/icons/bronze.png',
    promotionZoneSize: 10,
    demotionZoneSize: 0,
  );

  static const silver = League(
    tier: 1,
    name: 'Silver League',
    color: Color(0xFFC0C8D0),
    iconAsset: 'assets/icons/silver.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );

  static const gold = League(
    tier: 2,
    name: 'Gold League',
    color: Color(0xFFFFC800),
    iconAsset: 'assets/icons/gold.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );

  static const sapphire = League(
    tier: 3,
    name: 'Sapphire League',
    color: Color(0xFF1CB0F6),
    iconAsset: 'assets/icons/sapphire.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );

  static const ruby = League(
    tier: 4,
    name: 'Ruby League',
    color: Color(0xFFFF4B4B),
    iconAsset: 'assets/icons/ruby.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );

  static const emerald = League(
    tier: 5,
    name: 'Emerald League',
    color: Color(0xFF58CC02),
    iconAsset: 'assets/icons/emerald.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );

  static const amethyst = League(
    tier: 6,
    name: 'Amethyst League',
    color: Color(0xFFCE82FF),
    iconAsset: 'assets/icons/amethyst.png',
    promotionZoneSize: 0,
    demotionZoneSize: 5,
  );

  static const List<League> all = [
    bronze,
    silver,
    gold,
    sapphire,
    ruby,
    emerald,
    amethyst,
  ];

  static League byTier(int tier) => all[tier.clamp(0, all.length - 1)];

  /// The league one tier up, or null if this is already the highest.
  League? get nextLeague => tier < all.length - 1 ? all[tier + 1] : null;

  /// The league one tier down, or null if this is already the lowest.
  League? get previousLeague => tier > 0 ? all[tier - 1] : null;
}
