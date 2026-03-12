import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';
import 'chapters_screen.dart';
import 'chapter_reader_screen.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({Key? key}) : super(key: key);

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Leitura', style: Theme.of(context).textTheme.headlineLarge),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.goldPrimary,
          unselectedLabelColor: AppTheme.warmGray,
          indicatorColor: AppTheme.goldPrimary,
          tabs: const [
            Tab(text: 'Plano'),
            Tab(text: 'Cronológica'),
            Tab(text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlanTab(context, provider, isDark),
          _buildChronologicalTab(context, provider, isDark),
          _buildVideosTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildPlanTab(
      BuildContext context, AppProvider provider, bool isDark) {
    if (provider.activePlan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.goldPrimary, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Nenhum Plano Ativo',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Escolha um plano de leitura e acompanhe seu progresso diário',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...[
                ('1year', '📅 Bíblia em 1 Ano', '3-4 capítulos/dia', 365),
                ('6months', '⚡ Bíblia em 6 Meses', '6-8 capítulos/dia', 180),
                ('3months', '🚀 NT em 3 Meses', 'Novo Testamento', 90),
              ].map((plan) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final p = provider.createReadingPlan(plan.$1);
                          provider.setActivePlan(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Plano "${plan.$2}" iniciado! 🎉')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppTheme.creamWhite
                              : AppTheme.navyDeep,
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2A3F5A)
                                : const Color(0xFFE8DCC8),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: Row(
                          children: [
                            Text(plan.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(plan.$3,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Text('${plan.$4} dias',
                                    style: const TextStyle(
                                        color: AppTheme.goldPrimary,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
    }

    final plan = provider.activePlan!;
    final today = plan.dailyReadings.isNotEmpty &&
            plan.currentDay <= plan.dailyReadings.length
        ? plan.dailyReadings[plan.currentDay - 1]
        : null;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.forestGreen,
                  AppTheme.forestGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(plan.description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${(plan.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text('concluído',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: plan.progress,
                  backgroundColor: Colors.white30,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dia ${plan.currentDay} de ${plan.durationDays}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (today != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Leitura de Hoje — Dia ${today.day}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Spacer(),
                  if (!today.isCompleted)
                    ElevatedButton(
                      onPressed: () {
                        provider.markPlanDayComplete(today.day);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ Dia concluído! Continue assim!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Concluir'),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppTheme.forestGreen, size: 14),
                          SizedBox(width: 4),
                          Text('Concluído',
                              style: TextStyle(
                                  color: AppTheme.forestGreen,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final cr = today.chapters[i];
                final book = provider.books
                    .firstWhere((b) => b.id == cr.bookId,
                        orElse: () => provider.books.first);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.navyMid : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cr.isRead
                          ? AppTheme.forestGreen.withOpacity(0.4)
                          : isDark
                              ? const Color(0xFF2A3F5A)
                              : const Color(0xFFE8DCC8),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cr.isRead
                            ? AppTheme.forestGreen.withOpacity(0.15)
                            : AppTheme.goldPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cr.isRead
                            ? Icons.check_rounded
                            : Icons.menu_book_rounded,
                        color: cr.isRead
                            ? AppTheme.forestGreen
                            : AppTheme.goldPrimary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      '${book.name} ${cr.chapter}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    subtitle: Text(book.category,
                        style: Theme.of(context).textTheme.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.warmGray, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterReaderScreen(
                            book: book,
                            chapter: cr.chapter,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: today.chapters.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildChronologicalTab(
      BuildContext context, AppProvider provider, bool isDark) {
    final books = provider.books;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (ctx, i) {
        final book = books[i];
        final isNewTestament = i > 0 &&
            books[i - 1].testament == Testament.old &&
            book.testament == Testament.new_;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i == 0)
              _buildTestamentHeader(context, '📜 Antigo Testamento', isDark),
            if (isNewTestament)
              _buildTestamentHeader(context, '✝️ Novo Testamento', isDark),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.navyMid : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: book.isCompleted
                      ? AppTheme.forestGreen.withOpacity(0.3)
                      : book.readingProgress > 0
                          ? AppTheme.goldPrimary.withOpacity(0.2)
                          : isDark
                              ? const Color(0xFF2A3F5A)
                              : const Color(0xFFE8DCC8),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: book.isCompleted
                        ? AppTheme.forestGreen.withOpacity(0.15)
                        : AppTheme.goldPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      book.abbreviation.length > 3
                          ? book.abbreviation.substring(0, 3)
                          : book.abbreviation,
                      style: TextStyle(
                        color: book.isCompleted
                            ? AppTheme.forestGreen
                            : AppTheme.goldPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  book.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 14,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${book.chapters} capítulos · ${book.category}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: book.readingProgress,
                      backgroundColor: isDark
                          ? const Color(0xFF1E3048)
                          : const Color(0xFFEEE0CA),
                      color: book.isCompleted
                          ? AppTheme.forestGreen
                          : AppTheme.goldPrimary,
                      borderRadius: BorderRadius.circular(2),
                      minHeight: 3,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(book.readingProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: book.isCompleted
                            ? AppTheme.forestGreen
                            : AppTheme.warmGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.warmGray, size: 18),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChaptersScreen(book: book),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestamentHeader(
      BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildVideosTab(BuildContext context, bool isDark) {
    final videos = BibleData.getVideoLessons();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (ctx, i) {
        final video = videos[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyMid : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A3F5A)
                  : const Color(0xFFE8DCC8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.black26,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: video.category == 'padre'
                              ? Colors.purple.withOpacity(0.8)
                              : Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          video.category == 'padre' ? 'Padre' : 'Pastor',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          video.category == 'padre'
                              ? Icons.church_rounded
                              : Icons.groups_rounded,
                          size: 14,
                          color: AppTheme.warmGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.channelName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          video.bookId.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
