import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';
import 'chapter_reader_screen.dart';

class ChaptersScreen extends StatelessWidget {
  final BibleBook book;

  const ChaptersScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      book.testament == Testament.old
                          ? AppTheme.goldDark
                          : AppTheme.forestGreen,
                      isDark ? AppTheme.navyDeep : AppTheme.creamLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          book.name,
                          style:
                              Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        if (book.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.description!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(
                                '${book.chapters} capítulos', Colors.white24),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                                book.category, Colors.white24),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              book.testament == Testament.old
                                  ? 'Antigo Testamento'
                                  : 'Novo Testamento',
                              Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Progress bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.navyMid : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3F5A)
                      : const Color(0xFFE8DCC8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Progresso',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Text(
                        '${book.completedChapters.length}/${book.chapters} capítulos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.goldPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: book.readingProgress,
                    backgroundColor: isDark
                        ? const Color(0xFF1E3048)
                        : const Color(0xFFEEE0CA),
                    color: book.isCompleted
                        ? AppTheme.forestGreen
                        : AppTheme.goldPrimary,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(book.readingProgress * 100).toStringAsFixed(0)}% concluído',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Capítulos',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final chapter = i + 1;
                  final isRead =
                      book.completedChapters.contains(chapter);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterReaderScreen(
                            book: book,
                            chapter: chapter,
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isRead
                            ? AppTheme.forestGreen
                            : isDark
                                ? AppTheme.navyMid
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isRead
                              ? AppTheme.forestGreen
                              : isDark
                                  ? const Color(0xFF2A3F5A)
                                  : const Color(0xFFE8DCC8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$chapter',
                          style: TextStyle(
                            color: isRead
                                ? Colors.white
                                : isDark
                                    ? AppTheme.creamWhite
                                    : AppTheme.navyDeep,
                            fontWeight: isRead
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: book.chapters,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
