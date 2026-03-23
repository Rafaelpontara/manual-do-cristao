import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static Database? _db;

  // ── Inicializar banco ─────────────────────────────────────────────────────
  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'bible_offline.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE verses (
            id TEXT PRIMARY KEY,
            book_id TEXT NOT NULL,
            chapter INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            text TEXT NOT NULL,
            version TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_chapter ON verses(book_id, chapter, version)');
      },
    );
    return _db!;
  }

  // ── Salvar capítulo ───────────────────────────────────────────────────────
  static Future<void> saveChapter(
      String bookId, int chapter, String version, List<Map<String, String>> verses) async {
    final database = await db;
    final batch = database.batch();
    for (final v in verses) {
      final id = '${version}_${bookId}_${chapter}_${v['verse']}';
      batch.insert('verses', {
        'id': id,
        'book_id': bookId,
        'chapter': chapter,
        'verse_number': int.tryParse(v['verse'] ?? '0') ?? 0,
        'text': v['text'] ?? '',
        'version': version,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);

    // Marcar como baixado
    final prefs = await SharedPreferences.getInstance();
    final key = 'offline_${version}_${bookId}_$chapter';
    await prefs.setBool(key, true);
  }

  // ── Buscar capítulo salvo ─────────────────────────────────────────────────
  static Future<List<Map<String, String>>?> getChapter(
      String bookId, int chapter, String version) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offline_${version}_${bookId}_$chapter';
    if (!(prefs.getBool(key) ?? false)) return null;

    final database = await db;
    final rows = await database.query(
      'verses',
      where: 'book_id = ? AND chapter = ? AND version = ?',
      whereArgs: [bookId, chapter, version],
      orderBy: 'verse_number ASC',
    );

    if (rows.isEmpty) return null;
    return rows.map((r) => {
      'verse': '${r['verse_number']}',
      'text': r['text'] as String,
    }).toList();
  }

  // ── Verificar se capítulo está salvo ──────────────────────────────────────
  static Future<bool> isChapterDownloaded(String bookId, int chapter, String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('offline_${version}_${bookId}_$chapter') ?? false;
  }

  // ── Verificar se a Bíblia completa está baixada ───────────────────────────
  static Future<bool> isFullBibleDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('bible_downloaded') ?? false;
  }

  // ── Contar versículos salvos ──────────────────────────────────────────────
  static Future<int> getCachedVerseCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM verses');
    return (result.first['count'] as int?) ?? 0;
  }

  // ── Limpar cache ──────────────────────────────────────────────────────────
  static Future<void> clearCache() async {
    final database = await db;
    await database.delete('verses');
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('offline_')).toList();
    for (final key in keys) await prefs.remove(key);
    await prefs.setBool('bible_downloaded', false);
  }
}
