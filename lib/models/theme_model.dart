class ThemeIcon {
  final String id;
  final String name;
  final String iconUrl;

  ThemeIcon({
    required this.id,
    required this.name,
    required this.iconUrl,
  });
}

class ThemeModel {
  final String id;
  final String title;
  final String previewImageUrl;
  final int iconCount;
  final bool isPremium;
  final List<ThemeIcon> icons;

  ThemeModel({
    required this.id,
    required this.title,
    required this.previewImageUrl,
    required this.iconCount,
    required this.isPremium,
    List<ThemeIcon>? icons,
  }) : icons = icons ?? _generateDefaultIcons(iconCount);

  // Varsayılan simgeler oluştur
  static List<ThemeIcon> _generateDefaultIcons(int count) {
    return List.generate(
      count,
      (index) => ThemeIcon(
        id: 'icon_${index + 1}',
        name: 'İkon ${index + 1}',
        iconUrl: 'https://picsum.photos/id/${100 + index}/100/100',
      ),
    );
  }
}
