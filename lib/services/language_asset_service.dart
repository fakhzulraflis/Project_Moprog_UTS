class LanguageAssetService {
  static String avatarFor(String? language) {
    switch (language?.toLowerCase()) {
      case 'english':
        return 'assets/app/english.gif';
      case 'japanese':
        return 'assets/app/japanese.gif';
      case 'korean':
        return 'assets/app/korean.gif';
      default:
        return 'assets/app/wavingduck.gif';
    }
  }

  // Foto (gambar diam) karakter untuk halaman profil.
  static String profileAvatarFor(String? language) {
    switch (language?.toLowerCase()) {
      case 'japanese':
      case 'jepang':
        return 'assets/avatar/japduck.png';
      case 'korean':
      case 'korea':
        return 'assets/avatar/korduck.png';
      default:
        return 'assets/avatar/engduck.png';
    }
  }

  static String flagFor(String? language) {
    switch (language?.toLowerCase()) {
      case 'japanese':
      case 'jepang':
        return 'assets/flags/japan.png';
      case 'korean':
      case 'korea':
        return 'assets/flags/korea.png';
      default:
        return 'assets/flags/inggris.png';
    }
  }
}
