// Models for the Bible app

enum Testament { old, new_ }

enum BibleVersion { acf, arc, ntlh, nviPt }

enum Religion { catholic, evangelical, orthodox }

extension BibleVersionExt on BibleVersion {
  String get displayName {
    switch (this) {
      case BibleVersion.acf:
        return 'ACF - Almeida Corrigida Fiel';
      case BibleVersion.arc:
        return 'ARC - Almeida Revista e Corrigida';
      case BibleVersion.ntlh:
        return 'NTLH - Nova Tradução na Linguagem de Hoje';
      case BibleVersion.nviPt:
        return 'NVI-PT - Nova Versão Internacional';
    }
  }

  String get shortName {
    switch (this) {
      case BibleVersion.acf:
        return 'ACF';
      case BibleVersion.arc:
        return 'ARC';
      case BibleVersion.ntlh:
        return 'NTLH';
      case BibleVersion.nviPt:
        return 'NVI-PT';
    }
  }
}

extension ReligionExt on Religion {
  String get displayName {
    switch (this) {
      case Religion.catholic:
        return 'Católica';
      case Religion.evangelical:
        return 'Evangélica / Protestante';
      case Religion.orthodox:
        return 'Ortodoxa';
    }
  }

  String get description {
    switch (this) {
      case Religion.catholic:
        return 'Inclui deuterocanônicos (Tobias, Judite, Macabeus, etc.)';
      case Religion.evangelical:
        return 'Canon protestante de 66 livros';
      case Religion.orthodox:
        return 'Canon ortodoxo com livros adicionais';
    }
  }

  List<BibleVersion> get availableVersions {
    switch (this) {
      case Religion.catholic:
        return [BibleVersion.acf, BibleVersion.ntlh, BibleVersion.nviPt];
      case Religion.evangelical:
        return [BibleVersion.acf, BibleVersion.arc, BibleVersion.ntlh, BibleVersion.nviPt];
      case Religion.orthodox:
        return [BibleVersion.acf, BibleVersion.ntlh];
    }
  }
}

class BibleBook {
  final String id;
  final String name;
  final String abbreviation;
  final Testament testament;
  final int chapters;
  final int totalVerses;
  final String category;
  final String? description;
  double readingProgress; // 0.0 to 1.0
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'readingProgress': readingProgress,
        'completedChapters': completedChapters,
      };

  factory BibleBook.fromJson(Map<String, dynamic> json, BibleBook base) {
    return BibleBook(
      id: base.id,
      name: base.name,
      abbreviation: base.abbreviation,
      testament: base.testament,
      chapters: base.chapters,
      totalVerses: base.totalVerses,
      category: base.category,
      description: base.description,
      readingProgress: json['readingProgress'] ?? 0.0,
      completedChapters: List<int>.from(json['completedChapters'] ?? []),
    );
  }
}

class BibleVerse {
  final String bookId;
  final int chapter;
  final int verse;
  final String text;
  bool isHighlighted;
  String? highlightColor;
  bool isBookmarked;
  String? note;

  BibleVerse({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    this.isHighlighted = false,
    this.highlightColor,
    this.isBookmarked = false,
    this.note,
  });

  String get reference => '${_bookName(bookId)} $chapter:$verse';

  String _bookName(String id) {
    // Will be resolved from context
    return id;
  }

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'isHighlighted': isHighlighted,
        'highlightColor': highlightColor,
        'isBookmarked': isBookmarked,
        'note': note,
      };
}

class Note {
  final String id;
  String title;
  String content;
  String? verseReference;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;
  String? color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.verseReference,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    this.color,
  }) : tags = tags ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'verseReference': verseReference,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'color': color,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        verseReference: json['verseReference'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        tags: List<String>.from(json['tags'] ?? []),
        color: json['color'],
      );
}

class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final List<DailyReading> dailyReadings;
  int currentDay;
  bool isActive;
  DateTime? startDate;

  ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.dailyReadings,
    this.currentDay = 1,
    this.isActive = false,
    this.startDate,
  });

  double get progress =>
      dailyReadings.where((d) => d.isCompleted).length / dailyReadings.length;
}

class DailyReading {
  final int day;
  final List<ChapterReading> chapters;
  bool isCompleted;
  DateTime? completedAt;

  DailyReading({
    required this.day,
    required this.chapters,
    this.isCompleted = false,
    this.completedAt,
  });
}

class ChapterReading {
  final String bookId;
  final int chapter;
  bool isRead;

  ChapterReading({
    required this.bookId,
    required this.chapter,
    this.isRead = false,
  });
}

class VideoLesson {
  final String id;
  final String title;
  final String youtubeId;
  final String channelName;
  final String thumbnail;
  final String bookId;
  final int? chapter;
  final String description;
  final String category; // 'padre' or 'pastor'

  VideoLesson({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.channelName,
    required this.thumbnail,
    required this.bookId,
    this.chapter,
    required this.description,
    required this.category,
  });
}

// Bible data
class BibleData {
  static List<BibleBook> getBooks() {
    return [
      // OLD TESTAMENT - Pentateuco
      BibleBook(
          id: 'gn', name: 'Gênesis', abbreviation: 'Gn', testament: Testament.old,
          chapters: 50, totalVerses: 1533, category: 'Pentateuco',
          description: 'A criação do mundo e as origens da humanidade'),
      BibleBook(
          id: 'ex', name: 'Êxodo', abbreviation: 'Êx', testament: Testament.old,
          chapters: 40, totalVerses: 1213, category: 'Pentateuco',
          description: 'A libertação do Egito e a Lei de Deus'),
      BibleBook(
          id: 'lv', name: 'Levítico', abbreviation: 'Lv', testament: Testament.old,
          chapters: 27, totalVerses: 859, category: 'Pentateuco'),
      BibleBook(
          id: 'nm', name: 'Números', abbreviation: 'Nm', testament: Testament.old,
          chapters: 36, totalVerses: 1288, category: 'Pentateuco'),
      BibleBook(
          id: 'dt', name: 'Deuteronômio', abbreviation: 'Dt', testament: Testament.old,
          chapters: 34, totalVerses: 959, category: 'Pentateuco'),
      // Históricos
      BibleBook(
          id: 'js', name: 'Josué', abbreviation: 'Js', testament: Testament.old,
          chapters: 24, totalVerses: 658, category: 'Histórico'),
      BibleBook(
          id: 'jz', name: 'Juízes', abbreviation: 'Jz', testament: Testament.old,
          chapters: 21, totalVerses: 618, category: 'Histórico'),
      BibleBook(
          id: 'rt', name: 'Rute', abbreviation: 'Rt', testament: Testament.old,
          chapters: 4, totalVerses: 85, category: 'Histórico'),
      BibleBook(
          id: '1sm', name: '1 Samuel', abbreviation: '1Sm', testament: Testament.old,
          chapters: 31, totalVerses: 810, category: 'Histórico'),
      BibleBook(
          id: '2sm', name: '2 Samuel', abbreviation: '2Sm', testament: Testament.old,
          chapters: 24, totalVerses: 695, category: 'Histórico'),
      BibleBook(
          id: '1rs', name: '1 Reis', abbreviation: '1Rs', testament: Testament.old,
          chapters: 22, totalVerses: 816, category: 'Histórico'),
      BibleBook(
          id: '2rs', name: '2 Reis', abbreviation: '2Rs', testament: Testament.old,
          chapters: 25, totalVerses: 719, category: 'Histórico'),
      BibleBook(
          id: '1cr', name: '1 Crônicas', abbreviation: '1Cr', testament: Testament.old,
          chapters: 29, totalVerses: 942, category: 'Histórico'),
      BibleBook(
          id: '2cr', name: '2 Crônicas', abbreviation: '2Cr', testament: Testament.old,
          chapters: 36, totalVerses: 822, category: 'Histórico'),
      BibleBook(
          id: 'ed', name: 'Esdras', abbreviation: 'Ed', testament: Testament.old,
          chapters: 10, totalVerses: 280, category: 'Histórico'),
      BibleBook(
          id: 'ne', name: 'Neemias', abbreviation: 'Ne', testament: Testament.old,
          chapters: 13, totalVerses: 406, category: 'Histórico'),
      BibleBook(
          id: 'et', name: 'Ester', abbreviation: 'Et', testament: Testament.old,
          chapters: 10, totalVerses: 167, category: 'Histórico'),
      // Poéticos
      BibleBook(
          id: 'jó', name: 'Jó', abbreviation: 'Jó', testament: Testament.old,
          chapters: 42, totalVerses: 1070, category: 'Poético'),
      BibleBook(
          id: 'sl', name: 'Salmos', abbreviation: 'Sl', testament: Testament.old,
          chapters: 150, totalVerses: 2461, category: 'Poético',
          description: 'Cânticos e orações de louvor a Deus'),
      BibleBook(
          id: 'pv', name: 'Provérbios', abbreviation: 'Pv', testament: Testament.old,
          chapters: 31, totalVerses: 915, category: 'Poético'),
      BibleBook(
          id: 'ec', name: 'Eclesiastes', abbreviation: 'Ec', testament: Testament.old,
          chapters: 12, totalVerses: 222, category: 'Poético'),
      BibleBook(
          id: 'ct', name: 'Cânticos', abbreviation: 'Ct', testament: Testament.old,
          chapters: 8, totalVerses: 117, category: 'Poético'),
      // Profetas Maiores
      BibleBook(
          id: 'is', name: 'Isaías', abbreviation: 'Is', testament: Testament.old,
          chapters: 66, totalVerses: 1292, category: 'Profeta Maior',
          description: 'O grande profeta messiânico'),
      BibleBook(
          id: 'jr', name: 'Jeremias', abbreviation: 'Jr', testament: Testament.old,
          chapters: 52, totalVerses: 1364, category: 'Profeta Maior'),
      BibleBook(
          id: 'lm', name: 'Lamentações', abbreviation: 'Lm', testament: Testament.old,
          chapters: 5, totalVerses: 154, category: 'Profeta Maior'),
      BibleBook(
          id: 'ez', name: 'Ezequiel', abbreviation: 'Ez', testament: Testament.old,
          chapters: 48, totalVerses: 1273, category: 'Profeta Maior'),
      BibleBook(
          id: 'dn', name: 'Daniel', abbreviation: 'Dn', testament: Testament.old,
          chapters: 12, totalVerses: 357, category: 'Profeta Maior'),
      // Profetas Menores
      BibleBook(
          id: 'os', name: 'Oséias', abbreviation: 'Os', testament: Testament.old,
          chapters: 14, totalVerses: 197, category: 'Profeta Menor'),
      BibleBook(
          id: 'jl', name: 'Joel', abbreviation: 'Jl', testament: Testament.old,
          chapters: 3, totalVerses: 73, category: 'Profeta Menor'),
      BibleBook(
          id: 'am', name: 'Amós', abbreviation: 'Am', testament: Testament.old,
          chapters: 9, totalVerses: 146, category: 'Profeta Menor'),
      BibleBook(
          id: 'ob', name: 'Obadias', abbreviation: 'Ob', testament: Testament.old,
          chapters: 1, totalVerses: 21, category: 'Profeta Menor'),
      BibleBook(
          id: 'jn', name: 'Jonas', abbreviation: 'Jn', testament: Testament.old,
          chapters: 4, totalVerses: 48, category: 'Profeta Menor'),
      BibleBook(
          id: 'mq', name: 'Miquéias', abbreviation: 'Mq', testament: Testament.old,
          chapters: 7, totalVerses: 105, category: 'Profeta Menor'),
      BibleBook(
          id: 'na', name: 'Naum', abbreviation: 'Na', testament: Testament.old,
          chapters: 3, totalVerses: 47, category: 'Profeta Menor'),
      BibleBook(
          id: 'hc', name: 'Habacuque', abbreviation: 'Hc', testament: Testament.old,
          chapters: 3, totalVerses: 56, category: 'Profeta Menor'),
      BibleBook(
          id: 'sf', name: 'Sofonias', abbreviation: 'Sf', testament: Testament.old,
          chapters: 3, totalVerses: 53, category: 'Profeta Menor'),
      BibleBook(
          id: 'ag', name: 'Ageu', abbreviation: 'Ag', testament: Testament.old,
          chapters: 2, totalVerses: 38, category: 'Profeta Menor'),
      BibleBook(
          id: 'zc', name: 'Zacarias', abbreviation: 'Zc', testament: Testament.old,
          chapters: 14, totalVerses: 211, category: 'Profeta Menor'),
      BibleBook(
          id: 'ml', name: 'Malaquias', abbreviation: 'Ml', testament: Testament.old,
          chapters: 4, totalVerses: 55, category: 'Profeta Menor'),
      // NEW TESTAMENT - Evangelhos
      BibleBook(
          id: 'mt', name: 'Mateus', abbreviation: 'Mt', testament: Testament.new_,
          chapters: 28, totalVerses: 1071, category: 'Evangelho',
          description: 'O Evangelho do Rei Messias'),
      BibleBook(
          id: 'mc', name: 'Marcos', abbreviation: 'Mc', testament: Testament.new_,
          chapters: 16, totalVerses: 678, category: 'Evangelho',
          description: 'O Evangelho do Servo sofredor'),
      BibleBook(
          id: 'lc', name: 'Lucas', abbreviation: 'Lc', testament: Testament.new_,
          chapters: 24, totalVerses: 1151, category: 'Evangelho',
          description: 'O Evangelho do Filho do Homem'),
      BibleBook(
          id: 'jo', name: 'João', abbreviation: 'Jo', testament: Testament.new_,
          chapters: 21, totalVerses: 879, category: 'Evangelho',
          description: 'O Evangelho do Filho de Deus'),
      // Histórico NT
      BibleBook(
          id: 'at', name: 'Atos', abbreviation: 'At', testament: Testament.new_,
          chapters: 28, totalVerses: 1007, category: 'Histórico'),
      // Epístolas Paulinas
      BibleBook(
          id: 'rm', name: 'Romanos', abbreviation: 'Rm', testament: Testament.new_,
          chapters: 16, totalVerses: 433, category: 'Epístola Paulina'),
      BibleBook(
          id: '1co', name: '1 Coríntios', abbreviation: '1Co', testament: Testament.new_,
          chapters: 16, totalVerses: 437, category: 'Epístola Paulina'),
      BibleBook(
          id: '2co', name: '2 Coríntios', abbreviation: '2Co', testament: Testament.new_,
          chapters: 13, totalVerses: 257, category: 'Epístola Paulina'),
      BibleBook(
          id: 'gl', name: 'Gálatas', abbreviation: 'Gl', testament: Testament.new_,
          chapters: 6, totalVerses: 149, category: 'Epístola Paulina'),
      BibleBook(
          id: 'ef', name: 'Efésios', abbreviation: 'Ef', testament: Testament.new_,
          chapters: 6, totalVerses: 155, category: 'Epístola Paulina'),
      BibleBook(
          id: 'fp', name: 'Filipenses', abbreviation: 'Fp', testament: Testament.new_,
          chapters: 4, totalVerses: 104, category: 'Epístola Paulina'),
      BibleBook(
          id: 'cl', name: 'Colossenses', abbreviation: 'Cl', testament: Testament.new_,
          chapters: 4, totalVerses: 95, category: 'Epístola Paulina'),
      BibleBook(
          id: '1ts', name: '1 Tessalonicenses', abbreviation: '1Ts', testament: Testament.new_,
          chapters: 5, totalVerses: 89, category: 'Epístola Paulina'),
      BibleBook(
          id: '2ts', name: '2 Tessalonicenses', abbreviation: '2Ts', testament: Testament.new_,
          chapters: 3, totalVerses: 47, category: 'Epístola Paulina'),
      BibleBook(
          id: '1tm', name: '1 Timóteo', abbreviation: '1Tm', testament: Testament.new_,
          chapters: 6, totalVerses: 113, category: 'Epístola Paulina'),
      BibleBook(
          id: '2tm', name: '2 Timóteo', abbreviation: '2Tm', testament: Testament.new_,
          chapters: 4, totalVerses: 83, category: 'Epístola Paulina'),
      BibleBook(
          id: 'tt', name: 'Tito', abbreviation: 'Tt', testament: Testament.new_,
          chapters: 3, totalVerses: 46, category: 'Epístola Paulina'),
      BibleBook(
          id: 'fm', name: 'Filemom', abbreviation: 'Fm', testament: Testament.new_,
          chapters: 1, totalVerses: 25, category: 'Epístola Paulina'),
      // Epístolas Gerais
      BibleBook(
          id: 'hb', name: 'Hebreus', abbreviation: 'Hb', testament: Testament.new_,
          chapters: 13, totalVerses: 303, category: 'Epístola Geral'),
      BibleBook(
          id: 'tg', name: 'Tiago', abbreviation: 'Tg', testament: Testament.new_,
          chapters: 5, totalVerses: 108, category: 'Epístola Geral'),
      BibleBook(
          id: '1pe', name: '1 Pedro', abbreviation: '1Pe', testament: Testament.new_,
          chapters: 5, totalVerses: 105, category: 'Epístola Geral'),
      BibleBook(
          id: '2pe', name: '2 Pedro', abbreviation: '2Pe', testament: Testament.new_,
          chapters: 3, totalVerses: 61, category: 'Epístola Geral'),
      BibleBook(
          id: '1jo', name: '1 João', abbreviation: '1Jo', testament: Testament.new_,
          chapters: 5, totalVerses: 105, category: 'Epístola Geral'),
      BibleBook(
          id: '2jo', name: '2 João', abbreviation: '2Jo', testament: Testament.new_,
          chapters: 1, totalVerses: 13, category: 'Epístola Geral'),
      BibleBook(
          id: '3jo', name: '3 João', abbreviation: '3Jo', testament: Testament.new_,
          chapters: 1, totalVerses: 15, category: 'Epístola Geral'),
      BibleBook(
          id: 'jd', name: 'Judas', abbreviation: 'Jd', testament: Testament.new_,
          chapters: 1, totalVerses: 25, category: 'Epístola Geral'),
      // Profético NT
      BibleBook(
          id: 'ap', name: 'Apocalipse', abbreviation: 'Ap', testament: Testament.new_,
          chapters: 22, totalVerses: 404, category: 'Profético',
          description: 'A revelação do fim dos tempos e a vitória de Cristo'),
    ];
  }

  static List<Map<String, String>> getDailyVerses() {
    return [
      {'ref': 'João 3:16', 'text': 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.'},
      {'ref': 'Filipenses 4:13', 'text': 'Tudo posso naquele que me fortalece.'},
      {'ref': 'Salmos 23:1', 'text': 'O Senhor é o meu pastor; nada me faltará.'},
      {'ref': 'Isaías 40:31', 'text': 'Mas os que esperam no Senhor renovam as suas forças; sobem com asas como águias; correm, e não se cansam; caminham, e não se fatigam.'},
      {'ref': 'Romanos 8:28', 'text': 'E sabemos que todas as coisas contribuem juntamente para o bem daqueles que amam a Deus.'},
      {'ref': 'Jeremias 29:11', 'text': 'Porque eu bem sei os pensamentos que tenho a vosso respeito, diz o Senhor; pensamentos de paz, e não de mal, para vos dar o fim que esperais.'},
      {'ref': 'Mateus 6:33', 'text': 'Mas buscai primeiro o reino de Deus, e a sua justiça, e todas estas coisas vos serão acrescentadas.'},
      {'ref': 'Provérbios 3:5-6', 'text': 'Confia no Senhor de todo o teu coração, e não te estribes no teu próprio entendimento. Reconhece-o em todos os teus caminhos, e ele endireitará as tuas veredas.'},
      {'ref': 'Salmos 46:1', 'text': 'Deus é o nosso refúgio e força, socorro bem presente na angústia.'},
      {'ref': 'Efésios 2:8', 'text': 'Porque pela graça sois salvos, por meio da fé; e isto não vem de vós; é dom de Deus.'},
    ];
  }

  static List<VideoLesson> getVideoLessons() {
    return [
      VideoLesson(
        id: 'v1',
        title: 'Padre Reginaldo Manzotti - O Amor de Deus em João 3:16',
        youtubeId: 'dQw4w9WgXcQ',
        channelName: 'Padre Reginaldo Manzotti',
        thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        bookId: 'jo',
        chapter: 3,
        description: 'Uma reflexão profunda sobre o amor incondicional de Deus',
        category: 'padre',
      ),
      VideoLesson(
        id: 'v2',
        title: 'Padre Fábio de Melo - Salmos: A Oração do Coração',
        youtubeId: 'dQw4w9WgXcQ',
        channelName: 'Padre Fábio de Melo',
        thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        bookId: 'sl',
        description: 'Meditação sobre os Salmos e a vida de oração',
        category: 'padre',
      ),
      VideoLesson(
        id: 'v3',
        title: 'Pastor Cláudio Duarte - Gênesis: A Criação',
        youtubeId: 'dQw4w9WgXcQ',
        channelName: 'Pastor Cláudio Duarte',
        thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        bookId: 'gn',
        chapter: 1,
        description: 'Entendendo a criação do mundo através de Gênesis',
        category: 'pastor',
      ),
      VideoLesson(
        id: 'v4',
        title: 'Lucinho Barreto - Apocalipse: O Retorno de Cristo',
        youtubeId: 'dQw4w9WgXcQ',
        channelName: 'Lucinho Barreto',
        thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        bookId: 'ap',
        description: 'Estudo profético sobre o livro do Apocalipse',
        category: 'pastor',
      ),
    ];
  }
}
