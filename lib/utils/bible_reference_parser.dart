/// Parser de referências bíblicas com suporte completo a:
/// - Abreviações escritas (Gn, Ex, Jo, Rm...)
/// - Variações faladas / reconhecimento de voz (João, Romanos, Gênesis...)
/// - Nomes com/sem acento
/// - Livros numerados falados ("primeira coríntios", "1 coríntios", "um coríntios")
library bible_reference_parser;

class BibleReference {
  final String bookId;
  final String bookName;
  final int chapter;
  final int? verse;

  const BibleReference({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    this.verse,
  });

  String get displayText =>
      verse != null ? '$bookName $chapter:$verse' : '$bookName $chapter';
}

class BibleReferenceParser {
  // ── Mapa completo: alias → bookId canônico ────────────────────────────────
  // Cobre: abreviações, nomes completos, variações de voz, sem acento, STT artifacts
  static const Map<String, String> _aliases = {
    // ── Antigo Testamento ──────────────────────────────────────────────────

    // Gênesis
    'gn': 'GEN', 'gen': 'GEN', 'genesis': 'GEN', 'gênesis': 'GEN',
    'geneses': 'GEN', 'genêsis': 'GEN',

    // Êxodo
    'ex': 'EXO', 'exo': 'EXO', 'exodo': 'EXO', 'êxodo': 'EXO',
    'exodos': 'EXO',

    // Levítico
    'lv': 'LEV', 'lev': 'LEV', 'levitico': 'LEV', 'levítico': 'LEV',

    // Números
    'nm': 'NUM', 'num': 'NUM', 'numeros': 'NUM', 'números': 'NUM',

    // Deuteronômio
    'dt': 'DEU', 'deu': 'DEU', 'deuteronomio': 'DEU', 'deuteronômio': 'DEU',
    'deuteronomios': 'DEU',

    // Josué
    'js': 'JOS', 'jos': 'JOS', 'josue': 'JOS', 'josué': 'JOS',

    // Juízes
    'jz': 'JDG', 'jdg': 'JDG', 'juizes': 'JDG', 'juízes': 'JDG',

    // Rute
    'rt': 'RUT', 'rut': 'RUT', 'rute': 'RUT',

    // 1 Samuel
    '1sm': '1SA', '1sa': '1SA', 'primeiro samuel': '1SA', '1 samuel': '1SA',
    'um samuel': '1SA', 'hum samuel': '1SA',

    // 2 Samuel
    '2sm': '2SA', '2sa': '2SA', 'segundo samuel': '2SA', '2 samuel': '2SA',
    'dois samuel': '2SA',

    // 1 Reis
    '1rs': '1KI', '1ki': '1KI', 'primeiro reis': '1KI', '1 reis': '1KI',
    'um reis': '1KI', 'hum reis': '1KI',

    // 2 Reis
    '2rs': '2KI', '2ki': '2KI', 'segundo reis': '2KI', '2 reis': '2KI',
    'dois reis': '2KI',

    // 1 Crônicas
    '1cr': '1CH', '1ch': '1CH', 'primeiro cronicas': '1CH',
    'primeira cronicas': '1CH', '1 cronicas': '1CH', '1 crônicas': '1CH',
    'primeiro crônicas': '1CH', 'primeira crônicas': '1CH',
    'um cronicas': '1CH', 'hum cronicas': '1CH',

    // 2 Crônicas
    '2cr': '2CH', '2ch': '2CH', 'segundo cronicas': '2CH',
    'segunda cronicas': '2CH', '2 cronicas': '2CH', '2 crônicas': '2CH',
    'segundo crônicas': '2CH', 'segunda crônicas': '2CH',
    'dois cronicas': '2CH',

    // Esdras
    'ed': 'EZR', 'ezr': 'EZR', 'esdras': 'EZR',

    // Neemias
    'ne': 'NEH', 'neh': 'NEH', 'neemias': 'NEH',

    // Ester
    'et': 'EST', 'est': 'EST', 'ester': 'EST', 'éster': 'EST',

    // Jó
    'jo': 'JOB', 'jb': 'JOB', 'job': 'JOB', 'jó': 'JOB',

    // Salmos
    'sl': 'PSA', 'psa': 'PSA', 'salmos': 'PSA', 'salmo': 'PSA',
    'ps': 'PSA',

    // Provérbios
    'pv': 'PRO', 'pro': 'PRO', 'proverbios': 'PRO', 'provérbios': 'PRO',
    'proverbio': 'PRO',

    // Eclesiastes
    'ec': 'ECC', 'ecc': 'ECC', 'eclesiastes': 'ECC', 'qoheleth': 'ECC',

    // Cânticos
    'ct': 'SNG', 'sng': 'SNG', 'canticos': 'SNG', 'cânticos': 'SNG',
    'cantico dos canticos': 'SNG', 'cântico dos cânticos': 'SNG',
    'cantares': 'SNG',

    // Isaías
    'is': 'ISA', 'isa': 'ISA', 'isaias': 'ISA', 'isaías': 'ISA',

    // Jeremias
    'jr': 'JER', 'jer': 'JER', 'jeremias': 'JER',

    // Lamentações
    'lm': 'LAM', 'lam': 'LAM', 'lamentacoes': 'LAM', 'lamentações': 'LAM',
    'lamentacao': 'LAM',

    // Ezequiel
    'ez': 'EZK', 'ezk': 'EZK', 'ezequiel': 'EZK',

    // Daniel
    'dn': 'DAN', 'dan': 'DAN', 'daniel': 'DAN',

    // Oseias
    'os': 'HOS', 'hos': 'HOS', 'oseias': 'HOS', 'oséias': 'HOS',

    // Joel
    'jl': 'JOL', 'jol': 'JOL', 'joel': 'JOL',

    // Amós
    'am': 'AMO', 'amo': 'AMO', 'amos': 'AMO', 'amós': 'AMO',

    // Obadias
    'ob': 'OBA', 'oba': 'OBA', 'obadias': 'OBA',

    // Jonas
    'jn': 'JON', 'jon': 'JON', 'jonas': 'JON',
    // ⚠️ "joão" também é Jonas para STT quando fala rápido — tratado no normalizador

    // Miquéias
    'mq': 'MIC', 'mic': 'MIC', 'miqueias': 'MIC', 'miquéias': 'MIC',

    // Naum
    'na': 'NAM', 'nam': 'NAM', 'naum': 'NAM',

    // Habacuque
    'hc': 'HAB', 'hab': 'HAB', 'habacuque': 'HAB',

    // Sofonias
    'sf': 'ZEP', 'zep': 'ZEP', 'sofonias': 'ZEP',

    // Ageu
    'ag': 'HAG', 'hag': 'HAG', 'ageu': 'HAG',

    // Zacarias
    'zc': 'ZEC', 'zec': 'ZEC', 'zacarias': 'ZEC',

    // Malaquias
    'ml': 'MAL', 'mal': 'MAL', 'malaquias': 'MAL',

    // ── Novo Testamento ────────────────────────────────────────────────────

    // Mateus
    'mt': 'MAT', 'mat': 'MAT', 'mateus': 'MAT',

    // Marcos
    'mc': 'MRK', 'mrk': 'MRK', 'marcos': 'MRK', 'mk': 'MRK',

    // Lucas
    'lc': 'LUK', 'luk': 'LUK', 'lucas': 'LUK',

    // João (Evangelho) — principal conflito com "Jo" de voz
    // O STT vai falar "João" mesmo que o usuário diga "Jo"
    // A desambiguação João (evangelho) vs Jó (AT) é feita pelo número:
    // - "João 3" → evangelho de João (NT)
    // - "Jó 9"  → livro de Jó (AT)
    // Por padrão sem contexto, "João" → Evangelho de João
    'joao': 'JHN', 'joão': 'JHN', 'jhn': 'JHN', 'evangelho de joao': 'JHN',
    'evangelho de joão': 'JHN',

    // Atos
    'at': 'ACT', 'act': 'ACT', 'atos': 'ACT', 'atos dos apostolos': 'ACT',
    'atos dos apóstolos': 'ACT',

    // Romanos
    'rm': 'ROM', 'rom': 'ROM', 'romanos': 'ROM',

    // 1 Coríntios
    '1co': '1CO', 'primeiro corintios': '1CO', 'primeira corintios': '1CO',
    '1 corintios': '1CO', '1 coríntios': '1CO',
    'primeiro coríntios': '1CO', 'primeira coríntios': '1CO',
    'um corintios': '1CO', 'hum corintios': '1CO',
    'um coríntios': '1CO',

    // 2 Coríntios
    '2co': '2CO', 'segundo corintios': '2CO', 'segunda corintios': '2CO',
    '2 corintios': '2CO', '2 coríntios': '2CO',
    'segundo coríntios': '2CO', 'segunda coríntios': '2CO',
    'dois corintios': '2CO', 'dois coríntios': '2CO',

    // Gálatas
    'gl': 'GAL', 'gal': 'GAL', 'galatas': 'GAL', 'gálatas': 'GAL',

    // Efésios
    'ef': 'EPH', 'eph': 'EPH', 'efesios': 'EPH', 'efésios': 'EPH',

    // Filipenses
    'fp': 'PHP', 'php': 'PHP', 'filipenses': 'PHP', 'fl': 'PHP',

    // Colossenses
    'cl': 'COL', 'col': 'COL', 'colossenses': 'COL',

    // 1 Tessalonicenses
    '1ts': '1TH', '1th': '1TH', 'primeiro tessalonicenses': '1TH',
    '1 tessalonicenses': '1TH', 'um tessalonicenses': '1TH',
    'primeira tessalonicenses': '1TH',

    // 2 Tessalonicenses
    '2ts': '2TH', '2th': '2TH', 'segundo tessalonicenses': '2TH',
    '2 tessalonicenses': '2TH', 'dois tessalonicenses': '2TH',

    // 1 Timóteo
    '1tm': '1TI', '1ti': '1TI', 'primeiro timoteo': '1TI',
    '1 timoteo': '1TI', '1 timóteo': '1TI', 'um timoteo': '1TI',
    'primeiro timóteo': '1TI', 'hum timoteo': '1TI',

    // 2 Timóteo
    '2tm': '2TI', '2ti': '2TI', 'segundo timoteo': '2TI',
    '2 timoteo': '2TI', '2 timóteo': '2TI', 'dois timoteo': '2TI',
    'segundo timóteo': '2TI',

    // Tito
    'tt': 'TIT', 'tit': 'TIT', 'tito': 'TIT',

    // Filemom
    'fm': 'PHM', 'phm': 'PHM', 'filemom': 'PHM', 'filemon': 'PHM',

    // Hebreus
    'hb': 'HEB', 'heb': 'HEB', 'hebreus': 'HEB',

    // Tiago
    'tg': 'JAS', 'jas': 'JAS', 'tiago': 'JAS',

    // 1 Pedro
    '1pe': '1PE', 'primeiro pedro': '1PE', '1 pedro': '1PE',
    'um pedro': '1PE', 'hum pedro': '1PE', 'primeira pedro': '1PE',

    // 2 Pedro
    '2pe': '2PE', 'segundo pedro': '2PE', '2 pedro': '2PE',
    'dois pedro': '2PE',

    // 1 João (epístola)
    '1jo': '1JN', '1jn': '1JN', 'primeiro joao': '1JN', '1 joao': '1JN',
    '1 joão': '1JN', 'primeiro joão': '1JN', 'um joao': '1JN',
    'primeira joao': '1JN', 'primeira joão': '1JN',
    'hum joao': '1JN', 'hum joão': '1JN',

    // 2 João
    '2jo': '2JN', '2jn': '2JN', 'segundo joao': '2JN', '2 joao': '2JN',
    '2 joão': '2JN', 'segundo joão': '2JN', 'dois joao': '2JN',
    'segunda joao': '2JN', 'segunda joão': '2JN',

    // 3 João
    '3jo': '3JN', '3jn': '3JN', 'terceiro joao': '3JN', '3 joao': '3JN',
    '3 joão': '3JN', 'terceiro joão': '3JN', 'tres joao': '3JN',
    'terceira joao': '3JN', 'terceira joão': '3JN',

    // Judas
    'jd': 'JUD', 'jud': 'JUD', 'judas': 'JUD',

    // Apocalipse
    'ap': 'REV', 'rev': 'REV', 'apocalipse': 'REV',
  };

  // ── Nomes canônicos para exibição ─────────────────────────────────────────
  static const Map<String, String> _bookNames = {
    'GEN': 'Gênesis',    'EXO': 'Êxodo',       'LEV': 'Levítico',
    'NUM': 'Números',    'DEU': 'Deuteronômio', 'JOS': 'Josué',
    'JDG': 'Juízes',     'RUT': 'Rute',         '1SA': '1 Samuel',
    '2SA': '2 Samuel',   '1KI': '1 Reis',       '2KI': '2 Reis',
    '1CH': '1 Crônicas', '2CH': '2 Crônicas',   'EZR': 'Esdras',
    'NEH': 'Neemias',    'EST': 'Ester',        'JOB': 'Jó',
    'PSA': 'Salmos',     'PRO': 'Provérbios',   'ECC': 'Eclesiastes',
    'SNG': 'Cânticos',   'ISA': 'Isaías',       'JER': 'Jeremias',
    'LAM': 'Lamentações','EZK': 'Ezequiel',     'DAN': 'Daniel',
    'HOS': 'Oséias',     'JOL': 'Joel',         'AMO': 'Amós',
    'OBA': 'Obadias',    'JON': 'Jonas',        'MIC': 'Miquéias',
    'NAM': 'Naum',       'HAB': 'Habacuque',    'ZEP': 'Sofonias',
    'HAG': 'Ageu',       'ZEC': 'Zacarias',     'MAL': 'Malaquias',
    'MAT': 'Mateus',     'MRK': 'Marcos',       'LUK': 'Lucas',
    'JHN': 'João',       'ACT': 'Atos',         'ROM': 'Romanos',
    '1CO': '1 Coríntios','2CO': '2 Coríntios',  'GAL': 'Gálatas',
    'EPH': 'Efésios',    'PHP': 'Filipenses',   'COL': 'Colossenses',
    '1TH': '1 Tessalonicenses', '2TH': '2 Tessalonicenses',
    '1TI': '1 Timóteo',  '2TI': '2 Timóteo',   'TIT': 'Tito',
    'PHM': 'Filemom',    'HEB': 'Hebreus',      'JAS': 'Tiago',
    '1PE': '1 Pedro',    '2PE': '2 Pedro',
    '1JN': '1 João',     '2JN': '2 João',       '3JN': '3 João',
    'JUD': 'Judas',      'REV': 'Apocalipse',
  };

  // ── Normalizador de texto de voz ──────────────────────────────────────────
  /// Converte texto falado para formato que o parser consegue processar.
  /// Ex: "João três dezesseis" → "João 3:16"
  ///     "primeiro coríntios treze" → "1 Coríntios 13"
  static String normalizeVoiceInput(String input) {
    String s = input.toLowerCase().trim();

    // Remove pontuação desnecessária
    s = s.replaceAll(RegExp(r'[,;.!?]'), ' ');

    // ── Números ordinais/cardinais falados → dígitos ──────────────────────
    const Map<String, String> _numWords = {
      // Ordinais (para livros numerados: "primeiro coríntios" → "1")
      'primeiro': '1', 'primeira': '1', 'hum': '1', 'uma': '1',
      'segundo': '2', 'segunda': '2', 'duas': '2',
      'terceiro': '3', 'terceira': '3', 'tres': '3',
      'quarto': '4', 'quarta': '4',
      // Cardinais (para capítulos e versículos)
      'zero': '0', 'um': '1', 'dois': '2', 'três': '3', 'quatro': '4',
      'cinco': '5', 'seis': '6', 'sete': '7', 'oito': '8', 'nove': '9',
      'dez': '10', 'onze': '11', 'doze': '12', 'treze': '13',
      'quatorze': '14', 'catorze': '14', 'quinze': '15', 'dezesseis': '16',
      'dezessete': '17', 'dezoito': '18', 'dezenove': '19', 'vinte': '20',
      'trinta': '30', 'quarenta': '40', 'cinquenta': '50', 'sessenta': '60',
      'setenta': '70', 'oitenta': '80', 'noventa': '90', 'cem': '100',
      'cento': '100',
    };

    // Substitui ordinais no início (para livros numerados)
    // "primeiro coríntios" → "1 coríntios"
    for (final entry in _numWords.entries) {
      if (RegExp(r'^\b' + entry.key + r'\b').hasMatch(s)) {
        s = s.replaceFirst(
            RegExp(r'^\b' + entry.key + r'\b\s*'), '${entry.value} ');
        break;
      }
    }

    // ── Separador de versículo falado ─────────────────────────────────────
    // "João três vírgula dezesseis" → "João 3:16"
    // "João três dois ponto dezesseis" → "João 3:16"
    // "João capítulo três versículo dezesseis" → "João 3:16"
    s = s.replaceAll(RegExp(r'\bcapítulo\b|\bcapitulo\b'), '');
    s = s.replaceAll(RegExp(r'\bversículo\b|\bversiculo\b'), ':');
    s = s.replaceAll(RegExp(r'\bvírgula\b|\bvirgula\b'), ':');
    s = s.replaceAll(RegExp(r'\bponto\b'), ':');
    s = s.replaceAll(RegExp(r'\be\b'), ' ');  // "três e dezesseis" → "3 16"

    // Substitui números por extenso por dígitos (exceto no início que já foi tratado)
    // Faz em ordem decrescente para evitar conflitos (ex: 'vinte' antes de 'vinte e um')
    final numEntries = _numWords.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in numEntries) {
      s = s.replaceAll(
          RegExp(r'\b' + entry.key + r'\b'), entry.value);
    }

    // Remove espaços múltiplos
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  // ── Parser principal ──────────────────────────────────────────────────────
  /// Recebe texto livre (escrito ou de voz) e retorna BibleReference ou null.
  static BibleReference? parse(String input) {
    if (input.trim().isEmpty) return null;

    // 1. Normaliza voz para texto
    final normalized = normalizeVoiceInput(input);

    // 2. Tenta extrair "Livro Capítulo" ou "Livro Capítulo:Versículo"
    // Regex: captura parte textual + número + (opcional :número)
    final regex = RegExp(
      r'^([\p{L}\s\d]+?)\s+(\d+)(?::(\d+))?$',
      unicode: true,
    );
    final match = regex.firstMatch(normalized.trim());
    if (match == null) return null;

    final rawBook = match.group(1)!.trim().toLowerCase();
    final chapter = int.tryParse(match.group(2)!);
    final verse = match.group(3) != null ? int.tryParse(match.group(3)!) : null;

    if (chapter == null) return null;

    // 3. Resolve o bookId
    final bookId = _resolveBookId(rawBook, chapter);
    if (bookId == null) return null;

    final bookName = _bookNames[bookId] ?? rawBook;

    return BibleReference(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
    );
  }

  /// Resolve o ID canônico do livro a partir do alias.
  /// Usa o número do capítulo para desambiguar "João" (evangelho) vs "Jó" (AT).
  static String? _resolveBookId(String rawBook, int chapter) {
    // Remove acentos para comparação ampla
    final noAccent = _removeAccents(rawBook);

    // Tenta match direto
    String? id = _aliases[rawBook] ?? _aliases[noAccent];
    if (id != null) {
      // ── Desambiguação "João" / "Jo" ──────────────────────────────────────
      // Jó (AT) tem apenas 42 capítulos.
      // João (evangelho NT) tem 21 capítulos.
      // Se o usuário falar "João X" e X <= 42 sem mais contexto, a heurística é:
      //   - X <= 21 → pode ser João (NT) ou Jó (AT) — prefere João (NT) por frequência
      //   - X > 21  → só pode ser Jó (AT)
      if ((rawBook == 'joao' || rawBook == 'joão' || rawBook == 'jo') &&
          id == 'JHN') {
        if (chapter > 21) {
          // Capítulo impossível para João (NT) → provavelmente é Jó
          return 'JOB';
        }
      }
      return id;
    }

    // Tenta match por prefixo (ex: "joão" cobre "joãozinho"? Não — só prefixo exato de livro)
    for (final entry in _aliases.entries) {
      if (noAccent.startsWith(entry.key) || entry.key.startsWith(noAccent)) {
        if ((noAccent.length - entry.key.length).abs() <= 2) {
          return entry.value;
        }
      }
    }

    return null;
  }

  static String _removeAccents(String s) {
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
    const plain   = 'aaaaaaeeeeiiiioooooouuuuyyнс';
    // Mapa manual dos caracteres portugueses
    return s
        .replaceAll('á', 'a').replaceAll('à', 'a').replaceAll('â', 'a')
        .replaceAll('ã', 'a').replaceAll('ä', 'a')
        .replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('è', 'e')
        .replaceAll('í', 'i').replaceAll('î', 'i').replaceAll('ì', 'i')
        .replaceAll('ó', 'o').replaceAll('ô', 'o').replaceAll('õ', 'o')
        .replaceAll('ö', 'o').replaceAll('ò', 'o')
        .replaceAll('ú', 'u').replaceAll('û', 'u').replaceAll('ù', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c').replaceAll('ñ', 'n');
  }
}
