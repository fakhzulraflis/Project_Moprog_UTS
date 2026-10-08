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
