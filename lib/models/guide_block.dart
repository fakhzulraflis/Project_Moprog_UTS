class GuideItem {
  final String text;
  final String? romanization;
  final String meaning;

  const GuideItem({
    required this.text,
    this.romanization,
    required this.meaning,
  });

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    return GuideItem(
      text: json['text']?.toString() ?? '',
      romanization: json['romanization']?.toString(),
      meaning: json['meaning']?.toString() ?? '',
    );
  }
}

class GuideBlock {
  final String title;
  final String? body;
  final List<GuideItem> items;

  const GuideBlock({required this.title, this.body, this.items = const []});

  factory GuideBlock.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return GuideBlock(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => GuideItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
    );
  }
}
