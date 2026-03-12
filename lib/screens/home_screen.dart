import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/bible_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, provider, isDark),
          SliverToBoxAdapter(
            child: FadeTransition(opacity: _fadeAnim,
              child: SlideTransition(position: _slideAnim,
                child: Padding(padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildDailyVerse(context, provider, isDark),
                    const SizedBox(height: 24),
                    _buildProgressSection(context, provider, isDark),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, provider, isDark),
                    const SizedBox(height: 24),
                    _buildActivePlan(context, provider, isDark),
                    const SizedBox(height: 24),
                    _buildRecentVideos(context, isDark),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppProvider provider, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    return SliverAppBar(
      expandedHeight: 120, floating: false, pinned: true,
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$greeting! 🕊️', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.warmGray)),
              Text('Palavra Viva', style: Theme.of(context).textTheme.displaySmall),
            ]),
            GestureDetector(
              onTap: () => provider.toggleTheme(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.navyMid : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
                ),
                child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? AppTheme.goldPrimary : AppTheme.goldDark, size: 18),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDailyVerse(BuildContext context, AppProvider provider, bool isDark) {
    final verse = provider.dailyVerse;
    if (verse == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark ? [AppTheme.navyLight, AppTheme.navyMid] : [Colors.white, AppTheme.creamWhite]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.goldPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.wb_sunny_rounded, color: AppTheme.goldPrimary, size: 12),
              const SizedBox(width: 4),
              Text('Versículo do Dia', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.goldPrimary, fontWeight: FontWeight.w600)),
            ]),
          ),
          const Spacer(),
          IconButton(onPressed: () => Share.share('"${verse['text']}"\n— ${verse['ref']}\n\n🕊️ Palavra Viva'),
            icon: const Icon(Icons.share_rounded, color: AppTheme.warmGray, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 8),
          IconButton(onPressed: () {
            Clipboard.setData(ClipboardData(text: '"${verse['text']}"\n— ${verse['ref']}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Versículo copiado!')));
          }, icon: const Icon(Icons.copy_rounded, color: AppTheme.warmGray, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 16),
        Text('"${verse['text']}"', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        Text('— ${verse['ref']}', style: Theme.of(context).textTheme.labelLarge),
      ]),
    );
  }

  Widget _buildProgressSection(BuildContext context, AppProvider provider, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Meu Progresso', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _stat(context, Icons.auto_stories_rounded, '${provider.totalBooksRead}', 'Livros\nConcluídos', AppTheme.forestGreen, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _stat(context, Icons.local_fire_department_rounded, '${provider.dailyStreak}', 'Dias\nSeguidos', AppTheme.crimsonAccent, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _stat(context, Icons.percent_rounded, '${(provider.overallProgress * 100).toStringAsFixed(0)}%', 'Total\nLido', AppTheme.goldPrimary, isDark)),
      ]),
    ]);
  }

  Widget _stat(BuildContext context, IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color, fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider provider, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Acesso Rápido', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _action(context, Icons.shuffle_rounded, 'Versículo\nAleatório', AppTheme.purple, isDark, () => _randomVerse(context, provider))),
        const SizedBox(width: 12),
        Expanded(child: _action(context, Icons.bookmark_rounded, 'Meus\nFavoritos', AppTheme.goldPrimary, isDark, () => _bookmarks(context, provider))),
        const SizedBox(width: 12),
        Expanded(child: _action(context, Icons.highlight_rounded, 'Meus\nGrifos', AppTheme.forestGreen, isDark, () => _highlights(context, provider))),
      ]),
    ]);
  }

  Widget _action(BuildContext context, IconData icon, String label, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: isDark ? AppTheme.navyMid : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppTheme.creamWhite : AppTheme.navyDeep, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildActivePlan(BuildContext context, AppProvider provider, bool isDark) {
    if (provider.activePlan == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppTheme.navyMid : Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.goldPrimary.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.calendar_today_rounded, color: AppTheme.goldPrimary, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nenhum plano ativo', style: Theme.of(context).textTheme.headlineSmall),
            Text('Inicie um plano de leitura', style: Theme.of(context).textTheme.bodySmall),
          ])),
          TextButton(onPressed: () => _planSelector(context, provider), child: const Text('Criar')),
        ]),
      );
    }
    final plan = provider.activePlan!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.forestGreen.withOpacity(0.8), AppTheme.forestGreen.withOpacity(0.5)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text('Dia ${plan.currentDay}/${plan.durationDays}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: plan.progress, backgroundColor: Colors.white30, color: Colors.white, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 8),
        Text('${(plan.progress * 100).toStringAsFixed(1)}% concluído', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildRecentVideos(BuildContext context, bool isDark) {
    final videos = BibleData.getVideoLessons();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Vídeos Recentes', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      SizedBox(height: 140, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final v = videos[i];
          return Container(width: 220,
            decoration: BoxDecoration(color: isDark ? AppTheme.navyMid : Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 80, decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                child: Stack(alignment: Alignment.center, children: [
                  Container(color: Colors.black26),
                  Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20)),
                ])),
              Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(v.channelName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
              ])),
            ]),
          );
        },
      )),
    ]);
  }

  void _randomVerse(BuildContext context, AppProvider provider) {
    final verse = provider.getRandomVerse();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.navyMid, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('✨ Versículo Aleatório', style: Theme.of(context).textTheme.headlineMedium),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('"${verse['text']}"', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        Text('— ${verse['ref']}', style: Theme.of(context).textTheme.labelLarge),
      ]),
      actions: [
        TextButton(onPressed: () { Share.share('"${verse['text']}"\n— ${verse['ref']}\n\n🕊️ Palavra Viva'); }, child: const Text('Compartilhar')),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
      ],
    ));
  }

  void _bookmarks(BuildContext context, AppProvider provider) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.navyMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
        Text('Favoritos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Expanded(child: provider.bookmarks.isEmpty
          ? Center(child: Text('Nenhum favorito ainda', style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(itemCount: provider.bookmarks.length, itemBuilder: (c, i) {
              final bm = provider.bookmarks[i];
              return ListTile(leading: const Icon(Icons.bookmark_rounded, color: AppTheme.goldPrimary),
                title: Text(bm['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${bm['bookId']} ${bm['chapter']}:${bm['verse']}'));
            })),
      ]),
    );
  }

  void _highlights(BuildContext context, AppProvider provider) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.navyMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
        Text('Meus Grifos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Expanded(child: provider.highlights.isEmpty
          ? Center(child: Text('Nenhum grifo ainda', style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(itemCount: provider.highlights.length, itemBuilder: (c, i) {
              final hl = provider.highlights[i];
              return ListTile(leading: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.7), shape: BoxShape.circle)),
                title: Text(hl['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${hl['bookId']} ${hl['chapter']}:${hl['verse']}'));
            })),
      ]),
    );
  }

  void _planSelector(BuildContext context, AppProvider provider) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.navyMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Plano de Leitura', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ...[('1year','📅 Bíblia em 1 Ano','3-4 cap/dia',365),('6months','⚡ Bíblia em 6 Meses','6-8 cap/dia',180),('3months','🚀 NT em 3 Meses','NT - 3 cap/dia',90)].map((p) =>
          GestureDetector(onTap: () { provider.setActivePlan(provider.createReadingPlan(p.$1)); Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.$2} iniciado! 🎉'))); },
            child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.navyDeep, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A3F5A))),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.$2, style: Theme.of(context).textTheme.headlineSmall), Text(p.$3, style: Theme.of(context).textTheme.bodySmall)])),
                Text('${p.$4} dias', style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12)),
              ]),
            )),
        ),
        const SizedBox(height: 8),
      ])),
    );
  }
}
