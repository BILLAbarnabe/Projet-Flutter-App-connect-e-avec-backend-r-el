import 'package:dio/dio.dart';

import '../../domain/entities/content_item.dart';

abstract interface class ContentRemoteDataSource {
  Future<List<ContentItem>> fetch(ContentSection section);
}

class SupabaseContentApi implements ContentRemoteDataSource {
  SupabaseContentApi(this._dio);

  final Dio _dio;

  @override
  Future<List<ContentItem>> fetch(ContentSection section) async {
    final response = await _dio.get<List<dynamic>>(
      section.tableName,
      queryParameters: {'select': 'id,title,description,label'},
    );
    return (response.data ?? const [])
        .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
