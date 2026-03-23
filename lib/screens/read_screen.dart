import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../services/reading_plan_service.dart';
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
        backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
        elevation: 0,
        title: Text('Leitura', style: TextStyle(
          color: AppTheme.goldPrimary,
          fontSize: 22, fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        )),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.goldPrimary,
          unselectedLabelColor: AppTheme.warmGray,
          indicatorColor: AppTheme.goldPrimary,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Plano'),
            Tab(text: 'Cronológica'),
            Tab(text: 'Vídeos'),
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
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1B2A), fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Escolha um plano de leitura e acompanhe seu progresso diário',
                style: const TextStyle(color: AppTheme.warmGray, fontSize: 14, height: 1.5),
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
                  'Dia ${plan.currentDay} de ${plan.totalDays}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Leitura de Hoje — Dia \${plan.currentDay}',
                  style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    provider.markPlanDayComplete(plan.currentDay);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Dia concluído! Continue assim! 🎉')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: AppTheme.navyDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('✓ Concluir'),
                ),
              ]),
              const SizedBox(height: 12),
              // Show today's readings
              Builder(builder: (ctx) {
                final todayReading = ReadingPlanService.getTodayReading(plan.schedule, plan.currentDay);
                if (todayReading == null || (todayReading['readings'] as List).isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.navyMid : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppTheme.navyLight : const Color(0xFFE8DCC8)),
                    ),
                    child: const Text('Nenhuma leitura para hoje', style: TextStyle(color: AppTheme.warmGray)),
                  );
                }
                final readings = todayReading['readings'] as List;
                return Column(children: readings.map<Widget>((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.navyMid : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppTheme.navyLight : const Color(0xFFE8DCC8)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.goldPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r["bookName"]} Cap. ${r["chapter"]}',
                          style: TextStyle(color: isDark ? Colors.white : AppTheme.navyDeep,
                            fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('Capítulo ${r["chapter"]}',
                          style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                      ])),
                      GestureDetector(
                        onTap: () {
                          final book = provider.books.firstWhere(
                            (b) => b.id == r['bookId'],
                            orElse: () => provider.books.first,
                          );
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ChapterReaderScreen(book: book, chapter: r['chapter'] as int),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Ler', style: TextStyle(color: AppTheme.navyDeep, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                    ]),
                  );
                }).toList());
              }),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1B2A), fontSize: 15, fontWeight: FontWeight.w600)?.copyWith(
                        fontSize: 14,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${book.chapters} capítulos · ${book.category}',
                        style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
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
        style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 22, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildVideosTab(BuildContext context, bool isDark) {
    final videos = BibleData.getVideoLessons();
    final ctrl = TextEditingController();

    void searchYouTube() async {
      if (ctrl.text.trim().isEmpty) return;
      final query = Uri.encodeComponent('${ctrl.text.trim()} bíblia pregação');
      final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
      if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
    }

    return Column(children: [
      // Barra de busca YouTube
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2E45) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
              ),
              child: TextField(
                controller: ctrl,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1B2A), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar vídeos no YouTube...',
                  hintStyle: const TextStyle(color: AppTheme.warmGray, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.warmGray, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => searchYouTube(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: searchYouTube,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 24),
            ),
          ),
        ]),
      ),
      // Lista de vídeos
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: videos.length,
          itemBuilder: (ctx, i) {
            final video = videos[i];
            final isPadre = video.category == 'padre';
            return GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://www.youtube.com/watch?v=${video.youtubeId}');
                if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.navyMid : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(children: [
                      Container(
                        height: 180, width: double.infinity, color: Colors.black87,
                        child: Image.network(video.thumbnail, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black87)),
                      ),
                      Container(height: 180, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      )),
                      const Positioned.fill(child: Center(
                        child: Icon(Icons.play_circle_filled_rounded, color: Colors.red, size: 56),
                      )),
                      Positioned(top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPadre ? const Color(0xFF7B2FBE) : const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(isPadre ? 'Padre' : 'Pastor',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(video.title,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                          fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(isPadre ? Icons.church_rounded : Icons.people_rounded,
                          size: 13, color: AppTheme.warmGray),
                        const SizedBox(width: 4),
                        Expanded(child: Text(video.channelName,
                          style: const TextStyle(color: AppTheme.warmGray, fontSize: 12),
                          overflow: TextOverflow.ellipsis)),
                        Text(video.bookId.toUpperCase(),
                          style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                      if (video.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(video.description,
                          style: const TextStyle(color: AppTheme.warmGray, fontSize: 12),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
