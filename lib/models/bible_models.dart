// ═══════════════════════════════════════════════════════════════
// MODELOS — Palavra Viva
// ═══════════════════════════════════════════════════════════════

enum Testament { old, new_ }

// ── Versões da Bíblia ──────────────────────────────────────────
enum BibleVersion {
  // Evangélica / Protestante
  acf, arc, ntlh, nviPt,
  // Católica
  teb, bibAvePaulo,
  // Espírita
  erc, arcEspirita,
}

extension BibleVersionExt on BibleVersion {
  String get displayName {
    switch (this) {
      case BibleVersion.acf:       return 'ACF — Almeida Corrigida Fiel';
      case BibleVersion.arc:       return 'ARC — Almeida Revista e Corrigida';
      case BibleVersion.ntlh:      return 'NTLH — Nova Tradução na Linguagem de Hoje';
      case BibleVersion.nviPt:     return 'NVI-PT — Nova Versão Internacional';
      case BibleVersion.teb:       return 'TEB — Tradução Ecumênica da Bíblia';
      case BibleVersion.bibAvePaulo: return 'Bíblia Ave-Maria (Católica)';
      case BibleVersion.erc:       return 'ERC — Edição Espírita Comentada';
      case BibleVersion.arcEspirita: return 'ARC com Notas Espíritas';
    }
  }

  String get shortName {
    switch (this) {
      case BibleVersion.acf:       return 'ACF';
      case BibleVersion.arc:       return 'ARC';
      case BibleVersion.ntlh:      return 'NTLH';
      case BibleVersion.nviPt:     return 'NVI-PT';
      case BibleVersion.teb:       return 'TEB';
      case BibleVersion.bibAvePaulo: return 'Ave-Maria';
      case BibleVersion.erc:       return 'ERC';
      case BibleVersion.arcEspirita: return 'ARC-E';
    }
  }

  String get description {
    switch (this) {
      case BibleVersion.acf:       return 'Tradução clássica e fiel ao texto original';
      case BibleVersion.arc:       return 'Versão popular entre evangélicos';
      case BibleVersion.ntlh:      return 'Linguagem moderna e acessível';
      case BibleVersion.nviPt:     return 'Tradução contemporânea e precisa';
      case BibleVersion.teb:       return 'Inclui deuterocanônicos católicos';
      case BibleVersion.bibAvePaulo: return 'Bíblia oficial da Igreja Católica no Brasil';
      case BibleVersion.erc:       return 'Com comentários e notas espíritas';
      case BibleVersion.arcEspirita: return 'ARC com notas doutrinárias espíritas';
    }
  }
}

// ── Religiões / Estilos ────────────────────────────────────────
enum Religion { catholic, evangelical, spiritist }

extension ReligionExt on Religion {
  String get displayName {
    switch (this) {
      case Religion.catholic:    return 'Católica';
      case Religion.evangelical: return 'Evangélica / Protestante';
      case Religion.spiritist:   return 'Espírita';
    }
  }

  String get emoji {
    switch (this) {
      case Religion.catholic:    return '✝️';
      case Religion.evangelical: return '📖';
      case Religion.spiritist:   return '🕊️';
    }
  }

  String get description {
    switch (this) {
      case Religion.catholic:
        return 'Canon católico com 73 livros, incluindo deuterocanônicos (Tobias, Judite, Macabeus...)';
      case Religion.evangelical:
        return 'Canon protestante com 66 livros. Versões tradicionais e contemporâneas';
      case Religion.spiritist:
        return 'Bíblia com perspectiva espírita, baseada nos ensinamentos de Allan Kardec';
    }
  }

  // Versão padrão para cada religião
  BibleVersion get defaultVersion {
    switch (this) {
      case Religion.catholic:    return BibleVersion.teb;
      case Religion.evangelical: return BibleVersion.acf;
      case Religion.spiritist:   return BibleVersion.arcEspirita;
    }
  }

  List<BibleVersion> get availableVersions {
    switch (this) {
      case Religion.catholic:
        return [BibleVersion.teb, BibleVersion.bibAvePaulo, BibleVersion.ntlh];
      case Religion.evangelical:
        return [BibleVersion.acf, BibleVersion.arc, BibleVersion.ntlh, BibleVersion.nviPt];
      case Religion.spiritist:
        return [BibleVersion.arcEspirita, BibleVersion.erc, BibleVersion.arc];
    }
  }

  // Livros extras por religião
  bool get hasDeuterocanonical {
    return this == Religion.catholic;
  }

  List<String> get extraBooks {
    switch (this) {
      case Religion.catholic:
        return ['Tobias', 'Judite', '1 Macabeus', '2 Macabeus', 'Sabedoria', 'Eclesiástico', 'Baruque'];
      case Religion.spiritist:
        return []; // Mesmos livros do cânon protestante
      case Religion.evangelical:
        return [];
    }
  }

  // Temas e ênfases para IA
  String get aiContext {
    switch (this) {
      case Religion.catholic:
        return 'Perspectiva católica, incluindo Tradição, Magistério, Santos e Deuterocanônicos';
      case Religion.evangelical:
        return 'Perspectiva evangélica/protestante, com ênfase na Sola Scriptura e Graça';
      case Religion.spiritist:
        return 'Perspectiva espírita baseada em Allan Kardec, incluindo temas de caridade, reencarnação e mediunidade conforme ensinados no Evangelho Segundo o Espiritismo';
    }
  }
}

// ── Livro da Bíblia ────────────────────────────────────────────
class BibleBook {
  final String id;
  final String name;
  final String abbreviation;
  final Testament testament;
  final int chapters;
  final int totalVerses;
  final String category;
  final String? description;
  double readingProgress;
  List<int> completedChapters;

  BibleBook({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.chapters,
    required this.totalVerses,
    required this.category,
    this.description,
    this.readingProgress = 0.0,
    List<int>? completedChapters,
  }) : completedChapters = completedChapters ?? [];

  bool get isCompleted => readingProgress >= 1.0;
}

// ── Nota ──────────────────────────────────────────────────────
class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  String colorTag;
  String? verseReference;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.colorTag = 'gold',
    this.verseReference,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'colorTag': colorTag, 'verseReference': verseReference,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'], title: json['title'], content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    colorTag: json['colorTag'] ?? 'gold',
    verseReference: json['verseReference'],
  );
}

// ── Plano de Leitura ───────────────────────────────────────────
class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final int totalDays;
  int currentDay;
  double progress;
  final List<Map<String, dynamic>> schedule;

  ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.totalDays,
    this.currentDay = 1,
    this.progress = 0.0,
    required this.schedule,
  });
}

// ── Vídeo/Aula ────────────────────────────────────────────────
class VideoLesson {
  final String id;
  final String title;
  final String youtubeId;
  final String bookId;
  final String duration;
  final String thumbnail;
  final String channelName;
  final String category; // 'padre' ou 'pastor'
  final String description;

  const VideoLesson({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.bookId,
    required this.duration,
    required this.thumbnail,
    this.channelName = '',
    this.category = 'pastor',
    this.description = '',
  });
}

// ═══════════════════════════════════════════════════════════════
// DADOS ESTÁTICOS
// ═══════════════════════════════════════════════════════════════
class BibleData {
  static List<BibleBook> getBooks({Religion religion = Religion.evangelical}) {
    final books = _allBooks();
    if (religion == Religion.catholic) {
      books.addAll(_deuterocanonicalBooks());
      books.sort((a, b) => _bookOrder(a.id).compareTo(_bookOrder(b.id)));
    }
    return books;
  }

  static int _bookOrder(String id) {
    const order = [
      'gn','ex','lv','nm','dt','js','jz','rt','1sm','2sm','1rs','2rs',
      '1cr','2cr','ed','ne','tb','jd','et','1mc','2mc','jó','sl','pv',
      'ec','ct','sb','eclo','is','jr','lm','br','ez','dn','os','jl',
      'am','ob','jn','mq','na','hc','sf','ag','zc','ml',
      'mt','mc','lc','jo','at','rm','1co','2co','gl','ef','fp','cl',
      '1ts','2ts','1tm','2tm','tt','fm','hb','tg','1pe','2pe',
      '1jo','2jo','3jo','jd','ap',
    ];
    final i = order.indexOf(id);
    return i == -1 ? 999 : i;
  }

  static List<BibleBook> _deuterocanonicalBooks() => [
    BibleBook(id: 'tb', name: 'Tobias', abbreviation: 'Tb', testament: Testament.old, chapters: 14, totalVerses: 244, category: 'Histórico', description: 'Livro deuterocanônico católico'),
    BibleBook(id: 'jd', name: 'Judite', abbreviation: 'Jd', testament: Testament.old, chapters: 16, totalVerses: 340, category: 'Histórico', description: 'Livro deuterocanônico católico'),
    BibleBook(id: '1mc', name: '1 Macabeus', abbreviation: '1Mc', testament: Testament.old, chapters: 16, totalVerses: 924, category: 'Histórico', description: 'Livro deuterocanônico católico'),
    BibleBook(id: '2mc', name: '2 Macabeus', abbreviation: '2Mc', testament: Testament.old, chapters: 15, totalVerses: 555, category: 'Histórico', description: 'Livro deuterocanônico católico'),
    BibleBook(id: 'sb', name: 'Sabedoria', abbreviation: 'Sb', testament: Testament.old, chapters: 19, totalVerses: 435, category: 'Sapiencial', description: 'Livro deuterocanônico católico'),
    BibleBook(id: 'eclo', name: 'Eclesiástico', abbreviation: 'Eclo', testament: Testament.old, chapters: 51, totalVerses: 1390, category: 'Sapiencial', description: 'Sirácida — deuterocanônico católico'),
    BibleBook(id: 'br', name: 'Baruque', abbreviation: 'Br', testament: Testament.old, chapters: 6, totalVerses: 213, category: 'Profético', description: 'Livro deuterocanônico católico'),
  ];

  static List<BibleBook> _allBooks() => [
    // ── Antigo Testamento ──────────────────────────────────
    BibleBook(id: 'gn', name: 'Gênesis', abbreviation: 'Gn', testament: Testament.old, chapters: 50, totalVerses: 1533, category: 'Pentateuco', description: 'A criação do mundo e os patriarcas'),
    BibleBook(id: 'ex', name: 'Êxodo', abbreviation: 'Ex', testament: Testament.old, chapters: 40, totalVerses: 1213, category: 'Pentateuco', description: 'A libertação do Egito e a Lei de Moisés'),
    BibleBook(id: 'lv', name: 'Levítico', abbreviation: 'Lv', testament: Testament.old, chapters: 27, totalVerses: 859, category: 'Pentateuco'),
    BibleBook(id: 'nm', name: 'Números', abbreviation: 'Nm', testament: Testament.old, chapters: 36, totalVerses: 1288, category: 'Pentateuco'),
    BibleBook(id: 'dt', name: 'Deuteronômio', abbreviation: 'Dt', testament: Testament.old, chapters: 34, totalVerses: 959, category: 'Pentateuco'),
    BibleBook(id: 'js', name: 'Josué', abbreviation: 'Js', testament: Testament.old, chapters: 24, totalVerses: 658, category: 'Histórico'),
    BibleBook(id: 'jz', name: 'Juízes', abbreviation: 'Jz', testament: Testament.old, chapters: 21, totalVerses: 618, category: 'Histórico'),
    BibleBook(id: 'rt', name: 'Rute', abbreviation: 'Rt', testament: Testament.old, chapters: 4, totalVerses: 85, category: 'Histórico'),
    BibleBook(id: '1sm', name: '1 Samuel', abbreviation: '1Sm', testament: Testament.old, chapters: 31, totalVerses: 810, category: 'Histórico'),
    BibleBook(id: '2sm', name: '2 Samuel', abbreviation: '2Sm', testament: Testament.old, chapters: 24, totalVerses: 695, category: 'Histórico'),
    BibleBook(id: '1rs', name: '1 Reis', abbreviation: '1Rs', testament: Testament.old, chapters: 22, totalVerses: 816, category: 'Histórico'),
    BibleBook(id: '2rs', name: '2 Reis', abbreviation: '2Rs', testament: Testament.old, chapters: 25, totalVerses: 719, category: 'Histórico'),
    BibleBook(id: '1cr', name: '1 Crônicas', abbreviation: '1Cr', testament: Testament.old, chapters: 29, totalVerses: 942, category: 'Histórico'),
    BibleBook(id: '2cr', name: '2 Crônicas', abbreviation: '2Cr', testament: Testament.old, chapters: 36, totalVerses: 822, category: 'Histórico'),
    BibleBook(id: 'ed', name: 'Esdras', abbreviation: 'Ed', testament: Testament.old, chapters: 10, totalVerses: 280, category: 'Histórico'),
    BibleBook(id: 'ne', name: 'Neemias', abbreviation: 'Ne', testament: Testament.old, chapters: 13, totalVerses: 406, category: 'Histórico'),
    BibleBook(id: 'et', name: 'Ester', abbreviation: 'Et', testament: Testament.old, chapters: 10, totalVerses: 167, category: 'Histórico'),
    BibleBook(id: 'jó', name: 'Jó', abbreviation: 'Jó', testament: Testament.old, chapters: 42, totalVerses: 1070, category: 'Sapiencial', description: 'O sofrimento e a fidelidade de Jó'),
    BibleBook(id: 'sl', name: 'Salmos', abbreviation: 'Sl', testament: Testament.old, chapters: 150, totalVerses: 2461, category: 'Sapiencial', description: 'Hinos e orações de Israel'),
    BibleBook(id: 'pv', name: 'Provérbios', abbreviation: 'Pv', testament: Testament.old, chapters: 31, totalVerses: 915, category: 'Sapiencial'),
    BibleBook(id: 'ec', name: 'Eclesiastes', abbreviation: 'Ec', testament: Testament.old, chapters: 12, totalVerses: 222, category: 'Sapiencial'),
    BibleBook(id: 'ct', name: 'Cântico dos Cânticos', abbreviation: 'Ct', testament: Testament.old, chapters: 8, totalVerses: 117, category: 'Sapiencial'),
    BibleBook(id: 'is', name: 'Isaías', abbreviation: 'Is', testament: Testament.old, chapters: 66, totalVerses: 1292, category: 'Profético', description: 'Profecias messiânicas e de restauração'),
    BibleBook(id: 'jr', name: 'Jeremias', abbreviation: 'Jr', testament: Testament.old, chapters: 52, totalVerses: 1364, category: 'Profético'),
    BibleBook(id: 'lm', name: 'Lamentações', abbreviation: 'Lm', testament: Testament.old, chapters: 5, totalVerses: 154, category: 'Profético'),
    BibleBook(id: 'ez', name: 'Ezequiel', abbreviation: 'Ez', testament: Testament.old, chapters: 48, totalVerses: 1273, category: 'Profético'),
    BibleBook(id: 'dn', name: 'Daniel', abbreviation: 'Dn', testament: Testament.old, chapters: 12, totalVerses: 357, category: 'Profético'),
    BibleBook(id: 'os', name: 'Oséias', abbreviation: 'Os', testament: Testament.old, chapters: 14, totalVerses: 197, category: 'Profetas Menores'),
    BibleBook(id: 'jl', name: 'Joel', abbreviation: 'Jl', testament: Testament.old, chapters: 3, totalVerses: 73, category: 'Profetas Menores'),
    BibleBook(id: 'am', name: 'Amós', abbreviation: 'Am', testament: Testament.old, chapters: 9, totalVerses: 146, category: 'Profetas Menores'),
    BibleBook(id: 'ob', name: 'Obadias', abbreviation: 'Ob', testament: Testament.old, chapters: 1, totalVerses: 21, category: 'Profetas Menores'),
    BibleBook(id: 'jn', name: 'Jonas', abbreviation: 'Jn', testament: Testament.old, chapters: 4, totalVerses: 48, category: 'Profetas Menores'),
    BibleBook(id: 'mq', name: 'Miquéias', abbreviation: 'Mq', testament: Testament.old, chapters: 7, totalVerses: 105, category: 'Profetas Menores'),
    BibleBook(id: 'na', name: 'Naum', abbreviation: 'Na', testament: Testament.old, chapters: 3, totalVerses: 47, category: 'Profetas Menores'),
    BibleBook(id: 'hc', name: 'Habacuque', abbreviation: 'Hc', testament: Testament.old, chapters: 3, totalVerses: 56, category: 'Profetas Menores'),
    BibleBook(id: 'sf', name: 'Sofonias', abbreviation: 'Sf', testament: Testament.old, chapters: 3, totalVerses: 53, category: 'Profetas Menores'),
    BibleBook(id: 'ag', name: 'Ageu', abbreviation: 'Ag', testament: Testament.old, chapters: 2, totalVerses: 38, category: 'Profetas Menores'),
    BibleBook(id: 'zc', name: 'Zacarias', abbreviation: 'Zc', testament: Testament.old, chapters: 14, totalVerses: 211, category: 'Profetas Menores'),
    BibleBook(id: 'ml', name: 'Malaquias', abbreviation: 'Ml', testament: Testament.old, chapters: 4, totalVerses: 55, category: 'Profetas Menores'),
    // ── Novo Testamento ────────────────────────────────────
    BibleBook(id: 'mt', name: 'Mateus', abbreviation: 'Mt', testament: Testament.new_, chapters: 28, totalVerses: 1071, category: 'Evangelhos', description: 'O Evangelho do Rei'),
    BibleBook(id: 'mc', name: 'Marcos', abbreviation: 'Mc', testament: Testament.new_, chapters: 16, totalVerses: 678, category: 'Evangelhos', description: 'O Evangelho do Servo'),
    BibleBook(id: 'lc', name: 'Lucas', abbreviation: 'Lc', testament: Testament.new_, chapters: 24, totalVerses: 1151, category: 'Evangelhos', description: 'O Evangelho do Filho do Homem'),
    BibleBook(id: 'jo', name: 'João', abbreviation: 'Jo', testament: Testament.new_, chapters: 21, totalVerses: 879, category: 'Evangelhos', description: 'O Evangelho do Filho de Deus'),
    BibleBook(id: 'at', name: 'Atos', abbreviation: 'At', testament: Testament.new_, chapters: 28, totalVerses: 1007, category: 'Histórico'),
    BibleBook(id: 'rm', name: 'Romanos', abbreviation: 'Rm', testament: Testament.new_, chapters: 16, totalVerses: 433, category: 'Cartas de Paulo'),
    BibleBook(id: '1co', name: '1 Coríntios', abbreviation: '1Co', testament: Testament.new_, chapters: 16, totalVerses: 437, category: 'Cartas de Paulo'),
    BibleBook(id: '2co', name: '2 Coríntios', abbreviation: '2Co', testament: Testament.new_, chapters: 13, totalVerses: 257, category: 'Cartas de Paulo'),
    BibleBook(id: 'gl', name: 'Gálatas', abbreviation: 'Gl', testament: Testament.new_, chapters: 6, totalVerses: 149, category: 'Cartas de Paulo'),
    BibleBook(id: 'ef', name: 'Efésios', abbreviation: 'Ef', testament: Testament.new_, chapters: 6, totalVerses: 155, category: 'Cartas de Paulo'),
    BibleBook(id: 'fp', name: 'Filipenses', abbreviation: 'Fp', testament: Testament.new_, chapters: 4, totalVerses: 104, category: 'Cartas de Paulo'),
    BibleBook(id: 'cl', name: 'Colossenses', abbreviation: 'Cl', testament: Testament.new_, chapters: 4, totalVerses: 95, category: 'Cartas de Paulo'),
    BibleBook(id: '1ts', name: '1 Tessalonicenses', abbreviation: '1Ts', testament: Testament.new_, chapters: 5, totalVerses: 89, category: 'Cartas de Paulo'),
    BibleBook(id: '2ts', name: '2 Tessalonicenses', abbreviation: '2Ts', testament: Testament.new_, chapters: 3, totalVerses: 47, category: 'Cartas de Paulo'),
    BibleBook(id: '1tm', name: '1 Timóteo', abbreviation: '1Tm', testament: Testament.new_, chapters: 6, totalVerses: 113, category: 'Cartas de Paulo'),
    BibleBook(id: '2tm', name: '2 Timóteo', abbreviation: '2Tm', testament: Testament.new_, chapters: 4, totalVerses: 83, category: 'Cartas de Paulo'),
    BibleBook(id: 'tt', name: 'Tito', abbreviation: 'Tt', testament: Testament.new_, chapters: 3, totalVerses: 46, category: 'Cartas de Paulo'),
    BibleBook(id: 'fm', name: 'Filemom', abbreviation: 'Fm', testament: Testament.new_, chapters: 1, totalVerses: 25, category: 'Cartas de Paulo'),
    BibleBook(id: 'hb', name: 'Hebreus', abbreviation: 'Hb', testament: Testament.new_, chapters: 13, totalVerses: 303, category: 'Cartas Gerais'),
    BibleBook(id: 'tg', name: 'Tiago', abbreviation: 'Tg', testament: Testament.new_, chapters: 5, totalVerses: 108, category: 'Cartas Gerais'),
    BibleBook(id: '1pe', name: '1 Pedro', abbreviation: '1Pe', testament: Testament.new_, chapters: 5, totalVerses: 105, category: 'Cartas Gerais'),
    BibleBook(id: '2pe', name: '2 Pedro', abbreviation: '2Pe', testament: Testament.new_, chapters: 3, totalVerses: 61, category: 'Cartas Gerais'),
    BibleBook(id: '1jo', name: '1 João', abbreviation: '1Jo', testament: Testament.new_, chapters: 5, totalVerses: 105, category: 'Cartas Gerais'),
    BibleBook(id: '2jo', name: '2 João', abbreviation: '2Jo', testament: Testament.new_, chapters: 1, totalVerses: 13, category: 'Cartas Gerais'),
    BibleBook(id: '3jo', name: '3 João', abbreviation: '3Jo', testament: Testament.new_, chapters: 1, totalVerses: 14, category: 'Cartas Gerais'),
    BibleBook(id: 'jd2', name: 'Judas', abbreviation: 'Jd', testament: Testament.new_, chapters: 1, totalVerses: 25, category: 'Cartas Gerais'),
    BibleBook(id: 'ap', name: 'Apocalipse', abbreviation: 'Ap', testament: Testament.new_, chapters: 22, totalVerses: 404, category: 'Profético', description: 'A revelação de Jesus Cristo a João'),
  ];

  // ── Versículos do Dia ──────────────────────────────────────
  static List<Map<String, dynamic>> getDailyVerses() => [
    // ── Janeiro / 1-31 ────────────────────────────────────────────────────
    {'text': 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.', 'ref': 'João 3:16', 'book': 'jo', 'chapter': 3, 'verse': 16},
    {'text': 'O Senhor é o meu pastor; nada me faltará.', 'ref': 'Salmos 23:1', 'book': 'sl', 'chapter': 23, 'verse': 1},
    {'text': 'Tudo posso naquele que me fortalece.', 'ref': 'Filipenses 4:13', 'book': 'fp', 'chapter': 4, 'verse': 13},
    {'text': 'Porque para Deus não há nada impossível.', 'ref': 'Lucas 1:37', 'book': 'lc', 'chapter': 1, 'verse': 37},
    {'text': 'Confia no Senhor de todo o teu coração, e não te estribes no teu próprio entendimento.', 'ref': 'Provérbios 3:5', 'book': 'pv', 'chapter': 3, 'verse': 5},
    {'text': 'Buscai primeiro o reino de Deus e a sua justiça, e todas estas coisas vos serão acrescentadas.', 'ref': 'Mateus 6:33', 'book': 'mt', 'chapter': 6, 'verse': 33},
    {'text': 'Não andeis ansiosos por coisa alguma; antes as vossas petições sejam em tudo conhecidas diante de Deus.', 'ref': 'Filipenses 4:6', 'book': 'fp', 'chapter': 4, 'verse': 6},
    {'text': 'A paz de Deus, que excede todo o entendimento, guardará os vossos corações e os vossos pensamentos em Cristo Jesus.', 'ref': 'Filipenses 4:7', 'book': 'fp', 'chapter': 4, 'verse': 7},
    {'text': 'Sede fortes e corajosos. Não temais, nem vos assusteis diante deles; porque o Senhor teu Deus é o que vai contigo.', 'ref': 'Deuteronômio 31:6', 'book': 'dt', 'chapter': 31, 'verse': 6},
    {'text': 'O amor é paciente, o amor é bondoso. O amor não inveja, não se vangloria, não se ensoberbece.', 'ref': '1 Coríntios 13:4', 'book': '1co', 'chapter': 13, 'verse': 4},
    {'text': 'Eu sou o caminho, e a verdade, e a vida; ninguém vem ao Pai senão por mim.', 'ref': 'João 14:6', 'book': 'jo', 'chapter': 14, 'verse': 6},
    {'text': 'Porque pela graça sois salvos, por meio da fé; e isso não vem de vós; é dom de Deus.', 'ref': 'Efésios 2:8', 'book': 'ef', 'chapter': 2, 'verse': 8},
    {'text': 'Sede fortes e corajosos; não vos atemorizeis, nem vos espanteis; porque o Senhor vosso Deus estará convosco em tudo o que andares.', 'ref': 'Josué 1:9', 'book': 'js', 'chapter': 1, 'verse': 9},
    {'text': 'Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos.', 'ref': 'Mateus 5:6', 'book': 'mt', 'chapter': 5, 'verse': 6},
    {'text': 'O Senhor é a minha luz e a minha salvação; a quem temerei? O Senhor é a força da minha vida; de quem me recearei?', 'ref': 'Salmos 27:1', 'book': 'sl', 'chapter': 27, 'verse': 1},
    {'text': 'Porque eu bem sei os pensamentos que tenho a vosso respeito, diz o Senhor; pensamentos de paz e não de mal, para vos dar o fim que esperais.', 'ref': 'Jeremias 29:11', 'book': 'jr', 'chapter': 29, 'verse': 11},
    {'text': 'Mas os que esperam no Senhor renovarão as forças, subirão com asas como águias; correrão, e não se cansarão; caminharão, e não se fatigarão.', 'ref': 'Isaías 40:31', 'book': 'is', 'chapter': 40, 'verse': 31},
    {'text': 'Ainda que eu ande pelo vale da sombra da morte, não temerei mal algum, porque tu estás comigo.', 'ref': 'Salmos 23:4', 'book': 'sl', 'chapter': 23, 'verse': 4},
    {'text': 'Em Deus somente descansa a minha alma; dele vem a minha salvação.', 'ref': 'Salmos 62:1', 'book': 'sl', 'chapter': 62, 'verse': 1},
    {'text': 'Mas em todas estas coisas somos mais do que vencedores, por meio daquele que nos amou.', 'ref': 'Romanos 8:37', 'book': 'rm', 'chapter': 8, 'verse': 37},
    {'text': 'Nem a morte, nem a vida, nem os anjos, nem os principados nos poderá separar do amor de Deus, que está em Cristo Jesus nosso Senhor.', 'ref': 'Romanos 8:38-39', 'book': 'rm', 'chapter': 8, 'verse': 38},
    {'text': 'E sabemos que todas as coisas contribuem juntamente para o bem daqueles que amam a Deus.', 'ref': 'Romanos 8:28', 'book': 'rm', 'chapter': 8, 'verse': 28},
    {'text': 'Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia.', 'ref': 'Mateus 5:7', 'book': 'mt', 'chapter': 5, 'verse': 7},
    {'text': 'Bem-aventurados os limpos de coração, porque eles verão a Deus.', 'ref': 'Mateus 5:8', 'book': 'mt', 'chapter': 5, 'verse': 8},
    {'text': 'O Senhor te guardará de todo o mal; guardará a tua alma.', 'ref': 'Salmos 121:7', 'book': 'sl', 'chapter': 121, 'verse': 7},
    {'text': 'Lança sobre o Senhor o teu cuidado, e ele te susterá; não permitirá jamais que o justo seja abalado.', 'ref': 'Salmos 55:22', 'book': 'sl', 'chapter': 55, 'verse': 22},
    {'text': 'Não vos conformeis com este século, mas transformai-vos pela renovação da vossa mente.', 'ref': 'Romanos 12:2', 'book': 'rm', 'chapter': 12, 'verse': 2},
    {'text': 'O amor nunca falha; mas havendo profecias, serão aniquiladas; havendo línguas, cessarão.', 'ref': '1 Coríntios 13:8', 'book': '1co', 'chapter': 13, 'verse': 8},
    {'text': 'Agora, pois, permanecem a fé, a esperança e o amor, estes três; mas o maior destes é o amor.', 'ref': '1 Coríntios 13:13', 'book': '1co', 'chapter': 13, 'verse': 13},
    {'text': 'Porque não nos deu Deus o espírito de covardia, mas de poder, e de amor, e de moderação.', 'ref': '2 Timóteo 1:7', 'book': '2tm', 'chapter': 1, 'verse': 7},
    {'text': 'Toda a Escritura é divinamente inspirada, e proveitosa para ensinar, para redarguir, para corrigir, para instruir em justiça.', 'ref': '2 Timóteo 3:16', 'book': '2tm', 'chapter': 3, 'verse': 16},
    // ── Fevereiro / 32-59 ─────────────────────────────────────────────────
    {'text': 'Bem-aventurado o homem que não anda no conselho dos ímpios, nem se detém no caminho dos pecadores.', 'ref': 'Salmos 1:1', 'book': 'sl', 'chapter': 1, 'verse': 1},
    {'text': 'Alegrai-vos sempre no Senhor; outra vez digo, alegrai-vos.', 'ref': 'Filipenses 4:4', 'book': 'fp', 'chapter': 4, 'verse': 4},
    {'text': 'Eu vim para que tenham vida e a tenham em abundância.', 'ref': 'João 10:10', 'book': 'jo', 'chapter': 10, 'verse': 10},
    {'text': 'Pedi e dar-se-vos-á; buscai e achareis; batei e abrir-se-vos-á.', 'ref': 'Mateus 7:7', 'book': 'mt', 'chapter': 7, 'verse': 7},
    {'text': 'O meu Deus, segundo as suas riquezas em glória, suprirá todas as vossas necessidades em Cristo Jesus.', 'ref': 'Filipenses 4:19', 'book': 'fp', 'chapter': 4, 'verse': 19},
    {'text': 'Vinde a mim, todos os que estais cansados e sobrecarregados, e eu vos aliviarei.', 'ref': 'Mateus 11:28', 'book': 'mt', 'chapter': 11, 'verse': 28},
    {'text': 'Deus é o nosso refúgio e fortaleza, socorro bem presente na angústia.', 'ref': 'Salmos 46:1', 'book': 'sl', 'chapter': 46, 'verse': 1},
    {'text': 'Aquietai-vos e sabei que eu sou Deus; serei exaltado entre as nações.', 'ref': 'Salmos 46:10', 'book': 'sl', 'chapter': 46, 'verse': 10},
    {'text': 'O que habita no esconderijo do Altíssimo, à sombra do Onipotente descansará.', 'ref': 'Salmos 91:1', 'book': 'sl', 'chapter': 91, 'verse': 1},
    {'text': 'Porque aos seus anjos dará ordem acerca de ti, para te guardarem em todos os teus caminhos.', 'ref': 'Salmos 91:11', 'book': 'sl', 'chapter': 91, 'verse': 11},
    {'text': 'Honra ao Senhor com a tua fazenda e com as primícias de todos os teus ganhos.', 'ref': 'Provérbios 3:9', 'book': 'pv', 'chapter': 3, 'verse': 9},
    {'text': 'A palavra de Deus é viva e eficaz, e mais penetrante do que qualquer espada de dois gumes.', 'ref': 'Hebreus 4:12', 'book': 'hb', 'chapter': 4, 'verse': 12},
    {'text': 'Ora, a fé é o firme fundamento das coisas que se esperam, e a prova das coisas que se não vêem.', 'ref': 'Hebreus 11:1', 'book': 'hb', 'chapter': 11, 'verse': 1},
    {'text': 'Despojemo-nos de todo o peso e do pecado que tão de perto nos rodeia, e corramos com paciência a carreira que nos está proposta.', 'ref': 'Hebreus 12:1', 'book': 'hb', 'chapter': 12, 'verse': 1},
    {'text': 'Porque Deus tanto amou o mundo que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça.', 'ref': 'João 3:16', 'book': 'jo', 'chapter': 3, 'verse': 16},
    {'text': 'Jesus lhe disse: Eu sou a ressurreição e a vida; quem crê em mim, ainda que esteja morto, viverá.', 'ref': 'João 11:25', 'book': 'jo', 'chapter': 11, 'verse': 25},
    {'text': 'Sede, pois, imitadores de Deus, como filhos amados.', 'ref': 'Efésios 5:1', 'book': 'ef', 'chapter': 5, 'verse': 1},
    {'text': 'Tudo o que é verdadeiro, tudo o que é honesto, tudo o que é justo — nisso pensai.', 'ref': 'Filipenses 4:8', 'book': 'fp', 'chapter': 4, 'verse': 8},
    {'text': 'Não vos conformeis com este século, mas transformai-vos pela renovação do vosso entendimento.', 'ref': 'Romanos 12:2', 'book': 'rm', 'chapter': 12, 'verse': 2},
    {'text': 'Sede bondosos uns para com os outros, misericordiosos, perdoando-vos uns aos outros.', 'ref': 'Efésios 4:32', 'book': 'ef', 'chapter': 4, 'verse': 32},
    {'text': 'Antes, sede uns para com os outros benignos, misericordiosos, perdoando-vos como também Deus vos perdoou em Cristo.', 'ref': 'Efésios 4:32', 'book': 'ef', 'chapter': 4, 'verse': 32},
    {'text': 'Porque sois todos filhos de Deus pela fé em Cristo Jesus.', 'ref': 'Gálatas 3:26', 'book': 'gl', 'chapter': 3, 'verse': 26},
    {'text': 'O fruto do Espírito é: amor, gozo, paz, longanimidade, benignidade, bondade, fidelidade.', 'ref': 'Gálatas 5:22', 'book': 'gl', 'chapter': 5, 'verse': 22},
    {'text': 'Cristo é o mesmo, ontem, e hoje, e eternamente.', 'ref': 'Hebreus 13:8', 'book': 'hb', 'chapter': 13, 'verse': 8},
    {'text': 'Vinde agora, e arrazoemos, diz o Senhor. Ainda que os vossos pecados sejam como a escarlata, eles se tornarão brancos como a neve.', 'ref': 'Isaías 1:18', 'book': 'is', 'chapter': 1, 'verse': 18},
    {'text': 'Não temas, porque eu sou contigo; não te assombres, porque eu sou o teu Deus.', 'ref': 'Isaías 41:10', 'book': 'is', 'chapter': 41, 'verse': 10},
    {'text': 'As misericórdias do Senhor são a causa de não sermos consumidos; as suas misericórdias não têm fim; renovam-se cada manhã.', 'ref': 'Lamentações 3:22-23', 'book': 'lm', 'chapter': 3, 'verse': 22},
    {'text': 'Porque os meus pensamentos não são os vossos pensamentos, nem os vossos caminhos os meus caminhos, diz o Senhor.', 'ref': 'Isaías 55:8', 'book': 'is', 'chapter': 55, 'verse': 8},
    // ── Março-Abril / 60-90 ───────────────────────────────────────────────
    {'text': 'Assim, qualquer que se humilhar como esta criança, esse é o maior no reino dos céus.', 'ref': 'Mateus 18:4', 'book': 'mt', 'chapter': 18, 'verse': 4},
    {'text': 'E conhecereis a verdade, e a verdade vos libertará.', 'ref': 'João 8:32', 'book': 'jo', 'chapter': 8, 'verse': 32},
    {'text': 'Eu sou a videira, e vós as varas; quem está em mim e eu nele, esse dá muito fruto.', 'ref': 'João 15:5', 'book': 'jo', 'chapter': 15, 'verse': 5},
    {'text': 'Nisto é glorificado meu Pai, em que deis muito fruto; e assim sereis meus discípulos.', 'ref': 'João 15:8', 'book': 'jo', 'chapter': 15, 'verse': 8},
    {'text': 'Nisto conhecerão todos que sois meus discípulos, se vos amardes uns aos outros.', 'ref': 'João 13:35', 'book': 'jo', 'chapter': 13, 'verse': 35},
    {'text': 'Deus é amor, e quem permanece no amor permanece em Deus, e Deus permanece nele.', 'ref': '1 João 4:16', 'book': '1jo', 'chapter': 4, 'verse': 16},
    {'text': 'Nós o amamos a ele porque ele nos amou primeiro.', 'ref': '1 João 4:19', 'book': '1jo', 'chapter': 4, 'verse': 19},
    {'text': 'Se confessarmos os nossos pecados, ele é fiel e justo para nos perdoar os pecados.', 'ref': '1 João 1:9', 'book': '1jo', 'chapter': 1, 'verse': 9},
    {'text': 'Todo aquele que é nascido de Deus não vive no pecado, porque a semente de Deus permanece nele.', 'ref': '1 João 3:9', 'book': '1jo', 'chapter': 3, 'verse': 9},
    {'text': 'Eis que estou à porta e bato; se alguém ouvir a minha voz e abrir a porta, entrarei em sua casa.', 'ref': 'Apocalipse 3:20', 'book': 'ap', 'chapter': 3, 'verse': 20},
    {'text': 'E enxugará Deus toda a lágrima dos seus olhos; e não haverá mais morte, nem pranto, nem clamor.', 'ref': 'Apocalipse 21:4', 'book': 'ap', 'chapter': 21, 'verse': 4},
    {'text': 'Portanto, não vos inquieteis pelo dia de amanhã; o dia de amanhã cuidará de si mesmo.', 'ref': 'Mateus 6:34', 'book': 'mt', 'chapter': 6, 'verse': 34},
    {'text': 'Bem-aventurados os pobres de espírito, porque deles é o reino dos céus.', 'ref': 'Mateus 5:3', 'book': 'mt', 'chapter': 5, 'verse': 3},
    {'text': 'Bem-aventurados os pacificadores, porque eles serão chamados filhos de Deus.', 'ref': 'Mateus 5:9', 'book': 'mt', 'chapter': 5, 'verse': 9},
    {'text': 'Vós sois a luz do mundo. Não se pode esconder uma cidade edificada sobre um monte.', 'ref': 'Mateus 5:14', 'book': 'mt', 'chapter': 5, 'verse': 14},
    {'text': 'Assim brilhe a vossa luz diante dos homens, para que vejam as vossas boas obras.', 'ref': 'Mateus 5:16', 'book': 'mt', 'chapter': 5, 'verse': 16},
    {'text': 'Porque onde estiver o vosso tesouro, aí estará também o vosso coração.', 'ref': 'Mateus 6:21', 'book': 'mt', 'chapter': 6, 'verse': 21},
    {'text': 'Nada façais por contenda ou por vanglória, mas por humildade; cada um considere os outros superiores a si mesmo.', 'ref': 'Filipenses 2:3', 'book': 'fp', 'chapter': 2, 'verse': 3},
    {'text': 'Haja em vós o mesmo sentimento que houve em Cristo Jesus.', 'ref': 'Filipenses 2:5', 'book': 'fp', 'chapter': 2, 'verse': 5},
    {'text': 'Tudo posso em Cristo que me fortalece.', 'ref': 'Filipenses 4:13', 'book': 'fp', 'chapter': 4, 'verse': 13},
    {'text': 'Qualquer coisa que fizerdes, fazei-o de todo o coração, como ao Senhor e não aos homens.', 'ref': 'Colossenses 3:23', 'book': 'cl', 'chapter': 3, 'verse': 23},
    {'text': 'Orai continuamente. Em tudo dai graças, porque esta é a vontade de Deus em Cristo Jesus.', 'ref': '1 Tessalonicenses 5:17-18', 'book': '1ts', 'chapter': 5, 'verse': 17},
    // ── Maio-Junho / 91-120 ───────────────────────────────────────────────
    {'text': 'Criou Deus o homem à sua imagem; à imagem de Deus o criou.', 'ref': 'Gênesis 1:27', 'book': 'gn', 'chapter': 1, 'verse': 27},
    {'text': 'O Senhor Deus formou o homem do pó da terra e soprou em suas narinas o fôlego da vida.', 'ref': 'Gênesis 2:7', 'book': 'gn', 'chapter': 2, 'verse': 7},
    {'text': 'Portanto, deixará o homem o seu pai e a sua mãe, e se unirá à sua mulher, e serão ambos uma carne.', 'ref': 'Gênesis 2:24', 'book': 'gn', 'chapter': 2, 'verse': 24},
    {'text': 'E disse Deus: Haja luz; e houve luz.', 'ref': 'Gênesis 1:3', 'book': 'gn', 'chapter': 1, 'verse': 3},
    {'text': 'O Senhor abençoe e te guarde; o Senhor faça resplandecer o seu rosto sobre ti.', 'ref': 'Números 6:24-25', 'book': 'nm', 'chapter': 6, 'verse': 24},
    {'text': 'Amarás o Senhor teu Deus de todo o teu coração, de toda a tua alma e de todo o teu poder.', 'ref': 'Deuteronômio 6:5', 'book': 'dt', 'chapter': 6, 'verse': 5},
    {'text': 'O Senhor teu Deus está no meio de ti, poderoso para salvar; exultará de alegria por causa de ti.', 'ref': 'Sofonias 3:17', 'book': 'sf', 'chapter': 3, 'verse': 17},
    {'text': 'Dá ao Senhor a glória devida ao seu nome; adorai o Senhor na beleza da santidade.', 'ref': 'Salmos 29:2', 'book': 'sl', 'chapter': 29, 'verse': 2},
    {'text': 'Canta ao Senhor um cântico novo; canta ao Senhor toda a terra.', 'ref': 'Salmos 96:1', 'book': 'sl', 'chapter': 96, 'verse': 1},
    {'text': 'Louvai ao Senhor, porque ele é bom; porque a sua misericórdia dura para sempre.', 'ref': 'Salmos 107:1', 'book': 'sl', 'chapter': 107, 'verse': 1},
    {'text': 'Este é o dia que o Senhor fez; regozijemo-nos e alegremo-nos nele.', 'ref': 'Salmos 118:24', 'book': 'sl', 'chapter': 118, 'verse': 24},
    {'text': 'A tua palavra é lâmpada que ilumina os meus passos e luz que clareia o meu caminho.', 'ref': 'Salmos 119:105', 'book': 'sl', 'chapter': 119, 'verse': 105},
    {'text': 'Elevo os meus olhos para os montes: de onde me virá o socorro? O meu socorro vem do Senhor.', 'ref': 'Salmos 121:1-2', 'book': 'sl', 'chapter': 121, 'verse': 1},
    {'text': 'Louvai ao Senhor porque ele é bom; eterna é a sua misericórdia.', 'ref': 'Salmos 136:1', 'book': 'sl', 'chapter': 136, 'verse': 1},
    {'text': 'Senhor, examinaste e conheces; sabes quando me sento e quando me levanto.', 'ref': 'Salmos 139:1-2', 'book': 'sl', 'chapter': 139, 'verse': 1},
    {'text': 'Maravilhosas são as tuas obras; a minha alma o sabe muito bem.', 'ref': 'Salmos 139:14', 'book': 'sl', 'chapter': 139, 'verse': 14},
    {'text': 'Não se ouviu, nem se viu com os olhos, nem jamais entrou no coração do homem o que Deus preparou para os que o amam.', 'ref': '1 Coríntios 2:9', 'book': '1co', 'chapter': 2, 'verse': 9},
    {'text': 'Portanto, meus amados irmãos, sede firmes, inabaláveis, sempre abundantes na obra do Senhor.', 'ref': '1 Coríntios 15:58', 'book': '1co', 'chapter': 15, 'verse': 58},
    {'text': 'Pelo que, se alguém está em Cristo, nova criatura é; as coisas velhas já passaram; eis que tudo se fez novo.', 'ref': '2 Coríntios 5:17', 'book': '2co', 'chapter': 5, 'verse': 17},
    {'text': 'E a minha graça te basta, porque o meu poder se aperfeiçoa na fraqueza.', 'ref': '2 Coríntios 12:9', 'book': '2co', 'chapter': 12, 'verse': 9},
    {'text': 'Porque pela fé andamos e não pelo que vemos.', 'ref': '2 Coríntios 5:7', 'book': '2co', 'chapter': 5, 'verse': 7},
    {'text': 'Sou crucificado com Cristo; e vivo, não mais eu, mas Cristo vive em mim.', 'ref': 'Gálatas 2:20', 'book': 'gl', 'chapter': 2, 'verse': 20},
    // ── Julho-Agosto / 122-152 ────────────────────────────────────────────
    {'text': 'Bendito seja o Deus e Pai de nosso Senhor Jesus Cristo, que nos abençoou com todas as bênçãos espirituais.', 'ref': 'Efésios 1:3', 'book': 'ef', 'chapter': 1, 'verse': 3},
    {'text': 'Fortalecei-vos no Senhor e na força do seu poder.', 'ref': 'Efésios 6:10', 'book': 'ef', 'chapter': 6, 'verse': 10},
    {'text': 'Tomai toda a armadura de Deus, para que possais resistir no dia mau.', 'ref': 'Efésios 6:13', 'book': 'ef', 'chapter': 6, 'verse': 13},
    {'text': 'Porque Cristo é a nossa paz.', 'ref': 'Efésios 2:14', 'book': 'ef', 'chapter': 2, 'verse': 14},
    {'text': 'Que a paz de Cristo reine em vossos corações.', 'ref': 'Colossenses 3:15', 'book': 'cl', 'chapter': 3, 'verse': 15},
    {'text': 'A palavra de Cristo habite em vós ricamente, em toda a sabedoria.', 'ref': 'Colossenses 3:16', 'book': 'cl', 'chapter': 3, 'verse': 16},
    {'text': 'Fiel é o que vos chama, o qual também o fará.', 'ref': '1 Tessalonicenses 5:24', 'book': '1ts', 'chapter': 5, 'verse': 24},
    {'text': 'O próprio Deus de paz vos santifique em tudo; e o vosso espírito, alma e corpo sejam conservados íntegros.', 'ref': '1 Tessalonicenses 5:23', 'book': '1ts', 'chapter': 5, 'verse': 23},
    {'text': 'Porque há um só Deus e um só Mediador entre Deus e os homens, Jesus Cristo homem.', 'ref': '1 Timóteo 2:5', 'book': '1tm', 'chapter': 2, 'verse': 5},
    {'text': 'A piedade com contentamento é grande ganho.', 'ref': '1 Timóteo 6:6', 'book': '1tm', 'chapter': 6, 'verse': 6},
    {'text': 'Combati o bom combate, acabei a carreira, guardei a fé.', 'ref': '2 Timóteo 4:7', 'book': '2tm', 'chapter': 4, 'verse': 7},
    {'text': 'Se confessarmos nossos pecados, ele é fiel e justo para nos perdoar e nos purificar de toda injustiça.', 'ref': '1 João 1:9', 'book': '1jo', 'chapter': 1, 'verse': 9},
    {'text': 'Todo o amor que existe no mundo vem de Deus, porque Deus é amor.', 'ref': '1 João 4:7', 'book': '1jo', 'chapter': 4, 'verse': 7},
    {'text': 'Aquele que está em vós é maior do que o que está no mundo.', 'ref': '1 João 4:4', 'book': '1jo', 'chapter': 4, 'verse': 4},
    {'text': 'Esta é a vitória que vence o mundo: a nossa fé.', 'ref': '1 João 5:4', 'book': '1jo', 'chapter': 5, 'verse': 4},
    // ── Setembro-Outubro / 153-183 ────────────────────────────────────────
    {'text': 'Bem-aventurado o homem que suporta a tentação; porque, quando for aprovado, receberá a coroa da vida.', 'ref': 'Tiago 1:12', 'book': 'tg', 'chapter': 1, 'verse': 12},
    {'text': 'Toda a boa dádiva e todo o dom perfeito vêm do alto, descendo do Pai das luzes.', 'ref': 'Tiago 1:17', 'book': 'tg', 'chapter': 1, 'verse': 17},
    {'text': 'A fé sem obras é morta.', 'ref': 'Tiago 2:26', 'book': 'tg', 'chapter': 2, 'verse': 26},
    {'text': 'Sujeitai-vos a Deus; resisti ao diabo, e ele fugirá de vós.', 'ref': 'Tiago 4:7', 'book': 'tg', 'chapter': 4, 'verse': 7},
    {'text': 'A oração feita com fé salvará o enfermo.', 'ref': 'Tiago 5:15', 'book': 'tg', 'chapter': 5, 'verse': 15},
    {'text': 'A oração eficaz do justo pode muito.', 'ref': 'Tiago 5:16', 'book': 'tg', 'chapter': 5, 'verse': 16},
    {'text': 'Sede sóbrios e vigilantes. O diabo, vosso adversário, anda em derredor como leão que ruge.', 'ref': '1 Pedro 5:8', 'book': '1pe', 'chapter': 5, 'verse': 8},
    {'text': 'Lançando sobre ele toda a vossa ansiedade, porque ele tem cuidado de vós.', 'ref': '1 Pedro 5:7', 'book': '1pe', 'chapter': 5, 'verse': 7},
    {'text': 'Mas vós sois a geração eleita, o sacerdócio real, a nação santa, o povo adquirido.', 'ref': '1 Pedro 2:9', 'book': '1pe', 'chapter': 2, 'verse': 9},
    {'text': 'O Senhor não retarda a sua promessa; antes, é longânimo para convosco.', 'ref': '2 Pedro 3:9', 'book': '2pe', 'chapter': 3, 'verse': 9},
    {'text': 'Crescei na graça e no conhecimento de nosso Senhor e Salvador Jesus Cristo.', 'ref': '2 Pedro 3:18', 'book': '2pe', 'chapter': 3, 'verse': 18},
    {'text': 'Bendito o Senhor, minha rocha, que adiestra as minhas mãos para a guerra.', 'ref': 'Salmos 144:1', 'book': 'sl', 'chapter': 144, 'verse': 1},
    {'text': 'Alegrai-vos com os que se alegram; chorai com os que choram.', 'ref': 'Romanos 12:15', 'book': 'rm', 'chapter': 12, 'verse': 15},
    {'text': 'O amor não faz mal ao próximo. De sorte que o cumprimento da lei é o amor.', 'ref': 'Romanos 13:10', 'book': 'rm', 'chapter': 13, 'verse': 10},
    {'text': 'Portanto, recebei-vos uns aos outros, como também Cristo nos recebeu para glória de Deus.', 'ref': 'Romanos 15:7', 'book': 'rm', 'chapter': 15, 'verse': 7},
    // ── Novembro-Dezembro / 184-210 ───────────────────────────────────────
    {'text': 'O Senhor é justo em todos os seus caminhos, e santo em todas as suas obras.', 'ref': 'Salmos 145:17', 'book': 'sl', 'chapter': 145, 'verse': 17},
    {'text': 'O Senhor está perto de todos os que o invocam, de todos os que o invocam em verdade.', 'ref': 'Salmos 145:18', 'book': 'sl', 'chapter': 145, 'verse': 18},
    {'text': 'Ele sara os de coração quebrantado e lhes ata as feridas.', 'ref': 'Salmos 147:3', 'book': 'sl', 'chapter': 147, 'verse': 3},
    {'text': 'Louvai a Deus no seu santuário; louvai-o no firmamento do seu poder.', 'ref': 'Salmos 150:1', 'book': 'sl', 'chapter': 150, 'verse': 1},
    {'text': 'Tudo quanto tem fôlego louve ao Senhor. Aleluia!', 'ref': 'Salmos 150:6', 'book': 'sl', 'chapter': 150, 'verse': 6},
    {'text': 'O filho sábio alegra o pai, mas o filho néscio é a tristeza de sua mãe.', 'ref': 'Provérbios 10:1', 'book': 'pv', 'chapter': 10, 'verse': 1},
    {'text': 'A esperança adiada enferma o coração, mas o desejo cumprido é árvore de vida.', 'ref': 'Provérbios 13:12', 'book': 'pv', 'chapter': 13, 'verse': 12},
    {'text': 'A resposta branda desvia o furor, mas a palavra dura suscita a ira.', 'ref': 'Provérbios 15:1', 'book': 'pv', 'chapter': 15, 'verse': 1},
    {'text': 'O coração do homem determina o seu caminho, mas o Senhor lhe dirige os passos.', 'ref': 'Provérbios 16:9', 'book': 'pv', 'chapter': 16, 'verse': 9},
    {'text': 'O amigo verdadeiro ama em todos os tempos, e na adversidade é como um irmão.', 'ref': 'Provérbios 17:17', 'book': 'pv', 'chapter': 17, 'verse': 17},
    {'text': 'Instrui o menino no caminho em que deve andar; e até quando envelhecer não se desviará dele.', 'ref': 'Provérbios 22:6', 'book': 'pv', 'chapter': 22, 'verse': 6},
    {'text': 'Melhor é o fim das coisas do que o seu princípio; melhor é o longânimo do que o altivo de espírito.', 'ref': 'Eclesiastes 7:8', 'book': 'ec', 'chapter': 7, 'verse': 8},
    {'text': 'O temor do Senhor é o princípio da sabedoria.', 'ref': 'Provérbios 9:10', 'book': 'pv', 'chapter': 9, 'verse': 10},
    {'text': 'Gloria in excelsis Deo — Glória a Deus nas alturas, e paz na terra aos homens de boa vontade.', 'ref': 'Lucas 2:14', 'book': 'lc', 'chapter': 2, 'verse': 14},
    {'text': 'Porque um menino nos nasceu, um filho nos foi dado; o governo está sobre os seus ombros.', 'ref': 'Isaías 9:6', 'book': 'is', 'chapter': 9, 'verse': 6},
    {'text': 'Eis que a virgem conceberá e dará à luz um filho, e chamar-se-á o seu nome Emanuel.', 'ref': 'Isaías 7:14', 'book': 'is', 'chapter': 7, 'verse': 14},
    {'text': 'Graças a Deus pelo seu dom inefável!', 'ref': '2 Coríntios 9:15', 'book': '2co', 'chapter': 9, 'verse': 15},
  ];

  static List<ReadingPlan> getReadingPlans() => [
    ReadingPlan(id: 'plan_1year', name: 'Bíblia em 1 Ano', description: '~3 capítulos por dia', totalDays: 365, schedule: []),
    ReadingPlan(id: 'plan_6months', name: 'Bíblia em 6 Meses', description: '~6 capítulos por dia', totalDays: 180, schedule: []),
    ReadingPlan(id: 'plan_nt', name: 'Novo Testamento em 3 Meses', description: '~3 capítulos por dia', totalDays: 90, schedule: []),
  ];

  // Pool de vídeos com termos de busca garantidos no YouTube
  static const List<Map<String, dynamic>> _videoSearchTerms = [
    {
      'title': 'Padre Reginaldo Manzotti - O Amor de Deus',
      'query': 'Padre+Reginaldo+Manzotti+amor+de+Deus+pregação',
      'bookId': 'jo', 'channelName': 'Padre Reginaldo Manzotti',
      'category': 'padre', 'description': 'Uma reflexão sobre o amor incondicional de Deus',
    },
    {
      'title': 'Padre Fábio de Melo - Deus no Silêncio',
      'query': 'Padre+Fábio+de+Melo+Deus+silêncio+pregação',
      'bookId': 'sl', 'channelName': 'Padre Fábio de Melo',
      'category': 'padre', 'description': 'Meditação sobre encontrar Deus no silêncio',
    },
    {
      'title': 'Pastor Cláudio Duarte - Fé que Move Montanhas',
      'query': 'Pastor+Cláudio+Duarte+fé+move+montanhas+pregação',
      'bookId': 'mt', 'channelName': 'Pastor Cláudio Duarte',
      'category': 'pastor', 'description': 'A fé que transforma e move montanhas',
    },
    {
      'title': 'Pastor Lucinho Barreto - A Paz de Deus',
      'query': 'Pastor+Lucinho+Barreto+paz+Filipenses+pregação',
      'bookId': 'fp', 'channelName': 'Pastor Lucinho Barreto',
      'category': 'pastor', 'description': 'Como ter paz em meio às tempestades da vida',
    },
    {
      'title': 'Padre Reginaldo Manzotti - Daniel e o Leão',
      'query': 'Padre+Reginaldo+Manzotti+Daniel+pregação+fé',
      'bookId': 'dn', 'channelName': 'Padre Reginaldo Manzotti',
      'category': 'padre', 'description': 'A fé inabalável de Daniel',
    },
    {
      'title': 'Pastor Cláudio Duarte - O Filho Pródigo',
      'query': 'Pastor+Cláudio+Duarte+filho+pródigo+Lucas+pregação',
      'bookId': 'lc', 'channelName': 'Pastor Cláudio Duarte',
      'category': 'pastor', 'description': 'A parábola do filho pródigo e o amor do Pai',
    },
    {
      'title': 'Padre Fábio de Melo - Esperança nos Salmos',
      'query': 'Padre+Fábio+de+Melo+esperança+Salmos+pregação',
      'bookId': 'sl', 'channelName': 'Padre Fábio de Melo',
      'category': 'padre', 'description': 'Encontrando esperança nos Salmos',
    },
    {
      'title': 'Pastor Samuel Câmara - A Graça em Romanos',
      'query': 'Pastor+Samuel+Câmara+Romanos+graça+pregação',
      'bookId': 'rm', 'channelName': 'Pastor Samuel Câmara',
      'category': 'pastor', 'description': 'O evangelho da graça no livro de Romanos',
    },
    {
      'title': 'Padre Zezinho - Sabedoria dos Provérbios',
      'query': 'Padre+Zezinho+sabedoria+Provérbios+pregação',
      'bookId': 'pv', 'channelName': 'Padre Zezinho',
      'category': 'padre', 'description': 'Reflexão sobre a sabedoria dos Provérbios',
    },
    {
      'title': 'Pastor Lucinho Barreto - Armadura de Deus',
      'query': 'Pastor+Lucinho+Barreto+armadura+Efésios+pregação',
      'bookId': 'ef', 'channelName': 'Pastor Lucinho Barreto',
      'category': 'pastor', 'description': 'Vestindo a armadura espiritual de Deus',
    },
    {
      'title': 'Padre Reginaldo Manzotti - Fé que Move Montanhas',
      'query': 'Padre+Reginaldo+Manzotti+fé+move+montanhas+pregação',
      'bookId': 'mt', 'channelName': 'Padre Reginaldo Manzotti',
      'category': 'padre', 'description': 'A fé que transforma vidas',
    },
    {
      'title': 'Pastor Cláudio Duarte - Fé e Obras em Tiago',
      'query': 'Pastor+Cláudio+Duarte+Tiago+fé+obras+pregação',
      'bookId': 'tg', 'channelName': 'Pastor Cláudio Duarte',
      'category': 'pastor', 'description': 'A relação entre fé e obras em Tiago',
    },
    {
      'title': 'Padre Fábio de Melo - Gênesis A Criação',
      'query': 'Padre+Fábio+de+Melo+Gênesis+criação+pregação',
      'bookId': 'gn', 'channelName': 'Padre Fábio de Melo',
      'category': 'padre', 'description': 'Reflexão sobre a criação do mundo',
    },
    {
      'title': 'Pastor Samuel Câmara - Jesus Sumo Sacerdote',
      'query': 'Pastor+Samuel+Câmara+Hebreus+Jesus+sacerdote+pregação',
      'bookId': 'hb', 'channelName': 'Pastor Samuel Câmara',
      'category': 'pastor', 'description': 'Jesus como Sumo Sacerdote eterno',
    },
  ];

  // Retorna 5 vídeos do dia — muda todo dia automaticamente
  // Usa busca no YouTube (sempre funciona, nunca expira)
  static List<VideoLesson> getVideoLessons() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final offset = (dayOfYear * 3) % _videoSearchTerms.length;
    final result = <VideoLesson>[];
    for (int i = 0; i < 5; i++) {
      final v = _videoSearchTerms[(offset + i) % _videoSearchTerms.length];
      final query = v['query'] as String;
      result.add(VideoLesson(
        id: 'search_${(offset + i) % _videoSearchTerms.length}',
        title: v['title'] as String,
        youtubeId: 'search:$query',
        bookId: v['bookId'] as String,
        duration: '',
        thumbnail: '',
        channelName: v['channelName'] as String,
        category: v['category'] as String,
        description: v['description'] as String,
      ));
    }
    return result;
  }

}
