class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.label,
  });

  final String id;
  final String title;
  final String description;
  final String label;

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        label: json['label'] as String,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'label': label,
      };
}

enum ContentSection {
  articles('articles', 'Articles', 'Des idées à découvrir', 'article'),
  books('books', 'Livres', 'Dans votre bibliothèque', 'livre'),
  tasks('tasks', 'Tâches', 'À garder en tête', 'tâche');

  const ContentSection(this.tableName, this.title, this.subtitle, this.singular);

  final String tableName;
  final String title;
  final String subtitle;
  final String singular;
}

class ContentPage {
  const ContentPage({required this.items, required this.isOffline});

  final List<ContentItem> items;
  final bool isOffline;
}
