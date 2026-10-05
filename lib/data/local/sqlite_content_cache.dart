import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/content_item.dart';
import 'content_cache.dart';

class SqliteContentCache implements ContentCache {
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      path.join(databasePath, 'carnet_connecte.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_content (
            section TEXT NOT NULL,
            id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            label TEXT NOT NULL,
            PRIMARY KEY (section, id)
          )
        ''');
      },
    );
  }

  @override
  Future<List<ContentItem>> read(ContentSection section) async {
    final rows = await (await database).query(
      'cached_content',
      where: 'section = ?',
      whereArgs: [section.tableName],
      orderBy: 'title COLLATE NOCASE',
    );
    return rows
        .map((row) => ContentItem.fromJson(row))
        .toList(growable: false);
  }

  @override
  Future<void> write(ContentSection section, List<ContentItem> items) async {
    final db = await database;
    await db.transaction((transaction) async {
      await transaction.delete(
        'cached_content',
        where: 'section = ?',
        whereArgs: [section.tableName],
      );
      for (final item in items) {
        await transaction.insert('cached_content', {
          'section': section.tableName,
          ...item.toJson(),
        });
      }
    });
  }
}
