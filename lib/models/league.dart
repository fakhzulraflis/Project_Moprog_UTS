/// Metadata about a single league tier (Bronze, Silver, Gold, ...).
///
/// Only "Silver" exists visually for now (assets/icons/silver.png), but the
/// shape is ready for more tiers once their badge assets are added.
class League {
  final String name;
  final String iconAsset;
  final int promotionZoneSize; // top N users promote to the next league
  final int demotionZoneSize; // bottom N users demote to the previous league

  const League({
    required this.name,
    required this.iconAsset,
    required this.promotionZoneSize,
    required this.demotionZoneSize,
  });

  static const silver = League(
    name: 'Silver League',
    iconAsset: 'assets/icons/silver.png',
    promotionZoneSize: 10,
    demotionZoneSize: 5,
  );
}
