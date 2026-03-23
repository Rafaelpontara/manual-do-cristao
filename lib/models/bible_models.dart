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
    {'text': 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito.', 'ref': 'João 3:16', 'book': 'jo', 'chapter': 3, 'verse': 16},
    {'text': 'O Senhor é o meu pastor; nada me faltará.', 'ref': 'Salmos 23:1', 'book': 'sl', 'chapter': 23, 'verse': 1},
    {'text': 'Tudo posso naquele que me fortalece.', 'ref': 'Filipenses 4:13', 'book': 'fp', 'chapter': 4, 'verse': 13},
    {'text': 'Porque para Deus não há nada impossível.', 'ref': 'Lucas 1:37', 'book': 'lc', 'chapter': 1, 'verse': 37},
    {'text': 'Confia no Senhor de todo o teu coração, e não te estribes no teu próprio entendimento.', 'ref': 'Provérbios 3:5', 'book': 'pv', 'chapter': 3, 'verse': 5},
    {'text': 'Buscai primeiro o reino de Deus e a sua justiça, e todas estas coisas vos serão acrescentadas.', 'ref': 'Mateus 6:33', 'book': 'mt', 'chapter': 6, 'verse': 33},
    {'text': 'Não andeis ansiosos por coisa alguma; antes as vossas petições sejam em tudo conhecidas diante de Deus.', 'ref': 'Filipenses 4:6', 'book': 'fp', 'chapter': 4, 'verse': 6},
    {'text': 'A paz de Deus, que excede todo o entendimento, guardará os vossos corações.', 'ref': 'Filipenses 4:7', 'book': 'fp', 'chapter': 4, 'verse': 7},
    {'text': 'Sede fortes e corajosos. Não temais, nem vos assusteis.', 'ref': 'Deuteronômio 31:6', 'book': 'dt', 'chapter': 31, 'verse': 6},
    {'text': 'O amor é paciente, o amor é bondoso. O amor não inveja, não se vangloria.', 'ref': '1 Coríntios 13:4', 'book': '1co', 'chapter': 13, 'verse': 4},
    {'text': 'Eu sou o caminho, e a verdade, e a vida; ninguém vem ao Pai senão por mim.', 'ref': 'João 14:6', 'book': 'jo', 'chapter': 14, 'verse': 6},
    {'text': 'Porque pela graça sois salvos, por meio da fé; e isso não vem de vós; é dom de Deus.', 'ref': 'Efésios 2:8', 'book': 'ef', 'chapter': 2, 'verse': 8},
  ];

  static List<ReadingPlan> getReadingPlans() => [
    ReadingPlan(id: 'plan_1year', name: 'Bíblia em 1 Ano', description: '~3 capítulos por dia', totalDays: 365, schedule: []),
    ReadingPlan(id: 'plan_6months', name: 'Bíblia em 6 Meses', description: '~6 capítulos por dia', totalDays: 180, schedule: []),
    ReadingPlan(id: 'plan_nt', name: 'Novo Testamento em 3 Meses', description: '~3 capítulos por dia', totalDays: 90, schedule: []),
  ];

  // Pool de vídeos — usa busca no YouTube para garantir que funcionem
  static final List<Map<String, dynamic>> _videoSearchTerms = [
    {'title': 'Padre Reginaldo Manzotti - O Amor de Deus', 'query': 'Padre+Reginaldo+Manzotti+amor+de+Deus+pregação', 'bookId': 'jo', 'channelName': 'Padre Reginaldo Manzotti', 'category': 'padre', 'description': 'Uma reflexão sobre o amor incondicional de Deus'},
    {'title': 'Padre Fábio de Melo - Salmos e Oração', 'query': 'Padre+Fábio+de+Melo+Salmos+oração', 'bookId': 'sl', 'channelName': 'Padre Fábio de Melo', 'category': 'padre', 'description': 'Meditação sobre os Salmos e a vida de oração'},
    {'title': 'Pastor Cláudio Duarte - Gênesis A Criação', 'query': 'Pastor+Cláudio+Duarte+Gênesis+criação+pregação', 'bookId': 'gn', 'channelName': 'Pastor Cláudio Duarte', 'category': 'pastor', 'description': 'Estudo bíblico sobre a criação do mundo'},
    {'title': 'Pastor Lucinho Barreto - A Paz de Deus', 'query': 'Pastor+Lucinho+Barreto+paz+de+Deus+Filipenses', 'bookId': 'fp', 'channelName': 'Pastor Lucinho Barreto', 'category': 'pastor', 'description': 'Como ter paz em meio às tempestades da vida'},
    {'title': 'Padre Zezinho - Sabedoria de Deus', 'query': 'Padre+Zezinho+sabedoria+Provérbios+pregação', 'bookId': 'pv', 'channelName': 'Padre Zezinho', 'category': 'padre', 'description': 'Reflexão sobre a sabedoria dos Provérbios'},
    {'title': 'Pastor Samuel Câmara - A Graça em Romanos', 'query': 'Pastor+Samuel+Câmara+Romanos+graça+pregação', 'bookId': 'rm', 'channelName': 'Pastor Samuel Câmara', 'category': 'pastor', 'description': 'O evangelho da graça no livro de Romanos'},
    {'title': 'Padre Reginaldo Manzotti - Fé que Move Montanhas', 'query': 'Padre+Reginaldo+Manzotti+fé+move+montanhas', 'bookId': 'mt', 'channelName': 'Padre Reginaldo Manzotti', 'category': 'padre', 'description': 'A fé que transforma vidas'},
    {'title': 'Pastor Cláudio Duarte - O Filho Pródigo', 'query': 'Pastor+Cláudio+Duarte+filho+pródigo+Lucas', 'bookId': 'lc', 'channelName': 'Pastor Cláudio Duarte', 'category': 'pastor', 'description': 'A parábola do filho pródigo e o amor do Pai'},
    {'title': 'Padre Fábio de Melo - Esperança no Apocalipse', 'query': 'Padre+Fábio+de+Melo+esperança+Apocalipse', 'bookId': 'ap', 'channelName': 'Padre Fábio de Melo', 'category': 'padre', 'description': 'Entendendo o livro do Apocalipse'},
    {'title': 'Pastor Lucinho Barreto - Armadura de Deus', 'query': 'Pastor+Lucinho+Barreto+armadura+Deus+Efésios', 'bookId': 'ef', 'channelName': 'Pastor Lucinho Barreto', 'category': 'pastor', 'description': 'Vistindo a armadura espiritual de Deus'},
    {'title': 'Padre Zezinho - Isaías O Servo Sofredor', 'query': 'Padre+Zezinho+Isaías+servo+sofredor+pregação', 'bookId': 'is', 'channelName': 'Padre Zezinho', 'category': 'padre', 'description': 'A profecia do servo sofredor em Isaías 53'},
    {'title': 'Pastor Samuel Câmara - Jesus Sumo Sacerdote', 'query': 'Pastor+Samuel+Câmara+Hebreus+Jesus+sacerdote', 'bookId': 'hb', 'channelName': 'Pastor Samuel Câmara', 'category': 'pastor', 'description': 'Jesus como Sumo Sacerdote eterno'},
    {'title': 'Padre Reginaldo Manzotti - Daniel e o Leão', 'query': 'Padre+Reginaldo+Manzotti+Daniel+pregação+fé', 'bookId': 'dn', 'channelName': 'Padre Reginaldo Manzotti', 'category': 'padre', 'description': 'A fé inabalável de Daniel'},
    {'title': 'Pastor Cláudio Duarte - Fé e Obras em Tiago', 'query': 'Pastor+Cláudio+Duarte+Tiago+fé+obras+pregação', 'bookId': 'tg', 'channelName': 'Pastor Cláudio Duarte', 'category': 'pastor', 'description': 'A relação entre fé e obras em Tiago'},
  ];

  // Retorna 5 vídeos do dia — muda todo dia automaticamente
  static List<VideoLesson> getVideoLessons() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final offset = (dayOfYear * 3) % _videoSearchTerms.length;
    final result = <VideoLesson>[];
    for (int i = 0; i < 5; i++) {
      final v = _videoSearchTerms[(offset + i) % _videoSearchTerms.length];
      final query = v['query'] as String;
      // Usa busca do YouTube como ID para garantir que sempre funcione
      result.add(VideoLesson(
        id: 'search_${(offset + i) % _videoSearchTerms.length}',
        title: v['title'] as String,
        youtubeId: 'search:$query', // Marcador especial para busca
        bookId: v['bookId'] as String,
        duration: '',
        thumbnail: 'https://img.youtube.com/vi/search/mqdefault.jpg',
        channelName: v['channelName'] as String,
        category: v['category'] as String,
        description: v['description'] as String,
      ));
    }
    return result;
  }

}
