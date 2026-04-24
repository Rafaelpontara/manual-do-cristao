import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/bible_models.dart';
import '../providers/app_provider.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';
import '../utils/bible_reference_parser.dart';
import 'chapter_reader_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _searched = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _listenedWords = '';

  final List<String> _suggestions = [
    'amor', 'paz', 'fé', 'esperança', 'graça',
    'salvação', 'perdão', 'oração', 'força', 'alegria',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(widget.initialQuery!));
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (mounted && (status == 'done' || status == 'notListening')) {
          final words = _listenedWords;
          setState(() => _isListening = false);
          // Aguarda um momento antes de buscar para garantir que o resultado final chegou
          if (words.isNotEmpty && !_searched) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !_searched) {
                final normalized = BibleReferenceParser.normalizeVoiceInput(words);
                _controller.text = normalized;
                _search(normalized);
              }
            });
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _startVoiceSearch() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconhecimento de voz não disponível neste dispositivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
      _listenedWords = '';
      _searched = false;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _listenedWords = result.recognizedWords;
          _controller.text = _listenedWords;
        });
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() => _isListening = false);
          // Normaliza voz antes de buscar (Jo→Jó/João, números por extenso)
          final normalized = BibleReferenceParser.normalizeVoiceInput(
              result.recognizedWords);
          _controller.text = normalized;
          _search(normalized);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'pt_BR',
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    // Detecta referência bíblica (ex: "João 3:16", "Jó 9", "Salmos 23")
    final reference = BibleReferenceParser.parse(query.trim());
    if (reference != null) {
      _openBibleReference(reference);
      return;
    }

    setState(() { _loading = true; _searched = true; });
    final provider = Provider.of<AppProvider>(context, listen: false);
    final results = await BibleService.searchVerses(query.trim(), provider.bibleVersion);
    setState(() { _results = results; _loading = false; });
  }

  void _openBibleReference(BibleReference ref) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final books = provider.books;

    BibleBook? book;
    try {
      book = books.firstWhere((b) => b.id == ref.bookId);
    } catch (_) {
      // Livro não encontrado — faz busca normal
      setState(() { _loading = true; _searched = true; });
      BibleService.searchVerses(ref.bookName, provider.bibleVersion).then((results) {
        if (mounted) setState(() { _results = results; _loading = false; });
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(
          book: book!,
          chapter: ref.chapter.clamp(1, book.chapters),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📖 Abrindo ${ref.displayText}'),
        backgroundColor: AppTheme.goldPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Buscar Versículos',
            style: GoogleFonts.playfairDisplay(
                color: AppTheme.goldPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Barra de busca ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Buscar por palavra, tema ou versículo...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _controller.clear();
                              setState(() { _results = []; _searched = false; _listenedWords = ''; });
                            })
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _search(_controller.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  minimumSize: Size.zero,
                ),
                child: const Icon(Icons.search_rounded, size: 20),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _startVoiceSearch,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFE84393), const Color(0xFFC00000)]
                          : _speechAvailable
                              ? [const Color(0xFF5B6EF5), const Color(0xFF7B4FE0)]
                              : [Colors.grey, Colors.grey],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isListening ? [
                      BoxShadow(
                        color: const Color(0xFFE84393).withOpacity(0.5),
                        blurRadius: 12, spreadRadius: 2,
                      )
                    ] : [],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white, size: 22),
                ),
              ),
            ]),
          ),

          // ── Banner de escuta ────────────────────────────────────────────
          if (_isListening)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE84393).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE84393).withOpacity(0.4)),
              ),
              child: Row(children: [
                const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE84393))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _listenedWords.isEmpty ? 'Ouvindo... fale agora 🎤' : '"$_listenedWords"',
                    style: TextStyle(
                      color: _listenedWords.isEmpty ? const Color(0xFFE84393) : AppTheme.goldPrimary,
                      fontSize: 13,
                      fontStyle: _listenedWords.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _speech.stop();
                    setState(() => _isListening = false);
                  },
                  child: const Icon(Icons.stop_circle_rounded, color: Color(0xFFE84393), size: 20),
                ),
              ]),
            ),

          // ── Sugestões ───────────────────────────────────────────────────
          if (!_searched && !_isListening) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Temas populares',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontSize: 13, color: AppTheme.warmGray)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _suggestions.map((s) => GestureDetector(
                    onTap: () { _controller.text = s; _search(s); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                      ),
                      child: Text(s, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 13)),
                    ),
                  )).toList(),
                ),
              ]),
            ),
          ],

          // ── Loading ─────────────────────────────────────────────────────
          if (_loading)
            const Expanded(child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircularProgressIndicator(color: AppTheme.goldPrimary),
                SizedBox(height: 16),
                Text('Buscando versículos...', style: TextStyle(color: AppTheme.warmGray)),
              ]),
            )),

          // ── Sem resultados ──────────────────────────────────────────────
          if (_searched && !_loading && _results.isEmpty)
            Expanded(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.search_off_rounded, color: AppTheme.warmGray, size: 48),
              const SizedBox(height: 16),
              Text('Nenhum versículo encontrado',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Tente outro termo ou palavra-chave',
                  style: Theme.of(context).textTheme.bodySmall),
            ]))),

          // ── Resultados ──────────────────────────────────────────────────
          if (!_loading && _results.isNotEmpty)
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${_results.length} resultado(s) encontrado(s)',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppTheme.goldPrimary)),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _buildResultCard(context, _results[i], isDark),
                ),
              ),
            ])),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> r, bool isDark) {
    final ref = r['reference'] ?? '';
    final text = r['text'] ?? '';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(ref, style: const TextStyle(
                color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Text('"$text"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic, height: 1.7,
                color: isDark ? AppTheme.creamWhite : AppTheme.navyDeep,
              )),
          const SizedBox(height: 12),
          Row(children: [
            const Spacer(),
            _iconBtn(Icons.copy_rounded, 'Copiar', () {
              Clipboard.setData(ClipboardData(text: '"$text"\n— $ref'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Versículo copiado!')));
            }),
            const SizedBox(width: 8),
            _iconBtn(Icons.share_rounded, 'Compartilhar', () {
              Share.share('"$text"\n— $ref\n\n🕊️ Manual do Cristão');
            }),
          ]),
        ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.goldPrimary, size: 16),
        ),
      ),
    );
  }
}
