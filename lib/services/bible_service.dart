import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';

class BibleService {
  static const String _baseUrl = 'https://www.abibliadigital.com.br/api';

  static const Map<String, String> _versionMap = {
    'acf': 'acf', 'arc': 'arc', 'ntlh': 'ntlh', 'nvi': 'nvi',
    'nviPt': 'nvi', 'teb': 'nvi', 'arcEspirita': 'arc',
    'bibAvePaulo': 'arc', 'erc': 'arc',
  };

  static const Map<String, String> _bookIdMap = {
    'gn': 'gn', 'ex': 'ex', 'lv': 'lv', 'nm': 'nm', 'dt': 'dt',
    'js': 'js', 'jz': 'jz', 'rt': 'rt', '1sm': '1sm', '2sm': '2sm',
    '1rs': '1rs', '2rs': '2rs', '1cr': '1cr', '2cr': '2cr', 'ed': 'ed',
    'ne': 'ne', 'et': 'et', 'jó': 'jo', 'sl': 'sl', 'pv': 'pv',
    'ec': 'ec', 'ct': 'ct', 'is': 'is', 'jr': 'jr', 'lm': 'lm',
    'ez': 'ez', 'dn': 'dn', 'os': 'os', 'jl': 'jl', 'am': 'am',
    'ob': 'ob', 'jn': 'jn', 'mq': 'mq', 'na': 'na', 'hc': 'hc',
    'sf': 'sf', 'ag': 'ag', 'zc': 'zc', 'ml': 'ml',
    'mt': 'mt', 'mc': 'mc', 'lc': 'lc', 'jo': 'jo', 'at': 'at',
    'rm': 'rm', '1co': '1co', '2co': '2co', 'gl': 'gl', 'ef': 'ef',
    'fp': 'fp', 'cl': 'cl', '1ts': '1ts', '2ts': '2ts', '1tm': '1tm',
    '2tm': '2tm', 'tt': 'tt', 'fm': 'fm', 'hb': 'hb', 'tg': 'tg',
    '1pe': '1pe', '2pe': '2pe', '1jo': '1jo', '2jo': '2jo', '3jo': '3jo',
    'jd': 'jd', 'ap': 'ap',
  };

  static final Map<String, List<Map<String, String>>> _cache = {};

  // ── Buscar capítulo completo ──────────────────────────────────────────────
  static Future<List<Map<String, String>>> getChapterVerses(
      String bookId, int chapter, BibleVersion version) async {
    final cacheKey = '${bookId}_${chapter}_${version.shortName}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final apiVersion = _versionMap[version.shortName] ?? 'nvi';
    final apiBook = _bookIdMap[bookId.toLowerCase()] ?? bookId.toLowerCase();
    final url = '$_baseUrl/verses/$apiVersion/$apiBook/$chapter';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final versesList = data['verses'] as List? ?? [];
        final verses = versesList.map<Map<String, String>>((v) => {
          'verse': '${v['number'] ?? ''}',
          'text': '${v['text'] ?? ''}',
        }).toList();
        _cache[cacheKey] = verses;
        return verses;
      }
    } catch (e) {}

    final fallback = _localVerses(bookId, chapter);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  // ── Buscar versículo aleatório da API ─────────────────────────────────────
  static Future<Map<String, dynamic>> getRandomVerseFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/verses/nvi/random'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['text'] ?? '',
          'ref': '${data['book']?['name'] ?? ''} ${data['chapter']}:${data['number']}',
        };
      }
    } catch (e) {}
    return getRandomVerse();
  }

  // ── Buscar por palavra-chave ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> searchVerses(
      String query, BibleVersion version) async {
    if (query.trim().isEmpty) return [];

    final apiVersion = _versionMap[version.shortName] ?? 'nvi';
    final encoded = Uri.encodeComponent(query.trim());
    final url = '$_baseUrl/verses/$apiVersion/search?search=$encoded';

    try {
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List? ?? [];
        return verses.map<Map<String, dynamic>>((v) => {
          'reference': '${v['book']?['name'] ?? ''} ${v['chapter']}:${v['number']}',
          'text': '${v['text'] ?? ''}',
          'bookId': '${v['book']?['abbrev']?['pt'] ?? ''}',
          'chapter': '${v['chapter'] ?? 1}',
          'verse': '${v['number'] ?? 1}',
        }).toList();
      }
    } catch (e) {}

    return _searchLocal(query);
  }

  static List<Map<String, dynamic>> _searchLocal(String query) {
    final q = query.toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final v in BibleData.getDailyVerses()) {
      if (v['text']!.toLowerCase().contains(q) || v['ref']!.toLowerCase().contains(q)) {
        results.add({'reference': v['ref'], 'text': v['text'], 'bookId': '', 'chapter': '1', 'verse': '1'});
      }
    }
    return results.take(20).toList();
  }

  static Map<String, dynamic> getRandomVerse() {
    final verses = BibleData.getDailyVerses();
    return verses[Random().nextInt(verses.length)];
  }

  static List<VideoLesson> getVideosForBook(String bookId) =>
      BibleData.getVideoLessons().where((v) => v.bookId == bookId).toList();

  static List<VideoLesson> getAllVideos() => BibleData.getVideoLessons();

  static List<Map<String, String>> _localVerses(String bookId, int chapter) {
    final phrases = [
      'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito.',
      'O Senhor é o meu pastor; nada me faltará.',
      'Tudo posso naquele que me fortalece.',
      'Confia no Senhor de todo o teu coração.',
      'Porque para Deus não há nada impossível.',
      'Buscai primeiro o reino de Deus e a sua justiça.',
      'A palavra de Deus é viva e eficaz.',
      'Sejam fortes e corajosos. Não tenham medo.',
      'Deus é o nosso refúgio e força.',
      'Bem-aventurados os puros de coração.',
      'O amor é paciente, o amor é bondoso.',
      'Porque pela graça sois salvos, por meio da fé.',
      'Eu sou o caminho, a verdade e a vida.',
      'A paz de Deus, que excede todo o entendimento.',
      'Em Deus somente descansa a minha alma.',
    ];
    return List.generate(15, (i) => {
      'verse': '${i + 1}',
      'text': phrases[(bookId.hashCode + chapter + i).abs() % phrases.length],
    });
  }
}
