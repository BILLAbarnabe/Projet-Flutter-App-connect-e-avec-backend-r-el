import '../entities/content_item.dart';

abstract interface class ContentRepository {
  Future<ContentPage> load(ContentSection section);
}
