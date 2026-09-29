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
}
