import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';

class AiService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  // Cadastre em https://console.anthropic.com → cole sua chave aqui
  static const String _apiKey = 'SUA_CHAVE_ANTHROPIC_AQUI';

  static String _buildSystemPrompt(Religion religion) => '''
Você é "Luz", um assistente bíblico espiritual e acolhedor, especializado em teologia e hermenêutica.
Responda sempre em português brasileiro, de forma profunda, edificante e amorosa.
Contexto religioso do usuário: ${religion.displayName} — ${religion.aiContext}
Baseie-se nas Escrituras. Seja conciso (máx. 3 parágrafos). Nunca invente versículos.
Use emojis com moderação para tornar a leitura mais amigável.
''';

  // ── Chat bíblico ───────────────────────────────────────────────────────────
  static Future<String> chat(List<Map<String, String>> history, Religion religion) async {
    return await _call(history, religion);
  }

  // ── Explicar versículo ─────────────────────────────────────────────────────
  static Future<String> explainVerse(String reference, String text, Religion religion) async {
    final prompt = '''Explique este versículo considerando a perspectiva ${religion.displayName}:

"$text" — $reference

Inclua: contexto histórico, significado teológico e aplicação prática para hoje.''';
    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Resumo de capítulo ─────────────────────────────────────────────────────
  static Future<String> summarizeChapter(String bookName, int chapter,
      List<Map<String, String>> verses, Religion religion) async {
    final verseText = verses.take(20).map((v) => '${v['verse']}. ${v['text']}').join('\n');
    final prompt = '''Faça um resumo espiritual de $bookName capítulo $chapter (perspectiva ${religion.displayName}).
Destaque temas principais, personagens e aplicações práticas.

Versículos:
$verseText''';
    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Sugestão por sentimento ────────────────────────────────────────────────
  static Future<String> suggestByMood(String mood, Religion religion) async {
    final prompt = '''Estou me sentindo: $mood

Considerando a perspectiva ${religion.displayName}, sugira 3 versículos bíblicos que me confortem.
Para cada um: referência, texto e breve explicação personalizada para este momento.''';
    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Comparação de versículos entre versões ────────────────────────────────
  static Future<String> compareVersions({
    required String reference,
    required String bookName,
    required int chapter,
    required int verse,
    required Map<String, String> versionTexts,
    required Religion religion,
  }) async {
    final versionsText = versionTexts.entries
        .map((e) => '**${e.key}:** "${e.value}"')
        .join('\n\n');

    final prompt = '''Compare as seguintes traduções de $reference na perspectiva ${religion.displayName}:

$versionsText

Analise:
1. Diferenças de tradução e suas implicações teológicas
2. Qual versão é mais fiel ao texto original (hebraico/grego)
3. Qual versão é mais acessível para leitura devocional
4. Recomendação baseada na tradição ${religion.displayName}''';

    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Plano de leitura personalizado por IA ────────────────────────────────
  static Future<String> generateReadingPlan({
    required String goal,
    required int daysAvailable,
    required int minutesPerDay,
    required Religion religion,
    required List<String> preferredBooks,
  }) async {
    final books = preferredBooks.isEmpty ? 'todos os livros' : preferredBooks.join(', ');
    final prompt = '''Crie um plano de leitura bíblica personalizado com estas características:

- Objetivo: $goal
- Dias disponíveis: $daysAvailable dias
- Tempo diário: $minutesPerDay minutos por dia
- Tradição: ${religion.displayName}
- Livros de interesse: $books

Forneça:
1. Nome do plano e descrição motivacional
2. Estrutura semanal detalhada (quais livros/capítulos por dia)
3. Como os livros foram escolhidos para este objetivo
4. Dicas para manter a consistência
5. Versículo motivacional para começar

Formato o plano de forma prática e fácil de seguir.''';

    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Oração personalizada ──────────────────────────────────────────────────
  static Future<String> generatePrayer(String intention, Religion religion) async {
    final prompt = '''Crie uma oração personalizada para esta intenção: $intention

Baseada na tradição ${religion.displayName}, usando linguagem contemporânea e acolhedora.
Inclua versículos bíblicos relevantes.''';
    return await _call([{'role': 'user', 'content': prompt}], religion);
  }

  // ── Chamada à API Anthropic ────────────────────────────────────────────────
  static Future<String> _call(List<Map<String, String>> messages, Religion religion) async {
    if (_apiKey == 'SUA_CHAVE_ANTHROPIC_AQUI') {
      return _mockResponse(messages.last['content'] ?? '', religion);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 1024,
          'system': _buildSystemPrompt(religion),
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['content'][0]['text'] as String;
      }
      return '⚠️ Não consegui me conectar. Tente novamente em instantes.';
    } catch (e) {
      return '⚠️ Erro de conexão. Verifique sua internet.';
    }
  }

  // ── Respostas demo (sem chave) ─────────────────────────────────────────────
  static String _mockResponse(String input, Religion religion) {
    final lower = input.toLowerCase();
    final relName = religion.displayName;

    if (lower.contains('compar')) {
      return '''📊 **Comparação de Traduções** — perspectiva $relName

**ACF (Almeida Corrigida Fiel):**
Mais literal ao texto original grego/hebraico. Preserva termos teológicos precisos. Ideal para estudo aprofundado.

**ARC (Almeida Revista e Corrigida):**
Versão modernizada da ACF. Mais fluente para leitura devocional. A mais popular no Brasil evangélico.

**NVI-PT:**
Tradução dinâmica equivalente. Linguagem contemporânea e acessível. Ótima para novos leitores.

**Recomendação para $relName:**
Para estudo: ACF • Para devoção diária: ARC ou NVI-PT

> *Ative a IA completa em ai_service.dart para comparações detalhadas de qualquer versículo.*''';
    }

    if (lower.contains('plano')) {
      return '''📅 **Plano de Leitura Personalizado** — $relName

**📖 Plano: Fundamentos da Fé**
*30 dias • ~20 minutos por dia*

**Semana 1 — Criação e Promessas**
Seg: Gênesis 1-2 | Ter: Gênesis 3-4 | Qua: Gênesis 12-15
Qui: Salmos 1, 8, 23 | Sex: João 1-3 | Sáb: João 14-17

**Semana 2 — A Vida de Jesus**
Seg-Sex: Evangelho de Lucas (5 cap/dia) | Sáb: Atos 1-2

**Semana 3 — Cartas Apostólicas**
Romanos, Efésios, Filipenses (3 cap/dia)

**Semana 4 — Sabedoria e Profecia**
Provérbios selecionados + Isaías 40-55 + Apocalipse 1-5

💡 *Dica: Leia de manhã para começar o dia com a Palavra.*

> *Configure sua chave em ai_service.dart para planos totalmente personalizados.*''';
    }

    if (lower.contains('sinto') || lower.contains('sentindo')) {
      return '''🙏 **Versículos para este momento** — $relName

**1. 📖 Filipenses 4:6-7**
"Não andeis ansiosos por coisa alguma... e a paz de Deus guardará os vossos corações."
*Entregue suas preocupações a Deus em oração.*

**2. 📖 Salmos 34:18**
"O Senhor está perto dos que têm o coração quebrantado."
*Você não está sozinho neste momento.*

**3. 📖 Isaías 41:10**
"Não temas, porque eu sou contigo; não te assombres, porque eu sou teu Deus."
*A força de Deus sustenta você agora.*

> *Ative a IA para sugestões totalmente personalizadas ao seu momento.*''';
    }

    return '''✨ Olá! Sou a **Luz**, sua assistente bíblica com IA.

Estou configurada para a tradição **$relName** e posso te ajudar com:

• 💬 **Chat bíblico** — tire dúvidas sobre passagens e teologia
• 🎭 **Versículos por humor** — baseados em como você está se sentindo  
• 📊 **Comparar versões** — análise de diferentes traduções
• 📅 **Plano personalizado** — roteiro de leitura sob medida

Como posso te ajudar hoje?

> *Para respostas completas de IA, configure sua chave em ai_service.dart*''';
  }
}
