import 'package:carnet_connecte/core/errors/app_exception.dart';
import 'package:carnet_connecte/data/local/content_cache.dart';
import 'package:carnet_connecte/data/remote/supabase_content_api.dart';
import 'package:carnet_connecte/data/repositories/content_repository_impl.dart';
import 'package:carnet_connecte/domain/entities/content_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const section = ContentSection.articles;
  const onlineItem = ContentItem(
    id: 'article-1',
    title: 'En ligne',
    description: 'Contenu récupéré depuis le backend.',
    label: 'Lecture',
  );
  const cachedItem = ContentItem(
    id: 'article-2',
    title: 'En cache',
    description: 'Contenu déjà enregistré sur le téléphone.',
    label: 'Offline',
  );

  late _FakeRemoteDataSource remote;
  late _FakeContentCache cache;
  late ContentRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemoteDataSource();
    cache = _FakeContentCache();
    repository = ContentRepositoryImpl(remote: remote, cache: cache);
  });

  test('returns remote data and writes it to the local cache', () async {
    remote.result = [onlineItem];

    final result = await repository.load(section);

    expect(result.items, [onlineItem]);
    expect(result.isOffline, isFalse);
    expect(cache.values[section], [onlineItem]);
  });

  test('returns cached data when the network is unavailable', () async {
    remote.error = DioException(
      requestOptions: RequestOptions(path: '/articles'),
      type: DioExceptionType.connectionError,
    );
    cache.values[section] = [cachedItem];

    final result = await repository.load(section);

    expect(result.items, [cachedItem]);
    expect(result.isOffline, isTrue);
  });

  test('returns a user-readable error when no cache is available offline',
      () async {
    remote.error = DioException(
      requestOptions: RequestOptions(path: '/articles'),
      type: DioExceptionType.connectionError,
    );

    await expectLater(
      repository.load(section),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('Vérifiez votre réseau'),
        ),
      ),
    );
  });

  test('does not hide local cache failures', () async {
    remote.error = DioException(
      requestOptions: RequestOptions(path: '/articles'),
      type: DioExceptionType.connectionError,
    );
    cache.readError = StateError('SQLite unavailable');

    await expectLater(repository.load(section), throwsStateError);
  });
}

class _FakeRemoteDataSource implements ContentRemoteDataSource {
  List<ContentItem> result = [];
  DioException? error;

  @override
  Future<List<ContentItem>> fetch(ContentSection section) async {
    if (error case final exception?) throw exception;
    return result;
  }
}

class _FakeContentCache implements ContentCache {
  final values = <ContentSection, List<ContentItem>>{};
  Object? readError;

  @override
  Future<List<ContentItem>> read(ContentSection section) async {
    if (readError case final exception?) throw exception;
    return values[section] ?? [];
  }

  @override
  Future<void> write(
    ContentSection section,
    List<ContentItem> items,
  ) async {
    values[section] = items;
  }
}
