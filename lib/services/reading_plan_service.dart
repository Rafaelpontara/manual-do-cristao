// Serviço que gera o cronograma real de leitura bíblica
class ReadingPlanService {

  // ── Cronograma completo da Bíblia em ordem canônica ──────────────────────
  static const List<Map<String, dynamic>> _bibleBooks = [
    // Antigo Testamento
    {'id': 'gn',  'name': 'Gênesis',       'chapters': 50},
    {'id': 'ex',  'name': 'Êxodo',         'chapters': 40},
    {'id': 'lv',  'name': 'Levítico',      'chapters': 27},
    {'id': 'nm',  'name': 'Números',       'chapters': 36},
    {'id': 'dt',  'name': 'Deuteronômio',  'chapters': 34},
    {'id': 'js',  'name': 'Josué',         'chapters': 24},
    {'id': 'jz',  'name': 'Juízes',        'chapters': 21},
    {'id': 'rt',  'name': 'Rute',          'chapters': 4},
    {'id': '1sm', 'name': '1 Samuel',      'chapters': 31},
    {'id': '2sm', 'name': '2 Samuel',      'chapters': 24},
    {'id': '1rs', 'name': '1 Reis',        'chapters': 22},
    {'id': '2rs', 'name': '2 Reis',        'chapters': 25},
    {'id': '1cr', 'name': '1 Crônicas',    'chapters': 29},
    {'id': '2cr', 'name': '2 Crônicas',    'chapters': 36},
    {'id': 'ed',  'name': 'Esdras',        'chapters': 10},
    {'id': 'ne',  'name': 'Neemias',       'chapters': 13},
    {'id': 'et',  'name': 'Ester',         'chapters': 10},
    {'id': 'jó',  'name': 'Jó',            'chapters': 42},
    {'id': 'sl',  'name': 'Salmos',        'chapters': 150},
    {'id': 'pv',  'name': 'Provérbios',    'chapters': 31},
    {'id': 'ec',  'name': 'Eclesiastes',   'chapters': 12},
    {'id': 'ct',  'name': 'Cantares',      'chapters': 8},
    {'id': 'is',  'name': 'Isaías',        'chapters': 66},
    {'id': 'jr',  'name': 'Jeremias',      'chapters': 52},
    {'id': 'lm',  'name': 'Lamentações',   'chapters': 5},
    {'id': 'ez',  'name': 'Ezequiel',      'chapters': 48},
    {'id': 'dn',  'name': 'Daniel',        'chapters': 12},
    {'id': 'os',  'name': 'Oséias',        'chapters': 14},
    {'id': 'jl',  'name': 'Joel',          'chapters': 3},
    {'id': 'am',  'name': 'Amós',          'chapters': 9},
    {'id': 'ob',  'name': 'Obadias',       'chapters': 1},
    {'id': 'jn',  'name': 'Jonas',         'chapters': 4},
    {'id': 'mq',  'name': 'Miquéias',      'chapters': 7},
    {'id': 'na',  'name': 'Naum',          'chapters': 3},
    {'id': 'hc',  'name': 'Habacuque',     'chapters': 3},
    {'id': 'sf',  'name': 'Sofonias',      'chapters': 3},
    {'id': 'ag',  'name': 'Ageu',          'chapters': 2},
    {'id': 'zc',  'name': 'Zacarias',      'chapters': 14},
    {'id': 'ml',  'name': 'Malaquias',     'chapters': 4},
    // Novo Testamento
    {'id': 'mt',  'name': 'Mateus',        'chapters': 28},
    {'id': 'mc',  'name': 'Marcos',        'chapters': 16},
    {'id': 'lc',  'name': 'Lucas',         'chapters': 24},
    {'id': 'jo',  'name': 'João',          'chapters': 21},
    {'id': 'at',  'name': 'Atos',          'chapters': 28},
    {'id': 'rm',  'name': 'Romanos',       'chapters': 16},
    {'id': '1co', 'name': '1 Coríntios',   'chapters': 16},
    {'id': '2co', 'name': '2 Coríntios',   'chapters': 13},
    {'id': 'gl',  'name': 'Gálatas',       'chapters': 6},
    {'id': 'ef',  'name': 'Efésios',       'chapters': 6},
    {'id': 'fp',  'name': 'Filipenses',    'chapters': 4},
    {'id': 'cl',  'name': 'Colossenses',   'chapters': 4},
    {'id': '1ts', 'name': '1 Tessalonicenses', 'chapters': 5},
    {'id': '2ts', 'name': '2 Tessalonicenses', 'chapters': 3},
    {'id': '1tm', 'name': '1 Timóteo',     'chapters': 6},
    {'id': '2tm', 'name': '2 Timóteo',     'chapters': 4},
    {'id': 'tt',  'name': 'Tito',          'chapters': 3},
    {'id': 'fm',  'name': 'Filemom',       'chapters': 1},
    {'id': 'hb',  'name': 'Hebreus',       'chapters': 13},
    {'id': 'tg',  'name': 'Tiago',         'chapters': 5},
    {'id': '1pe', 'name': '1 Pedro',       'chapters': 5},
    {'id': '2pe', 'name': '2 Pedro',       'chapters': 3},
    {'id': '1jo', 'name': '1 João',        'chapters': 5},
    {'id': '2jo', 'name': '2 João',        'chapters': 1},
    {'id': '3jo', 'name': '3 João',        'chapters': 1},
    {'id': 'jd',  'name': 'Judas',         'chapters': 1},
    {'id': 'ap',  'name': 'Apocalipse',    'chapters': 22},
  ];

  static const List<Map<String, dynamic>> _newTestament = [
    {'id': 'mt',  'name': 'Mateus',        'chapters': 28},
    {'id': 'mc',  'name': 'Marcos',        'chapters': 16},
    {'id': 'lc',  'name': 'Lucas',         'chapters': 24},
    {'id': 'jo',  'name': 'João',          'chapters': 21},
    {'id': 'at',  'name': 'Atos',          'chapters': 28},
    {'id': 'rm',  'name': 'Romanos',       'chapters': 16},
    {'id': '1co', 'name': '1 Coríntios',   'chapters': 16},
    {'id': '2co', 'name': '2 Coríntios',   'chapters': 13},
    {'id': 'gl',  'name': 'Gálatas',       'chapters': 6},
    {'id': 'ef',  'name': 'Efésios',       'chapters': 6},
    {'id': 'fp',  'name': 'Filipenses',    'chapters': 4},
    {'id': 'cl',  'name': 'Colossenses',   'chapters': 4},
    {'id': '1ts', 'name': '1 Tessalonicenses', 'chapters': 5},
    {'id': '2ts', 'name': '2 Tessalonicenses', 'chapters': 3},
    {'id': '1tm', 'name': '1 Timóteo',     'chapters': 6},
    {'id': '2tm', 'name': '2 Timóteo',     'chapters': 4},
    {'id': 'tt',  'name': 'Tito',          'chapters': 3},
    {'id': 'fm',  'name': 'Filemom',       'chapters': 1},
    {'id': 'hb',  'name': 'Hebreus',       'chapters': 13},
    {'id': 'tg',  'name': 'Tiago',         'chapters': 5},
    {'id': '1pe', 'name': '1 Pedro',       'chapters': 5},
    {'id': '2pe', 'name': '2 Pedro',       'chapters': 3},
    {'id': '1jo', 'name': '1 João',        'chapters': 5},
    {'id': '2jo', 'name': '2 João',        'chapters': 1},
    {'id': '3jo', 'name': '3 João',        'chapters': 1},
    {'id': 'jd',  'name': 'Judas',         'chapters': 1},
    {'id': 'ap',  'name': 'Apocalipse',    'chapters': 22},
  ];

  // ── Gerar cronograma real ─────────────────────────────────────────────────
  static List<Map<String, dynamic>> generateSchedule(String type) {
    final books = type == '3months' ? _newTestament : _bibleBooks;
    final totalDays = type == '1year' ? 365 : type == '6months' ? 180 : 90;

    // Flatten all chapters
    final allChapters = <Map<String, dynamic>>[];
    for (final book in books) {
      for (int c = 1; c <= (book['chapters'] as int); c++) {
        allChapters.add({'bookId': book['id'], 'bookName': book['name'], 'chapter': c});
      }
    }

    final totalChapters = allChapters.length;
    final chapsPerDay = (totalChapters / totalDays).ceil();
    final schedule = <Map<String, dynamic>>[];

    int idx = 0;
    for (int day = 1; day <= totalDays; day++) {
      final readings = <Map<String, dynamic>>[];
      for (int c = 0; c < chapsPerDay && idx < totalChapters; c++, idx++) {
        readings.add(allChapters[idx]);
      }
      schedule.add({
        'day': day,
        'readings': readings,
        'completed': false,
        'completedAt': null,
      });
    }

    return schedule;
  }

  // ── Pegar leitura do dia atual ────────────────────────────────────────────
  static Map<String, dynamic>? getTodayReading(List<Map<String, dynamic>> schedule, int currentDay) {
    if (schedule.isEmpty || currentDay > schedule.length) return null;
    return schedule[currentDay - 1];
  }

  // ── Calcular progresso ────────────────────────────────────────────────────
  static double calculateProgress(int currentDay, int totalDays) {
    if (totalDays == 0) return 0;
    return (currentDay - 1) / totalDays;
  }
}
