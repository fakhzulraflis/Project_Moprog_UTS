// Satu karakter yang bisa dipilih sebagai foto profil.
// Kunci harus sama dengan ProfileController::AVATARS di backend.
class AvatarCharacter {
  final String key;
  final String name;
  final String description;
  final String asset;
  final bool special;

  const AvatarCharacter({
    required this.key,
    required this.name,
    required this.description,
    required this.asset,
    this.special = false,
  });
}

class AvatarCatalog {
  AvatarCatalog._();

  static const List<AvatarCharacter> all = [
    AvatarCharacter(
      key: 'engduck',
      name: 'Sir Qua',
      description: 'Qua si gentleman Inggris',
      asset: 'assets/avatar/engduck.png',
    ),
    AvatarCharacter(
      key: 'japduck',
      name: 'Qua-san',
      description: 'Qua dengan haori Jepang',
      asset: 'assets/avatar/japduck.png',
    ),
    AvatarCharacter(
      key: 'korduck',
      name: 'Qua-ssi',
      description: 'Qua dengan hanbok Korea',
      asset: 'assets/avatar/korduck.png',
    ),
    AvatarCharacter(
      key: 'qua_chef',
      name: 'Chef Qua',
      description: 'Qua si koki handal',
      asset: 'assets/avatar/qua_chef.png',
    ),
    AvatarCharacter(
      key: 'qua_scholar',
      name: 'Scholar Qua',
      description: 'Qua baru lulus wisuda',
      asset: 'assets/avatar/qua_scholar.png',
    ),
    AvatarCharacter(
      key: 'binbin_cardigan',
      name: 'Binbin · Cardigan',
      description: 'Binbin si kelinci, cardigan cream',
      asset: 'assets/avatar/binbin_cardigan.png',
      special: true,
    ),
    AvatarCharacter(
      key: 'binbin_florist',
      name: 'Binbin · Florist',
      description: 'Binbin bermimpi menjadi florist',
      asset: 'assets/avatar/binbin_florist.png',
      special: true,
    ),
    AvatarCharacter(
      key: 'binbin_winter',
      name: 'Binbin · Winter',
      description: 'Binbin dengan mantel dan syal',
      asset: 'assets/avatar/binbin_winter.png',
      special: true,
    ),
  ];

  static AvatarCharacter? byKey(String? key) {
    for (final a in all) {
      if (a.key == key) return a;
    }
    return null;
  }

  // Karakter bawaan tiap bahasa belajar (dipakai kalau user belum memilih).
  static AvatarCharacter forLanguage(String? language) {
    switch (language?.toLowerCase()) {
      case 'japanese':
      case 'jepang':
        return byKey('japduck')!;
      case 'korean':
      case 'korea':
        return byKey('korduck')!;
      default:
        return byKey('engduck')!;
    }
  }

  // Karakter pilihan user, kalau belum memilih ikut bahasa belajar.
  static AvatarCharacter resolve({String? character, String? language}) =>
      byKey(character) ?? forLanguage(language);
}
