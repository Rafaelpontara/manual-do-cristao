import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bible_models.dart';

class BibleService {
  // Using ABíblia.digital API (free, Brazilian Portuguese)
  static const String _baseUrl = 'https://www.abibliadigital.com.br/api';
  static const String _token = ''; // Add token for production

  static final Map<String, Map<int, List<Map<String, String>>>> _cache = {};

  // Simulated content for demo (replace with real API calls)
  static Future<List<Map<String, String>>> getChapterVerses(
      String bookId, int chapter, BibleVersion version) async {
    final cacheKey = '${bookId}_${chapter}_${version.shortName}';

    if (_cache[cacheKey] != null) {
      return _cache[cacheKey]!.values.first;
    }

    // Simulated verses - in production use real API
    final verses = _generateSampleVerses(bookId, chapter);
    _cache[cacheKey] = {chapter: verses};
    return verses;
  }

  static List<Map<String, String>> _generateSampleVerses(String bookId, int chapter) {
    // Sample data for the most important books
    final sampleData = <String, Map<int, List<Map<String, String>>>>{
      'jo': {
        3: [
          {'verse': '1', 'text': 'Havia entre os fariseus um homem chamado Nicodemos, membro do Conselho dos judeus.'},
          {'verse': '2', 'text': 'Este foi de noite procurar Jesus e lhe disse: "Mestre, sabemos que és um mestre que veio da parte de Deus, pois ninguém pode fazer sinais miraculosos como os que tu fazes, se Deus não estiver com ele."'},
          {'verse': '3', 'text': 'Jesus lhe respondeu: "Eu te afirmo que ninguém pode ver o Reino de Deus se não nascer de novo."'},
          {'verse': '4', 'text': 'Nicodemos perguntou: "Como pode um homem nascer depois de já ser velho? Certamente não pode entrar uma segunda vez no ventre de sua mãe para nascer!"'},
          {'verse': '5', 'text': 'Jesus respondeu: "Eu te afirmo que ninguém pode entrar no Reino de Deus se não nascer da água e do Espírito."'},
          {'verse': '16', 'text': 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.'},
          {'verse': '17', 'text': 'Porque Deus não enviou o seu Filho ao mundo para condenar o mundo, mas para que o mundo seja salvo por meio dele.'},
        ],
      },
      'gn': {
        1: [
          {'verse': '1', 'text': 'No princípio, Deus criou os céus e a terra.'},
          {'verse': '2', 'text': 'Era a terra sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus se movia sobre a face das águas.'},
          {'verse': '3', 'text': 'Disse Deus: Haja luz; e houve luz.'},
          {'verse': '4', 'text': 'E viu Deus que a luz era boa; e fez separação entre a luz e as trevas.'},
          {'verse': '5', 'text': 'E Deus chamou à luz Dia; e às trevas chamou Noite. E foi a tarde e a manhã, o dia primeiro.'},
          {'verse': '26', 'text': 'E disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; tenha ele domínio sobre os peixes do mar, sobre as aves dos céus, sobre os animais domésticos, sobre toda a terra...'},
          {'verse': '27', 'text': 'Criou Deus, pois, o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou.'},
        ],
      },
      'sl': {
        23: [
          {'verse': '1', 'text': 'O Senhor é o meu pastor; nada me faltará.'},
          {'verse': '2', 'text': 'Ele me faz repousar em verdes pastagens; guia-me mansamente a águas tranquilas.'},
          {'verse': '3', 'text': 'Refrigera a minha alma; guia-me pelas veredas da justiça, por amor do seu nome.'},
          {'verse': '4', 'text': 'Ainda que eu andasse pelo vale da sombra da morte, não temeria mal nenhum, porque tu estás comigo; o teu bordão e o teu cajado me consolam.'},
          {'verse': '5', 'text': 'Preparas uma mesa perante mim na presença dos meus adversários; unges a minha cabeça com óleo; o meu cálice transborda.'},
          {'verse': '6', 'text': 'Certamente que a bondade e a misericórdia me seguirão todos os dias da minha vida; e habitarei na casa do Senhor por longos dias.'},
        ],
      },
    };

    if (sampleData.containsKey(bookId) && sampleData[bookId]!.containsKey(chapter)) {
      return sampleData[bookId]![chapter]!;
    }

    // Generate placeholder verses for chapters without specific data
    return List.generate(
      min(30, 10 + Random().nextInt(20)),
      (i) => {
        'verse': '${i + 1}',
        'text': _getPlaceholderVerse(bookId, chapter, i + 1),
      },
    );
  }

  static String _getPlaceholderVerse(String bookId, int chapter, int verse) {
    final placeholders = [
      'E disse o Senhor: Eu sou o caminho, a verdade e a vida; ninguém vem ao Pai senão por mim.',
      'Porque a Palavra de Deus é viva e eficaz, e mais cortante do que qualquer espada de dois gumes.',
      'Tudo posso naquele que me fortalece.',
      'Bem-aventurado o homem que não anda no conselho dos ímpios, nem pára no caminho dos pecadores, nem se assenta na roda dos escarnecedores.',
      'O nome do Senhor é uma torre forte; para ela corre o justo e está seguro.',
      'Confia no Senhor de todo o teu coração, e não te estribes no teu próprio entendimento.',
      'E conhecereis a verdade, e a verdade vos libertará.',
      'Porque o Senhor teu Deus é um Deus misericordioso; não te deixará, nem te destruirá.',
      'Porque para Deus não há nada impossível.',
      'Sejam fortes e corajosos. Não tenham medo nem fiquem apavorados por causa deles, pois o Senhor seu Deus vai com vocês.',
    ];
    return placeholders[(bookId.hashCode + chapter + verse) % placeholders.length];
  }

  static Map<String, dynamic> getRandomVerse() {
    final verses = BibleData.getDailyVerses();
    return verses[Random().nextInt(verses.length)];
  }

  static List<VideoLesson> getVideosForBook(String bookId) {
    return BibleData.getVideoLessons()
        .where((v) => v.bookId == bookId)
        .toList();
  }

  static List<VideoLesson> getAllVideos() {
    return BibleData.getVideoLessons();
  }
}
