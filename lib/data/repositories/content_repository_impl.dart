import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/repositories/content_repository.dart';
import '../local/content_cache.dart';
import '../remote/supabase_content_api.dart';

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl({required this.remote, required this.cache});

  final ContentRemoteDataSource remote;
  final ContentCache cache;

  @override
  Future<ContentPage> load(ContentSection section) async {
    try {
      final items = await remote.fetch(section);
      await cache.write(section, items);
      return ContentPage(items: items, isOffline: false);
    } on DioException catch (error) {
      final cachedItems = await cache.read(section);
      if (cachedItems.isNotEmpty) {
        return ContentPage(items: cachedItems, isOffline: true);
      }
      throw AppException(_messageFor(error));
    }
  }

  String _messageFor(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Connexion impossible. Vérifiez votre réseau et réessayez.';
    }
    if (error.response?.statusCode == 401 ||
        error.response?.statusCode == 403) {
      return 'Votre session a expiré. Reconnectez-vous pour continuer.';
    }
    return 'Les données ne sont pas disponibles pour le moment. Réessayez.';
  }
}
