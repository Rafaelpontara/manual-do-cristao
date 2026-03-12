import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';

class ChapterReaderScreen extends StatefulWidget {
  final BibleBook book;
  final int chapter;

  const ChapterReaderScreen(
      {Key? key, required this.book, required this.chapter})
      : super(key: key);

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  List<Map<String, String>> _verses = [];
  bool _isLoading = true;
  int? _selectedVerse;
  late int _currentChapter;
  bool _showToolbar = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _loadChapter();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _showToolbar) {
      setState(() => _showToolbar = false);
    } else if (_scrollController.offset <= 100 && !_showToolbar) {
      setState(() => _showToolbar = true);
    }
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final verses = await BibleService.getChapterVerses(
        widget.book.id, _currentChapter, provider.bibleVersion);
    setState(() {
      _verses = verses;
      _isLoading = false;
    });
  }

  void _nextChapter() {
    if (_currentChapter < widget.book.chapters) {
      _markCurrentRead();
      setState(() {
        _currentChapter++;
        _selectedVerse = null;
        _verses = [];
      });
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _loadChapter();
    }
  }

  void _prevChapter() {
    if (_currentChapter > 1) {
      setState(() {
        _currentChapter--;
        _selectedVerse = null;
        _verses = [];
      });
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _loadChapter();
    }
  }

  void _markCurrentRead() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.markChapterRead(widget.book.id, _currentChapter);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final fontSize = provider.readingFontSize.toDouble();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  '${widget.book.name} $_currentChapter',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                actions: [
                  // Font size
                  IconButton(
                    icon: const Icon(Icons.text_fields_rounded, size: 20),
                    onPressed: () => _showFontSizeDialog(context, provider),
                  ),
                  // Bible version
                  GestureDetector(
                    onTap: () => _showVersionDialog(context, provider),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.goldPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        provider.bibleVersion.shortName,
                        style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.goldPrimary),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final verse = _verses[i];
                        final verseNum = int.parse(verse['verse'] ?? '1');
                        final isSelected = _selectedVerse == verseNum;
                        final isHighlighted = provider.isHighlighted(
                            widget.book.id, _currentChapter, verseNum);
                        final hlColor = provider.getHighlightColor(
                            widget.book.id, _currentChapter, verseNum);
                        final isBookmarked = provider.isBookmarked(
                            widget.book.id, _currentChapter, verseNum);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedVerse =
                                isSelected ? null : verseNum);
                          },
                          onLongPress: () {
                            setState(() => _selectedVerse = verseNum);
                            _showVerseOptions(context, provider, verseNum,
                                verse['text'] ?? '');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.goldPrimary.withOpacity(0.1)
                                  : isHighlighted
                                      ? _getHighlightBgColor(hlColor)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.goldPrimary
                                          .withOpacity(0.3))
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Verse number
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '$verseNum',
                                    style: TextStyle(
                                      color: AppTheme.goldPrimary,
                                      fontSize: fontSize * 0.65,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Verse text
                                Expanded(
                                  child: Text(
                                    verse['text'] ?? '',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppTheme.creamWhite
                                          : AppTheme.navyDeep,
                                      fontSize: fontSize,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                                // Bookmark indicator
                                if (isBookmarked)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, top: 4),
                                    child: Icon(Icons.bookmark_rounded,
                                        color: AppTheme.goldPrimary, size: 14),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _verses.length,
                    ),
                  ),
                ),
            ],
          ),
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? AppTheme.navyDeep : AppTheme.creamLight)
                        .withOpacity(0),
                    isDark ? AppTheme.navyDeep : AppTheme.creamLight,
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (_currentChapter > 1)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _prevChapter,
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: Text('Cap. ${_currentChapter - 1}'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppTheme.creamWhite
                              : AppTheme.navyDeep,
                          side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF2A3F5A)
                                  : const Color(0xFFE8DCC8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (_currentChapter > 1 &&
                      _currentChapter < widget.book.chapters)
                    const SizedBox(width: 12),
                  if (_currentChapter < widget.book.chapters)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextChapter,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: Text('Cap. ${_currentChapter + 1}'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _markCurrentRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('📖 Livro concluído! Parabéns!')),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.celebration_rounded, size: 16),
                        label: const Text('Concluir Livro'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHighlightBgColor(String? color) {
    switch (color) {
      case 'yellow':
        return Colors.yellow.withOpacity(0.2);
      case 'green':
        return Colors.green.withOpacity(0.15);
      case 'blue':
        return Colors.blue.withOpacity(0.15);
      case 'pink':
        return Colors.pink.withOpacity(0.15);
      default:
        return Colors.yellow.withOpacity(0.2);
    }
  }

  void _showVerseOptions(BuildContext context, AppProvider provider,
      int verse, String text) {
    final isHighlighted =
        provider.isHighlighted(widget.book.id, _currentChapter, verse);
    final isBookmarked =
        provider.isBookmarked(widget.book.id, _currentChapter, verse);

    showModalBottomSheet(
      context: context,
      backgroundColor: provider.isDarkMode ? AppTheme.navyMid : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.warmGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '${widget.book.abbreviation} $_currentChapter:$verse',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            // Highlight colors
            Row(
              children: [
                Text('Grifar:', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                ...[
                  ('yellow', Colors.yellow),
                  ('green', Colors.green),
                  ('blue', Colors.lightBlue),
                  ('pink', Colors.pink),
                ].map((c) => GestureDetector(
                      onTap: () {
                        provider.addHighlight(widget.book.id,
                            _currentChapter, verse, text, c.$1);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: c.$2.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white30, width: 2),
                        ),
                      ),
                    )),
                if (isHighlighted)
                  GestureDetector(
                    onTap: () {
                      provider.removeHighlight(
                          widget.book.id, _currentChapter, verse);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.format_color_reset_rounded,
                          color: AppTheme.warmGray, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (isBookmarked) {
                        provider.removeBookmark(
                            widget.book.id, _currentChapter, verse);
                      } else {
                        provider.addBookmark(
                            widget.book.id, _currentChapter, verse, text);
                      }
                      Navigator.pop(ctx);
                    },
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_remove_rounded
                          : Icons.bookmark_add_rounded,
                      size: 16,
                    ),
                    label: Text(
                        isBookmarked ? 'Remover Favorito' : 'Favoritar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final shareText =
                          '"$text"\n— ${widget.book.name} $_currentChapter:$verse\n\n🕊️ Palavra Viva';
                      Share.share(shareText);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Compartilhar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          '"$text"\n— ${widget.book.name} $_currentChapter:$verse'));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Versículo copiado!')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copiar Texto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('Tamanho do Texto'),
        content: StatefulBuilder(
          builder: (ctx, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exemplo de texto bíblico',
                style: TextStyle(
                    fontSize: provider.readingFontSize.toDouble(),
                    height: 1.6),
              ),
              const SizedBox(height: 20),
              Slider(
                value: provider.readingFontSize.toDouble(),
                min: 14,
                max: 28,
                divisions: 7,
                label: '${provider.readingFontSize}',
                activeColor: AppTheme.goldPrimary,
                onChanged: (v) {
                  setDialogState(() {});
                  provider.setFontSize(v.toInt());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('A', style: TextStyle(fontSize: 12)),
                  const Text('A', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
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
          children: provider.religion.availableVersions.map((v) {
            return RadioListTile<BibleVersion>(
              value: v,
              groupValue: provider.bibleVersion,
              onChanged: (val) {
                if (val != null) {
                  provider.setBibleVersion(val);
                  Navigator.pop(ctx);
                  _loadChapter();
                }
              },
              title: Text(v.shortName),
              subtitle: Text(v.displayName,
                  style: const TextStyle(fontSize: 11)),
              activeColor: AppTheme.goldPrimary,
            );
          }).toList(),
        ),
      ),
    );
  }
}
