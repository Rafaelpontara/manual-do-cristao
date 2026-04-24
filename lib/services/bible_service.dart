import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';

class BibleService {
  // ── APIs em ordem de prioridade ──────────────────────────────────────────
  // 1. abibliadigital.com.br  — PT-BR, gratuita com registro
  // 2. bolls.life              — sem token, cobertura global
  // 3. bible-api.com           — sem token, suporta 'almeida'

  static const String _abibliaBase = 'https://www.abibliadigital.com.br/api';

  // ⚠️  AÇÃO NECESSÁRIA: cadastre-se gratuitamente em abibliadigital.com.br
  // e cole seu token abaixo. Sem token a API retorna 403.
  // Deixe vazio ('') para usar apenas as APIs de fallback.
  static const String _abibliaToken = '';

  static const Map<String, String> _versionMap = {
    'acf': 'acf', 'arc': 'arc', 'ntlh': 'ntlh', 'nvi': 'nvi',
    'nviPt': 'nvi', 'teb': 'nvi', 'arcEspirita': 'arc',
    'bibAvePaulo': 'arc', 'erc': 'arc',
  };

  // Mapeamento bookId do app → abreviação aceita pelas APIs
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
    'jd': 'jd', 'jd2': 'jd', 'ap': 'ap',
  };

  // Mapeamento bookId → número para a API bolls.life
  static const Map<String, int> _bollsBookMap = {
    'gn': 1, 'ex': 2, 'lv': 3, 'nm': 4, 'dt': 5,
    'js': 6, 'jz': 7, 'rt': 8, '1sm': 9, '2sm': 10,
    '1rs': 11, '2rs': 12, '1cr': 13, '2cr': 14, 'ed': 15,
    'ne': 16, 'et': 17, 'jó': 18, 'sl': 19, 'pv': 20,
    'ec': 21, 'ct': 22, 'is': 23, 'jr': 24, 'lm': 25,
    'ez': 26, 'dn': 27, 'os': 28, 'jl': 29, 'am': 30,
    'ob': 31, 'jn': 32, 'mq': 33, 'na': 34, 'hc': 35,
    'sf': 36, 'ag': 37, 'zc': 38, 'ml': 39,
    'mt': 40, 'mc': 41, 'lc': 42, 'jo': 43, 'at': 44,
    'rm': 45, '1co': 46, '2co': 47, 'gl': 48, 'ef': 49,
    'fp': 50, 'cl': 51, '1ts': 52, '2ts': 53, '1tm': 54,
    '2tm': 55, 'tt': 56, 'fm': 57, 'hb': 58, 'tg': 59,
    '1pe': 60, '2pe': 61, '1jo': 62, '2jo': 63, '3jo': 64,
    'jd': 65, 'jd2': 65, 'ap': 66,
  };

  // Mapeamento bookId → nome em inglês para bible-api.com
  static const Map<String, String> _bibleApiBookMap = {
    'gn': 'genesis', 'ex': 'exodus', 'lv': 'leviticus', 'nm': 'numbers',
    'dt': 'deuteronomy', 'js': 'joshua', 'jz': 'judges', 'rt': 'ruth',
    '1sm': '1+samuel', '2sm': '2+samuel', '1rs': '1+kings', '2rs': '2+kings',
    '1cr': '1+chronicles', '2cr': '2+chronicles', 'ed': 'ezra', 'ne': 'nehemiah',
    'et': 'esther', 'jó': 'job', 'sl': 'psalms', 'pv': 'proverbs',
    'ec': 'ecclesiastes', 'ct': 'song+of+songs', 'is': 'isaiah', 'jr': 'jeremiah',
    'lm': 'lamentations', 'ez': 'ezekiel', 'dn': 'daniel', 'os': 'hosea',
    'jl': 'joel', 'am': 'amos', 'ob': 'obadiah', 'jn': 'jonah', 'mq': 'micah',
    'na': 'nahum', 'hc': 'habakkuk', 'sf': 'zephaniah', 'ag': 'haggai',
    'zc': 'zechariah', 'ml': 'malachi',
    'mt': 'matthew', 'mc': 'mark', 'lc': 'luke', 'jo': 'john', 'at': 'acts',
    'rm': 'romans', '1co': '1+corinthians', '2co': '2+corinthians', 'gl': 'galatians',
    'ef': 'ephesians', 'fp': 'philippians', 'cl': 'colossians',
    '1ts': '1+thessalonians', '2ts': '2+thessalonians',
    '1tm': '1+timothy', '2tm': '2+timothy', 'tt': 'titus', 'fm': 'philemon',
    'hb': 'hebrews', 'tg': 'james', '1pe': '1+peter', '2pe': '2+peter',
    '1jo': '1+john', '2jo': '2+john', '3jo': '3+john',
    'jd': 'jude', 'jd2': 'jude', 'ap': 'revelation',
  };

  static final Map<String, List<Map<String, String>>> _cache = {};
  static final Map<String, List<Map<String, dynamic>>> _searchCache = {};

  // Cache do JSON local carregado uma vez
  static List<dynamic>? _localBible;
  static bool _localBibleLoaded = false;

  // Carrega o JSON da Bíblia do asset uma única vez
  static Future<List<dynamic>?> _loadLocalBible() async {
    if (_localBibleLoaded) return _localBible;
    _localBibleLoaded = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/bible/acf.json');
      _localBible = json.decode(jsonStr) as List<dynamic>;
    } catch (_) {
      _localBible = null; // asset não encontrado — usa API
    }
    return _localBible;
  }

  // Índice de abbrev → posição na lista para busca rápida
  static const Map<String, int> _bookIndex = {
    'gn':0,'ex':1,'lv':2,'nm':3,'dt':4,'js':5,'jz':6,'rt':7,
    '1sm':8,'2sm':9,'1rs':10,'2rs':11,'1cr':12,'2cr':13,'ed':14,
    'ne':15,'et':16,'jo':17,'sl':18,'pv':19,'ec':20,'ct':21,
    'is':22,'jr':23,'lm':24,'ez':25,'dn':26,'os':27,'jl':28,
    'am':29,'ob':30,'jn':31,'mq':32,'na':33,'hc':34,'sf':35,
    'ag':36,'zc':37,'ml':38,'mt':39,'mc':40,'lc':41,'jo2':42,
    'at':43,'rm':44,'1co':45,'2co':46,'gl':47,'ef':48,'fp':49,
    'cl':50,'1ts':51,'2ts':52,'1tm':53,'2tm':54,'tt':55,'fm':56,
    'hb':57,'tg':58,'1pe':59,'2pe':60,'1jo':61,'2jo':62,'3jo':63,
    'jd':64,'jd2':64,'ap':65,
    // aliases
    'jó':17,
  };

  // ── Buscar capítulo — cascata de APIs ────────────────────────────────────
  static Future<List<Map<String, String>>> getChapterVerses(
      String bookId, int chapter, BibleVersion version) async {

    final cacheKey = '${bookId}_${chapter}_${version.shortName}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final bookLower = bookId.toLowerCase();

    // 0️⃣ JSON local embarcado (offline — prioridade máxima)
    final localResult = await _fetchLocal(bookLower, chapter);
    if (localResult != null && localResult.isNotEmpty) {
      _cache[cacheKey] = localResult;
      return localResult;
    }

    // 1️⃣ bible-api.com — API principal atual (sem token, Almeida PT-BR ✅)
    final bibleApiResult = await _fetchBibleApi(bookLower, chapter);
    if (bibleApiResult != null && bibleApiResult.isNotEmpty) {
      _cache[cacheKey] = bibleApiResult;
      return bibleApiResult;
    }

    // 2️⃣ bolls.life — fallback (sem token)
    final bollsResult = await _fetchBolls(bookLower, chapter);
    if (bollsResult != null && bollsResult.isNotEmpty) {
      _cache[cacheKey] = bollsResult;
      return bollsResult;
    }

    // 3️⃣ abibliadigital.com.br — quando o servidor voltar
    final abibliaResult = await _fetchAbiblia(bookLower, chapter, version);
    if (abibliaResult != null && abibliaResult.isNotEmpty) {
      _cache[cacheKey] = abibliaResult;
      return abibliaResult;
    }

    // 4️⃣ Versículos embarcados (offline parcial)
    final fallback = _realLocalVerses(bookLower, chapter);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  // ── Asset local: assets/bible/acf.json ──────────────────────────────────
  static Future<List<Map<String, String>>?> _fetchLocal(
      String bookId, int chapter) async {
    try {
      final bible = await _loadLocalBible();
      if (bible == null) return null;

      // Resolve bookId para índice
      final normalizedId = bookId == 'jó' ? 'jo' :
                           bookId == 'jo' ? 'jo2' : bookId;
      int? bookIdx = _bookIndex[normalizedId] ?? _bookIndex[bookId];
      if (bookIdx == null) return null;
      if (bookIdx >= bible.length) return null;

      final bookData = bible[bookIdx];
      final chapters = bookData['chapters'] as List<dynamic>?;
      if (chapters == null || chapter < 1 || chapter > chapters.length) return null;

      final verseList = chapters[chapter - 1] as List<dynamic>;
      return verseList.asMap().entries.map((e) => {
        'verse': '${e.key + 1}',
        'text': '${e.value}',
      }).toList();
    } catch (_) {
      return null;
    }
  }

  // ── API 1: abibliadigital.com.br ─────────────────────────────────────────
  static Future<List<Map<String, String>>?> _fetchAbiblia(
      String bookId, int chapter, BibleVersion version) async {
    try {
      final apiVersion = _versionMap[version.shortName] ?? 'nvi';
      final apiBook = _bookIdMap[bookId] ?? bookId;
      final url = '$_abibliaBase/verses/$apiVersion/$apiBook/$chapter';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final versesList = data['verses'] as List? ?? [];
        if (versesList.isNotEmpty) {
          return versesList.map<Map<String, String>>((v) => {
            'verse': '${v['number'] ?? ''}',
            'text': '${v['text'] ?? ''}',
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  // ── API 2: bolls.life (sem token) ────────────────────────────────────────
  static Future<List<Map<String, String>>?> _fetchBolls(
      String bookId, int chapter) async {
    try {
      final bookNum = _bollsBookMap[bookId];
      if (bookNum == null) return null;

      // BRAGA = Bíblia Almeida Revista e Atualizada (português)
      final url = 'https://bolls.life/get-chapter/BRAGA/$bookNum/$chapter/';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.map<Map<String, String>>((v) => {
            'verse': '${v['verse'] ?? v['pk'] ?? ''}',
            'text': '${v['text'] ?? ''}',
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  // ── API 3: bible-api.com (sem token, Almeida PT-BR) ─────────────────────
  static Future<List<Map<String, String>>?> _fetchBibleApi(
      String bookId, int chapter) async {
    try {
      final bookName = _bibleApiBookMap[bookId];
      if (bookName == null) return null;

      // Busca o capítulo completo
      final url = 'https://bible-api.com/$bookName+$chapter?translation=almeida';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List? ?? [];
        if (verses.isNotEmpty) {
          return verses.map<Map<String, String>>((v) => {
            'verse': '${v['verse'] ?? ''}',
            // Remove espaços extras que a API às vezes inclui
            'text': '${v['text'] ?? ''}'.trim(),
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Fallback local — versículos reais embarcados ──────────────────────────
  // Contém os primeiros capítulos dos livros mais lidos
  // para funcionar completamente offline.
  static List<Map<String, String>> _realLocalVerses(String bookId, int chapter) {
    final key = '${bookId}_$chapter';
    final data = _embeddedVerses[key];
    if (data != null) return data;

    // Se não tem o capítulo específico, mostra mensagem útil
    return [
      {'verse': '1', 'text': 'Conecte-se à internet para carregar este capítulo.'},
      {'verse': '2', 'text': 'Os textos bíblicos são carregados automaticamente quando há conexão disponível.'},
      {'verse': '3', 'text': 'Capítulos já lidos ficam salvos para acesso offline.'},
    ];
  }

  // Versículos reais embarcados — livros e capítulos mais acessados
  static final Map<String, List<Map<String, String>>> _embeddedVerses = {

    // ── Gênesis 1 ──────────────────────────────────────────────────────────
    'gn_1': [
      {'verse': '1', 'text': 'No princípio criou Deus os céus e a terra.'},
      {'verse': '2', 'text': 'A terra era sem forma e vazia; e havia trevas sobre a face do abismo; e o Espírito de Deus se movia sobre a face das águas.'},
      {'verse': '3', 'text': 'E disse Deus: Haja luz; e houve luz.'},
      {'verse': '4', 'text': 'E viu Deus que a luz era boa; e fez Deus separação entre a luz e as trevas.'},
      {'verse': '5', 'text': 'E Deus chamou à luz Dia; e às trevas chamou Noite. E foi a tarde e a manhã, o dia primeiro.'},
      {'verse': '6', 'text': 'E disse Deus: Haja um firmamento no meio das águas, e haja separação entre águas e águas.'},
      {'verse': '7', 'text': 'E fez Deus o firmamento, e fez separação entre as águas que estavam debaixo do firmamento e as águas que estavam sobre o firmamento; e assim foi.'},
      {'verse': '8', 'text': 'E chamou Deus ao firmamento Céus; e foi a tarde e a manhã, o dia segundo.'},
      {'verse': '9', 'text': 'E disse Deus: Ajuntem-se as águas que estão debaixo dos céus num lugar; e apareça a porção seca; e assim foi.'},
      {'verse': '10', 'text': 'E chamou Deus à porção seca Terra; e ao ajuntamento das águas chamou Mares; e viu Deus que era bom.'},
      {'verse': '11', 'text': 'E disse Deus: Produza a terra erva verde, erva que dê semente, árvore frutífera que dê fruto segundo a sua espécie, cuja semente esteja nela sobre a terra; e assim foi.'},
      {'verse': '12', 'text': 'E a terra produziu erva, erva dando semente conforme a sua espécie, e árvore frutífera, cuja semente estava nela conforme a sua espécie; e viu Deus que era bom.'},
      {'verse': '13', 'text': 'E foi a tarde e a manhã, o dia terceiro.'},
      {'verse': '14', 'text': 'E disse Deus: Haja luminares no firmamento dos céus para fazerem separação entre o dia e a noite; e sejam eles para sinais e para estações determinadas, e para dias e anos.'},
      {'verse': '15', 'text': 'E sejam para luminares no firmamento dos céus para iluminar a terra; e assim foi.'},
      {'verse': '16', 'text': 'E fez Deus os dois grandes luminares: o luminar maior para governar o dia, e o luminar menor para governar a noite; e fez as estrelas.'},
      {'verse': '17', 'text': 'E Deus os pôs no firmamento dos céus para iluminar a terra,'},
      {'verse': '18', 'text': 'E para governar o dia e a noite, e para fazer separação entre a luz e as trevas; e viu Deus que era bom.'},
      {'verse': '19', 'text': 'E foi a tarde e a manhã, o dia quarto.'},
      {'verse': '20', 'text': 'E disse Deus: Produzam as águas abundantemente répteis de alma vivente; e voem as aves sobre a face do firmamento dos céus.'},
      {'verse': '21', 'text': 'E criou Deus as grandes baleias, e todo o réptil de alma vivente que as águas produziram abundantemente conforme as suas espécies, e toda a ave de asas conforme a sua espécie; e viu Deus que era bom.'},
      {'verse': '22', 'text': 'E Deus os abençoou, dizendo: Sede fecundos, e multiplicai-vos, e enchei as águas nos mares; e as aves se multipliquem na terra.'},
      {'verse': '23', 'text': 'E foi a tarde e a manhã, o dia quinto.'},
      {'verse': '24', 'text': 'E disse Deus: Produza a terra alma vivente conforme a sua espécie; gado, e répteis, e animais da terra conforme a sua espécie; e assim foi.'},
      {'verse': '25', 'text': 'E fez Deus os animais da terra conforme a sua espécie, e o gado conforme a sua espécie, e todo o réptil da terra conforme a sua espécie; e viu Deus que era bom.'},
      {'verse': '26', 'text': 'E disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; e domine sobre os peixes do mar, e sobre as aves dos céus, e sobre o gado, e sobre toda a terra, e sobre todo o réptil que se move sobre a terra.'},
      {'verse': '27', 'text': 'E criou Deus o homem à sua imagem; à imagem de Deus o criou; homem e mulher os criou.'},
      {'verse': '28', 'text': 'E Deus os abençoou, e Deus lhes disse: Sede fecundos e multiplicai-vos, e enchei a terra, e sujeitai-a; e dominai sobre os peixes do mar e sobre as aves dos céus, e sobre todo o animal que se move sobre a terra.'},
      {'verse': '29', 'text': 'E disse Deus: Eis que vos tenho dado toda a erva que dá semente, que está sobre a face de toda a terra, e toda a árvore em que há fruto que dá semente; ser-vos-á para mantimento.'},
      {'verse': '30', 'text': 'E a todo o animal da terra, e a toda a ave dos céus, e a todo o réptil sobre a terra, em que há alma vivente, toda a erva verde lhes será para mantimento; e assim foi.'},
      {'verse': '31', 'text': 'E viu Deus tudo quanto tinha feito, e eis que era muito bom; e foi a tarde e a manhã, o dia sexto.'},
    ],

    // ── Gênesis 2 ──────────────────────────────────────────────────────────
    'gn_2': [
      {'verse': '1', 'text': 'Assim os céus e a terra foram acabados, e todo o seu exército.'},
      {'verse': '2', 'text': 'E aos sete dias completou Deus a sua obra, que fizera; e descansou no dia sétimo de toda a sua obra, que tinha feito.'},
      {'verse': '3', 'text': 'E abençoou Deus o dia sétimo, e o santificou; porque nele descansou de toda a sua obra que Deus criara e fizera.'},
      {'verse': '4', 'text': 'Estas são as origens dos céus e da terra quando foram criados; no dia em que o Senhor Deus fez a terra e os céus,'},
      {'verse': '5', 'text': 'E toda a planta do campo, antes que estivesse na terra, e toda a erva do campo, antes que crescesse; porque o Senhor Deus ainda não tinha feito chover sobre a terra, e não havia homem para lavrar o solo;'},
      {'verse': '6', 'text': 'Mas um vapor subia da terra, e regava toda a face da terra.'},
      {'verse': '7', 'text': 'E formou o Senhor Deus o homem do pó da terra, e soprou em suas narinas o fôlego da vida; e o homem foi feito alma vivente.'},
      {'verse': '8', 'text': 'E plantou o Senhor Deus um jardim no Éden, do lado oriental; e pôs ali o homem que tinha formado.'},
      {'verse': '9', 'text': 'E o Senhor Deus fez crescer do solo toda a árvore agradável à vista e boa para comida; e a árvore da vida no meio do jardim, e a árvore do conhecimento do bem e do mal.'},
      {'verse': '15', 'text': 'E tomou o Senhor Deus o homem, e o pôs no jardim do Éden para o lavrar e guardar.'},
      {'verse': '16', 'text': 'E ordenou o Senhor Deus ao homem, dizendo: De toda a árvore do jardim comerás livremente,'},
      {'verse': '17', 'text': 'Mas da árvore do conhecimento do bem e do mal, dela não comerás; porque no dia em que dela comeres, certamente morrerás.'},
      {'verse': '18', 'text': 'E disse o Senhor Deus: Não é bom que o homem esteja só; far-lhe-ei uma adjutora que lhe seja idônea.'},
      {'verse': '24', 'text': 'Portanto deixará o homem o seu pai e a sua mãe, e se unirá à sua mulher, e serão ambos uma carne.'},
    ],

    // ── João 3 ─────────────────────────────────────────────────────────────
    'jo_3': [
      {'verse': '1', 'text': 'Havia entre os fariseus um homem chamado Nicodemos, príncipe dos judeus.'},
      {'verse': '2', 'text': 'Este foi ter com Jesus de noite, e disse-lhe: Rabi, sabemos que és Mestre, vindo de Deus; porque ninguém pode fazer estes sinais que tu fazes, se Deus não for com ele.'},
      {'verse': '3', 'text': 'Jesus respondeu, e disse-lhe: Na verdade, na verdade te digo que aquele que não nascer de novo não pode ver o reino de Deus.'},
      {'verse': '4', 'text': 'Nicodemos disse-lhe: Como pode um homem nascer sendo velho? Pode tornar a entrar no ventre de sua mãe, e nascer?'},
      {'verse': '5', 'text': 'Jesus respondeu: Na verdade, na verdade te digo que aquele que não nascer da água e do Espírito não pode entrar no reino de Deus.'},
      {'verse': '6', 'text': 'O que é nascido da carne é carne; e o que é nascido do Espírito é espírito.'},
      {'verse': '7', 'text': 'Não te maravilhes de te ter dito: Necessário vos é nascer de novo.'},
      {'verse': '14', 'text': 'E assim como Moisés levantou a serpente no deserto, assim importa que o Filho do homem seja levantado;'},
      {'verse': '15', 'text': 'Para que todo aquele que nele crê não pereça, mas tenha a vida eterna.'},
      {'verse': '16', 'text': 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.'},
      {'verse': '17', 'text': 'Porque Deus enviou o seu Filho ao mundo, não para que condenasse o mundo, mas para que o mundo fosse salvo por ele.'},
    ],

    // ── Salmos 23 ──────────────────────────────────────────────────────────
    'sl_23': [
      {'verse': '1', 'text': 'O Senhor é o meu pastor; nada me faltará.'},
      {'verse': '2', 'text': 'Deitar-me faz em verdes pastos; guia-me mansamente a águas tranquilas.'},
      {'verse': '3', 'text': 'Refrigera a minha alma; guia-me pelas veredas da justiça por amor do seu nome.'},
      {'verse': '4', 'text': 'Ainda que eu andasse pelo vale da sombra da morte, não temeria mal algum, porque tu estás comigo; a tua vara e o teu cajado me consolam.'},
      {'verse': '5', 'text': 'Preparas uma mesa perante mim na presença dos meus inimigos; unges a minha cabeça com óleo; o meu cálice transborda.'},
      {'verse': '6', 'text': 'Certamente que a bondade e a misericórdia me seguirão todos os dias da minha vida; e habitarei na casa do Senhor por longos dias.'},
    ],

    // ── Salmos 91 ──────────────────────────────────────────────────────────
    'sl_91': [
      {'verse': '1', 'text': 'O que habita no esconderijo do Altíssimo, à sombra do Onipotente descansará.'},
      {'verse': '2', 'text': 'Direi do Senhor: Ele é o meu Deus, o meu refúgio, a minha fortaleza, e nele confiarei.'},
      {'verse': '3', 'text': 'Porque ele te livrará do laço do passarinheiro, e da peste perniciosa.'},
      {'verse': '4', 'text': 'Ele te cobrirá com as suas penas, e debaixo das suas asas te refugiarás; a sua verdade será o teu escudo e broquel.'},
      {'verse': '5', 'text': 'Não te assombrará o terror de noite, nem a seta que voa de dia;'},
      {'verse': '11', 'text': 'Porque aos seus anjos dará ordem acerca de ti, para te guardarem em todos os teus caminhos.'},
      {'verse': '14', 'text': 'Pois me amou, eu o livrarei; pô-lo-ei em segurança, porque conheceu o meu nome.'},
    ],

    // ── Mateus 5 ───────────────────────────────────────────────────────────
    'mt_5': [
      {'verse': '1', 'text': 'E Jesus, vendo a multidão, subiu a um monte; e, quando se assentou, seus discípulos vieram a ele.'},
      {'verse': '2', 'text': 'E ele, abrindo a boca, os ensinava, dizendo:'},
      {'verse': '3', 'text': 'Bem-aventurados os pobres de espírito, porque deles é o reino dos céus.'},
      {'verse': '4', 'text': 'Bem-aventurados os que choram, porque eles serão consolados.'},
      {'verse': '5', 'text': 'Bem-aventurados os mansos, porque eles herdarão a terra.'},
      {'verse': '6', 'text': 'Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos.'},
      {'verse': '7', 'text': 'Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia.'},
      {'verse': '8', 'text': 'Bem-aventurados os limpos de coração, porque eles verão a Deus.'},
      {'verse': '9', 'text': 'Bem-aventurados os pacificadores, porque eles serão chamados filhos de Deus.'},
      {'verse': '10', 'text': 'Bem-aventurados os que sofrem perseguição por causa da justiça, porque deles é o reino dos céus.'},
    ],

    // ── Filipenses 4 ───────────────────────────────────────────────────────
    'fp_4': [
      {'verse': '4', 'text': 'Regozijai-vos sempre no Senhor; outra vez digo, regozijai-vos.'},
      {'verse': '5', 'text': 'A vossa modéstia seja conhecida de todos os homens. O Senhor está próximo.'},
      {'verse': '6', 'text': 'Não andeis ansiosos de coisa alguma; antes as vossas petições sejam em tudo conhecidas diante de Deus pela oração e súplica, com ação de graças.'},
      {'verse': '7', 'text': 'E a paz de Deus, que excede todo o entendimento, guardará os vossos corações e os vossos pensamentos em Cristo Jesus.'},
      {'verse': '13', 'text': 'Posso tudo em Cristo que me fortalece.'},
      {'verse': '19', 'text': 'O meu Deus, segundo as suas riquezas em glória, suprirá todas as vossas necessidades em Cristo Jesus.'},
    ],

    // ── Romanos 8 ──────────────────────────────────────────────────────────
    'rm_8': [
      {'verse': '1', 'text': 'Portanto, agora nenhuma condenação há para os que estão em Cristo Jesus, que não andam segundo a carne, mas segundo o Espírito.'},
      {'verse': '2', 'text': 'Porque a lei do Espírito de vida em Cristo Jesus me livrou da lei do pecado e da morte.'},
      {'verse': '28', 'text': 'E sabemos que todas as coisas contribuem juntamente para o bem daqueles que amam a Deus, daqueles que são chamados segundo o seu propósito.'},
      {'verse': '31', 'text': 'Que diremos pois a estas coisas? Se Deus é por nós, quem será contra nós?'},
      {'verse': '37', 'text': 'Mas em todas estas coisas somos mais do que vencedores, por meio daquele que nos amou.'},
      {'verse': '38', 'text': 'Porque estou certo de que nem a morte, nem a vida, nem os anjos, nem os principados, nem as potestades, nem o presente, nem o porvir,'},
      {'verse': '39', 'text': 'Nem a altura, nem a profundidade, nem alguma outra criatura nos poderá separar do amor de Deus, que está em Cristo Jesus nosso Senhor.'},
    ],

    // ── 1 Coríntios 13 ─────────────────────────────────────────────────────
    '1co_13': [
      {'verse': '1', 'text': 'Ainda que eu falasse as línguas dos homens e dos anjos, e não tivesse amor, seria como o metal que soa ou como o sino que tine.'},
      {'verse': '2', 'text': 'E ainda que tivesse o dom de profecia, e conhecesse todos os mistérios e toda a ciência, e ainda que tivesse toda a fé, de maneira tal que transportasse os montes, e não tivesse amor, nada seria.'},
      {'verse': '4', 'text': 'O amor é sofredor, é benigno; o amor não é invejoso; o amor não trata com leviandade, não se ensoberbece.'},
      {'verse': '5', 'text': 'Não se porta com indecência, não busca os seus interesses, não se irrita, não suspeita mal;'},
      {'verse': '6', 'text': 'Não se alegra com a injustiça, mas regozija-se com a verdade;'},
      {'verse': '7', 'text': 'Tudo sofre, tudo crê, tudo espera, tudo suporta.'},
      {'verse': '8', 'text': 'O amor nunca falha; mas havendo profecias, serão aniquiladas; havendo línguas, cessarão; havendo ciência, desaparecerá.'},
      {'verse': '13', 'text': 'Agora, pois, permanecem a fé, a esperança e o amor, estes três; mas o maior destes é o amor.'},
    ],
  };

  // ── Buscar versículo aleatório ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRandomVerseFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('$_abibliaBase/verses/nvi/random'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['text'] ?? '',
          'ref': "${data['book']?['name'] ?? ''} ${data['chapter']}:${data['number']}",
        };
      }
    } catch (_) {}
    return getRandomVerse();
  }

  // ── Buscar por palavra-chave ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> searchVerses(
      String query, BibleVersion version) async {
    if (query.trim().isEmpty) return [];

    final cacheKey = '${query.trim().toLowerCase()}_${version.shortName}';
    if (_searchCache.containsKey(cacheKey)) return _searchCache[cacheKey]!;

    // 1️⃣ Busca na bible-api.com (principal — Almeida PT-BR ✅)
    final bibleApiSearch = await _searchBibleApi(query);
    if (bibleApiSearch != null && bibleApiSearch.isNotEmpty) {
      _searchCache[cacheKey] = bibleApiSearch;
      return bibleApiSearch;
    }

    // 2️⃣ Busca no bolls.life (fallback)
    final bollsSearch = await _searchBolls(query);
    if (bollsSearch != null && bollsSearch.isNotEmpty) {
      _searchCache[cacheKey] = bollsSearch;
      return bollsSearch;
    }

    // 3️⃣ Busca na abibliadigital (quando voltar)
    try {
      final apiVersion = _versionMap[version.shortName] ?? 'nvi';
      final encoded = Uri.encodeComponent(query.trim());
      final url = '$_abibliaBase/verses/$apiVersion/search?search=$encoded';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List? ?? [];
        if (verses.isNotEmpty) {
          final results = verses.map<Map<String, dynamic>>((v) {
            final bookName = v['book']?['name'] ?? '';
            final chap = v['chapter']?.toString() ?? '1';
            final number = v['number']?.toString() ?? '1';
            return {
              'reference': '$bookName $chap:$number',
              'text': '${v['text'] ?? ''}',
              'bookId': '${v['book']?['abbrev']?['pt'] ?? ''}',
              'chapter': chap,
              'verse': number,
            };
          }).toList();
          _searchCache[cacheKey] = results;
          return results;
        }
      }
    } catch (_) {}

    // 3️⃣ Busca local (fallback offline)
    final local = _searchLocal(query);
    _searchCache[cacheKey] = local;
    return local;
  }

  // ── Busca na bible-api.com ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>?> _searchBibleApi(String query) async {
    try {
      // bible-api.com suporta busca por referência (ex: "john 3:16")
      // Para busca por palavra, tentamos carregar versículos conhecidos
      // e filtrar localmente — a API não tem endpoint de busca por palavra
      // Mas para referências bíblicas diretas funciona perfeitamente
      final encoded = Uri.encodeComponent(query.trim());
      final url = 'https://bible-api.com/$encoded?translation=almeida';
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List? ?? [];
        if (verses.isNotEmpty) {
          return verses.map<Map<String, dynamic>>((v) {
            final bookName = data['reference']?.toString().split(' ').first ?? '';
            final chap = (v['chapter'] as int?)?.toString() ?? '1';
            final verse = (v['verse'] as int?)?.toString() ?? '1';
            return {
              'reference': '$bookName $chap:$verse',
              'text': '${v['text'] ?? ''}',
              'bookId': _bibleApiNameToAbbrev(bookName),
              'chapter': chap,
              'verse': verse,
            };
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  static String _bibleApiNameToAbbrev(String name) {
    const map = {
      'genesis': 'gn', 'exodus': 'ex', 'leviticus': 'lv', 'numbers': 'nm',
      'deuteronomy': 'dt', 'joshua': 'js', 'judges': 'jz', 'ruth': 'rt',
      '1 samuel': '1sm', '2 samuel': '2sm', '1 kings': '1rs', '2 kings': '2rs',
      '1 chronicles': '1cr', '2 chronicles': '2cr', 'ezra': 'ed',
      'nehemiah': 'ne', 'esther': 'et', 'job': 'jo', 'psalms': 'sl',
      'proverbs': 'pv', 'ecclesiastes': 'ec', 'song of solomon': 'ct',
      'isaiah': 'is', 'jeremiah': 'jr', 'lamentations': 'lm',
      'ezekiel': 'ez', 'daniel': 'dn', 'hosea': 'os', 'joel': 'jl',
      'amos': 'am', 'obadiah': 'ob', 'jonah': 'jn', 'micah': 'mq',
      'nahum': 'na', 'habakkuk': 'hc', 'zephaniah': 'sf', 'haggai': 'ag',
      'zechariah': 'zc', 'malachi': 'ml', 'matthew': 'mt', 'mark': 'mc',
      'luke': 'lc', 'john': 'jo', 'acts': 'at', 'romans': 'rm',
      '1 corinthians': '1co', '2 corinthians': '2co', 'galatians': 'gl',
      'ephesians': 'ef', 'philippians': 'fp', 'colossians': 'cl',
      '1 thessalonians': '1ts', '2 thessalonians': '2ts',
      '1 timothy': '1tm', '2 timothy': '2tm', 'titus': 'tt',
      'philemon': 'fm', 'hebrews': 'hb', 'james': 'tg',
      '1 peter': '1pe', '2 peter': '2pe', '1 john': '1jo',
      '2 john': '2jo', '3 john': '3jo', 'jude': 'jd', 'revelation': 'ap',
    };
    return map[name.toLowerCase()] ?? 'gn';
  }

  // ── Busca no bolls.life ──────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>?> _searchBolls(String query) async {
    try {
      final encoded = Uri.encodeComponent(query.trim());
      // BRAGA = Almeida Revista e Atualizada (melhor PT-BR disponível no bolls)
      final url = 'https://bolls.life/search/BRAGA/$encoded/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Mapeia número do livro → abbrev
          return data.take(20).map<Map<String, dynamic>>((v) {
            final bookNum = (v['book'] as int?) ?? 1;
            final chap = (v['chapter'] as int?) ?? 1;
            final verse = (v['verse'] as int?) ?? 1;
            final abbrev = _bollsBookNumToAbbrev(bookNum);
            final bookName = _bollsBookNumToName(bookNum);
            return {
              'reference': '$bookName $chap:$verse',
              'text': '${v['text'] ?? ''}',
              'bookId': abbrev,
              'chapter': '$chap',
              'verse': '$verse',
            };
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  static String _bollsBookNumToAbbrev(int num) {
    const abbrevs = [
      'gn','ex','lv','nm','dt','js','jz','rt','1sm','2sm',
      '1rs','2rs','1cr','2cr','ed','ne','et','jo','sl','pv',
      'ec','ct','is','jr','lm','ez','dn','os','jl','am',
      'ob','jn','mq','na','hc','sf','ag','zc','ml',
      'mt','mc','lc','jo','at','rm','1co','2co','gl','ef',
      'fp','cl','1ts','2ts','1tm','2tm','tt','fm','hb','tg',
      '1pe','2pe','1jo','2jo','3jo','jd','ap',
    ];
    if (num < 1 || num > abbrevs.length) return 'gn';
    return abbrevs[num - 1];
  }

  static String _bollsBookNumToName(int num) {
    const names = [
      'Gênesis','Êxodo','Levítico','Números','Deuteronômio','Josué',
      'Juízes','Rute','1 Samuel','2 Samuel','1 Reis','2 Reis',
      '1 Crônicas','2 Crônicas','Esdras','Neemias','Ester','Jó',
      'Salmos','Provérbios','Eclesiastes','Cânticos','Isaías','Jeremias',
      'Lamentações','Ezequiel','Daniel','Oséias','Joel','Amós',
      'Obadias','Jonas','Miquéias','Naum','Habacuque','Sofonias',
      'Ageu','Zacarias','Malaquias','Mateus','Marcos','Lucas',
      'João','Atos','Romanos','1 Coríntios','2 Coríntios','Gálatas',
      'Efésios','Filipenses','Colossenses','1 Tessalonicenses',
      '2 Tessalonicenses','1 Timóteo','2 Timóteo','Tito','Filemom',
      'Hebreus','Tiago','1 Pedro','2 Pedro','1 João','2 João',
      '3 João','Judas','Apocalipse',
    ];
    if (num < 1 || num > names.length) return 'Gênesis';
    return names[num - 1];
  }

  static List<Map<String, dynamic>> _searchLocal(String query) {
    final q = query.toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final v in BibleData.getDailyVerses()) {
      if ((v['text'] as String).toLowerCase().contains(q) ||
          (v['ref'] as String).toLowerCase().contains(q)) {
        results.add({
          'reference': v['ref'],
          'text': v['text'],
          'bookId': v['book'] ?? '',
          'chapter': '${v['chapter'] ?? 1}',
          'verse': '${v['verse'] ?? 1}',
        });
      }
    }
    // Busca também nos versículos embarcados
    for (final entry in _embeddedVerses.entries) {
      for (final v in entry.value) {
        if ((v['text'] ?? '').toLowerCase().contains(q)) {
          final parts = entry.key.split('_');
          results.add({
            'reference': '${parts[0].toUpperCase()} ${parts[1]}:${v['verse']}',
            'text': v['text'] ?? '',
            'bookId': parts[0],
            'chapter': parts[1],
            'verse': v['verse'] ?? '1',
          });
        }
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
}
