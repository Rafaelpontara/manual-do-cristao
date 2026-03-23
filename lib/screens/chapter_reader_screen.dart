import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../services/offline_service.dart';
import '../services/bible_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class ChapterReaderScreen extends StatefulWidget {
  final BibleBook book;
  final int chapter;
  const ChapterReaderScreen({Key? key, required this.book, required this.chapter}) : super(key: key);
  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  List<Map<String, String>> _verses = [];
  bool _isLoading = true;
  int? _selectedVerse;
  late int _currentChapter;
  bool _isSpeaking = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadChapter();
    TtsService.onComplete(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    TtsService.stop();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    setState(() { _isLoading = true; _verses = []; });
    final provider = Provider.of<AppProvider>(context, listen: false);
    final version = provider.bibleVersion.shortName;

    // Try offline cache first
    final cached = await OfflineService.getChapter(widget.book.id, _currentChapter, version);
    if (cached != null) {
      if (mounted) setState(() { _verses = cached; _isLoading = false; });
      return;
    }

    // Fetch from API
    final verses = await BibleService.getChapterVerses(
        widget.book.id, _currentChapter, provider.bibleVersion);

    // Save to offline cache automatically
    if (verses.isNotEmpty) {
      await OfflineService.saveChapter(widget.book.id, _currentChapter, version, verses);
    }

    if (mounted) setState(() { _verses = verses; _isLoading = false; });
  }

  void _nextChapter() {
    if (_currentChapter < widget.book.chapters) {
      _markRead();
      setState(() { _currentChapter++; _selectedVerse = null; });
      _scrollController.jumpTo(0);
      _loadChapter();
    }
  }

  void _prevChapter() {
    if (_currentChapter > 1) {
      setState(() { _currentChapter--; _selectedVerse = null; });
      _scrollController.jumpTo(0);
      _loadChapter();
    }
  }

  void _markRead() {
    Provider.of<AppProvider>(context, listen: false)
        .markChapterRead(widget.book.id, _currentChapter);
  }

  Future<void> _toggleTTS() async {
    if (_isSpeaking) {
      await TtsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await TtsService.speakVerses(_verses);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final fontSize = provider.readingFontSize.toDouble();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      body: Stack(children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text('${widget.book.name} $_currentChapter', style: GoogleFonts.playfairDisplay(color: AppTheme.goldPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                // YouTube search
                IconButton(
                  icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.red, size: 22),
                  tooltip: 'Buscar vídeos no YouTube',
                  onPressed: () => _searchYouTube(context),
                ),
                // TTS button
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: _isSpeaking ? AppTheme.crimsonAccent : AppTheme.goldPrimary,
                    size: 22,
                  ),
                  onPressed: _verses.isEmpty ? null : _toggleTTS,
                  tooltip: _isSpeaking ? 'Parar leitura' : 'Ouvir capítulo',
                ),
                // Font size
                IconButton(
                  icon: const Icon(Icons.text_fields_rounded, size: 20),
                  onPressed: () => _showFontDialog(context, provider),
                ),
                // Version
                GestureDetector(
                  onTap: () => _showVersionDialog(context, provider),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(provider.bibleVersion.shortName,
                        style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // TTS banner quando tocando
            if (_isSpeaking)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppTheme.forestGreen.withOpacity(0.15),
                  child: Row(children: [
                    const Icon(Icons.volume_up_rounded, color: AppTheme.forestGreen, size: 16),
                    const SizedBox(width: 8),
                    Text('Lendo em voz alta...', style: TextStyle(color: AppTheme.forestGreen, fontSize: 13)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleTTS,
                      child: const Icon(Icons.stop_rounded, color: AppTheme.forestGreen, size: 18),
                    ),
                  ]),
                ),
              ),

            if (_isLoading)
              const SliverFillRemaining(child: Center(
                child: CircularProgressIndicator(color: AppTheme.goldPrimary),
              ))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final verse = _verses[i];
                      final verseNum = int.tryParse(verse['verse'] ?? '1') ?? (i + 1);
                      final isSelected = _selectedVerse == verseNum;
                      final isHighlighted = provider.isHighlighted(widget.book.id, _currentChapter, verseNum);
                      final hlColor = provider.getHighlightColor(widget.book.id, _currentChapter, verseNum);
                      final isBookmarked = provider.isBookmarked(widget.book.id, _currentChapter, verseNum);

                      return GestureDetector(
                        onTap: () => setState(() => _selectedVerse = isSelected ? null : verseNum),
                        onLongPress: () {
                          setState(() => _selectedVerse = verseNum);
                          _showVerseOptions(context, provider, verseNum, verse['text'] ?? '');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.goldPrimary.withOpacity(0.1)
                                : isHighlighted
                                    ? _hlBg(hlColor)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: AppTheme.goldPrimary.withOpacity(0.3))
                                : null,
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              width: 28,
                              child: Text('$verseNum',
                                  style: TextStyle(color: AppTheme.goldPrimary, fontSize: fontSize * 0.65, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(verse['text'] ?? '',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.creamWhite : AppTheme.navyDeep,
                                    fontSize: fontSize, height: 1.8,
                                  )),
                            ),
                            if (isBookmarked)
                              const Padding(
                                padding: EdgeInsets.only(left: 4, top: 4),
                                child: Icon(Icons.bookmark_rounded, color: AppTheme.goldPrimary, size: 14),
                              ),
                          ]),
                        ),
                      );
                    },
                    childCount: _verses.length,
                  ),
                ),
              ),
          ],
        ),

        // Navegação inferior
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [(isDark ? AppTheme.navyDeep : AppTheme.creamLight).withOpacity(0),
                         isDark ? AppTheme.navyDeep : AppTheme.creamLight],
              ),
            ),
            child: Row(children: [
              if (_currentChapter > 1)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prevChapter,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text('Cap. ${_currentChapter - 1}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.creamWhite : AppTheme.navyDeep,
                      side: BorderSide(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (_currentChapter > 1 && _currentChapter < widget.book.chapters)
                const SizedBox(width: 12),
              if (_currentChapter < widget.book.chapters)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextChapter,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text('Cap. ${_currentChapter + 1}'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _markRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📖 Livro concluído! Parabéns!')));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.celebration_rounded, size: 16),
                    label: const Text('Concluir Livro'),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  Color _hlBg(String? color) {
    switch (color) {
      case 'yellow': return Colors.yellow.withOpacity(0.2);
      case 'green': return Colors.green.withOpacity(0.15);
      case 'blue': return Colors.blue.withOpacity(0.15);
      case 'pink': return Colors.pink.withOpacity(0.15);
      default: return Colors.yellow.withOpacity(0.2);
    }
  }

  void _showVerseOptions(BuildContext context, AppProvider provider, int verse, String text) {
    final isHighlighted = provider.isHighlighted(widget.book.id, _currentChapter, verse);
    final isBookmarked = provider.isBookmarked(widget.book.id, _currentChapter, verse);

    showModalBottomSheet(
      context: context,
      backgroundColor: provider.isDarkMode ? AppTheme.navyMid : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
          Text('${widget.book.abbreviation} $_currentChapter:$verse', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),

          // Cores de grifo
          Row(children: [
            Text('Grifar:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 12),
            ...[('yellow', Colors.yellow), ('green', Colors.green), ('blue', Colors.lightBlue), ('pink', Colors.pink)]
                .map((c) => GestureDetector(
                      onTap: () { provider.addHighlight(widget.book.id, _currentChapter, verse, text, c.$1); Navigator.pop(ctx); },
                      child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: c.$2.withOpacity(0.7), shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 2))),
                    )),
            if (isHighlighted)
              GestureDetector(
                onTap: () { provider.removeHighlight(widget.book.id, _currentChapter, verse); Navigator.pop(ctx); },
                child: const Icon(Icons.format_color_reset_rounded, color: AppTheme.warmGray, size: 20)),
          ]),
          const SizedBox(height: 12),

          // Botões de ação
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {
                isBookmarked
                    ? provider.removeBookmark(widget.book.id, _currentChapter, verse)
                    : provider.addBookmark(widget.book.id, _currentChapter, verse, text);
                Navigator.pop(ctx);
              },
              icon: Icon(isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded, size: 16),
              label: Text(isBookmarked ? 'Remover' : 'Favoritar'),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: () { Share.share('"$text"\n— ${widget.book.name} $_currentChapter:$verse\n\n🕊️ Manual do Cristão'); Navigator.pop(ctx); },
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Compartilhar'),
            )),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '"$text"\n— ${widget.book.name} $_currentChapter:$verse'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Versículo copiado!')));
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () { TtsService.speak(text); Navigator.pop(ctx); },
              icon: const Icon(Icons.volume_up_rounded, size: 16),
              label: const Text('Ouvir'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _searchYouTube(BuildContext context) {
    final bookChapter = '${widget.book.name} $_currentChapter';
    final ctrl = TextEditingController(text: bookChapter);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.play_circle_filled_rounded, color: Colors.red, size: 26),
          SizedBox(width: 10),
          Text('Buscar no YouTube', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Pesquise vídeos sobre esta passagem:', style: TextStyle(color: AppTheme.warmGray, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldPrimary),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AppTheme.warmGray))),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final query = Uri.encodeComponent('${ctrl.text.trim()} bíblia pregação');
              final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
              if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.play_circle_filled_rounded, size: 18),
            label: const Text('Buscar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  void _showFontDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('Tamanho do Texto'),
        content: StatefulBuilder(
          builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Exemplo de texto bíblico', style: TextStyle(fontSize: provider.readingFontSize.toDouble(), height: 1.6)),
            const SizedBox(height: 20),
            Slider(
              value: provider.readingFontSize.toDouble(), min: 14, max: 28, divisions: 7,
              label: '${provider.readingFontSize}', activeColor: AppTheme.goldPrimary,
              onChanged: (v) { set(() {}); provider.setFontSize(v.toInt()); },
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('A', style: TextStyle(fontSize: 12)), Text('A', style: TextStyle(fontSize: 22)),
            ]),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
      ),
    );
  }

  void _showVersionDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('Versão da Bíblia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: provider.religion.availableVersions.map((v) => RadioListTile<BibleVersion>(
            value: v, groupValue: provider.bibleVersion,
            onChanged: (val) { if (val != null) { provider.setBibleVersion(val); Navigator.pop(ctx); _loadChapter(); } },
            title: Text(v.shortName),
            subtitle: Text(v.displayName, style: const TextStyle(fontSize: 11)),
            activeColor: AppTheme.goldPrimary,
          )).toList(),
        ),
      ),
    );
  }
}
