import '../../domain/entities/content_item.dart';

abstract interface class ContentCache {
  Future<List<ContentItem>> read(ContentSection section);
  Future<void> write(ContentSection section, List<ContentItem> items);
}
