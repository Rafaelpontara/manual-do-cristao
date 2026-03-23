import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/bible_models.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'download_screen.dart';
import 'books_screen.dart';
import 'read_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final bg = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F0E8);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          _appBar(context, provider, isDark),
          SliverToBoxAdapter(child: _body(context, provider, isDark)),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _appBar(BuildContext context, AppProvider provider, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia ☀️' : hour < 18 ? 'Boa tarde 🌤️' : 'Boa noite 🌙';
    final now = DateTime.now();
    final weekDays = ['domingo','segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado'];
    final months = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
    final dateStr = '${weekDays[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]}';

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F0E8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(greeting, style: TextStyle(
                  color: isDark ? const Color(0xFF8FA8C0) : AppTheme.warmGray,
                  fontSize: 13, fontWeight: FontWeight.w400,
                )),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => _editName(context, provider),
                  child: Row(children: [
                    Flexible(child: Text(
                      provider.userName.isNotEmpty ? provider.userName : 'Toque para adicionar seu nome',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                        fontSize: 26, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_rounded, size: 14, color: AppTheme.goldPrimary),
                  ]),
                ),
                const SizedBox(height: 2),
                Text(dateStr, style: TextStyle(
                  color: isDark ? const Color(0xFF8FA8C0) : AppTheme.warmGray,
                  fontSize: 12,
                )),
              ]),
            ),
            // Botões top right
            Row(children: [
              _topBtn(isDark, isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, () => provider.toggleTheme()),
            ]),
          ]),
        ),
      ),
    );
  }

  void _editName(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seu nome'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Digite seu nome...'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.setUserName(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Salvar', style: TextStyle(color: AppTheme.goldPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _topBtn(bool isDark, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2E45) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0)),
      ),
      child: Icon(icon, color: isDark ? const Color(0xFF8FA8C0) : AppTheme.warmGray, size: 18),
    ),
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body(BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Versão + Religião + Lembretes
        _topChips(context, provider, isDark),
        const SizedBox(height: 16),

        // Versículo do dia
        _verseOfDay(context, provider, isDark),
        const SizedBox(height: 16),

        // Banner offline
        _offlineBanner(context, isDark),
        const SizedBox(height: 20),

        // Acesso rápido
        _sectionLabel('ACESSO RÁPIDO', isDark),
        const SizedBox(height: 12),
        _quickAccess(context, provider, isDark),
        const SizedBox(height: 20),

        // Progresso
        _sectionLabel('MEU PROGRESSO', isDark),
        const SizedBox(height: 12),
        _progress(context, provider, isDark),
        const SizedBox(height: 20),

        // Plano ativo
        _activePlan(context, provider, isDark),
        const SizedBox(height: 20),

        // Vídeos recentes
        _sectionLabel('VÍDEOS', isDark),
        const SizedBox(height: 12),
        _videos(context, isDark),
      ]),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      color: isDark ? const Color(0xFF5A7A99) : AppTheme.warmGray,
      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
    ),
  );

  // ── Chips de versão / religião / lembretes ─────────────────────────────────
  Widget _topChips(BuildContext context, AppProvider provider, bool isDark) {
    return Row(children: [
      _chip(provider.bibleVersion.shortName, AppTheme.goldPrimary, isDark, solid: true),
      const SizedBox(width: 8),
      _chip('${provider.religion.emoji} ${provider.religion.displayName}',
          isDark ? const Color(0xFF2A5AE8) : const Color(0xFF3B6DDE), isDark),
      const Spacer(),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        child: _chip('🔔 Lembretes', isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8), isDark),
      ),
    ]);
  }

  Widget _chip(String label, Color color, bool isDark, {bool solid = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: solid ? color : color.withOpacity(isDark ? 0.2 : 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(
      color: solid ? AppTheme.navyDeep : color,
      fontSize: 12, fontWeight: FontWeight.w600,
    )),
  );

  // ── Pesquisa por voz ───────────────────────────────────────────────────────
  Future<void> _startVoiceSearch(BuildContext context) async {
    final ctrl = TextEditingController();
    setState(() => _isListening = true);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5B6EF5), Color(0xFF7B4FE0)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Pesquisa por Voz', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Digite ou fale o que deseja buscar:', style: TextStyle(color: AppTheme.warmGray, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ex: amor, João 3:16, Salmos...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldPrimary),
            ),
            onSubmitted: (v) => Navigator.pop(context),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AppTheme.warmGray))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );

    setState(() => _isListening = false);
    if (ctrl.text.trim().isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: ctrl.text.trim()),
      ));
    }
  }

    Widget _voiceSearch(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _startVoiceSearch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E45) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _isListening
              ? const Color(0xFF5B6EF5)
              : (isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0))),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isListening
                    ? [const Color(0xFFE84393), const Color(0xFF7B4FE0)]
                    : [const Color(0xFF5B6EF5), const Color(0xFF7B4FE0)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pesquisa por Voz', style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
              fontWeight: FontWeight.w600, fontSize: 14,
            )),
            Text(_isListening ? 'Ouvindo...' : 'Toque e fale para pesquisar',
              style: TextStyle(
                color: _isListening ? const Color(0xFF5B6EF5) : (isDark ? const Color(0xFF8FA8C0) : AppTheme.warmGray),
                fontSize: 12,
              )),
          ]),
          const Spacer(),
          Icon(Icons.chevron_right_rounded,
            color: isDark ? const Color(0xFF5A7A99) : AppTheme.warmGray),
        ]),
      ),
    );
  }

  // ── Versículo do Dia ───────────────────────────────────────────────────────
  Widget _verseOfDay(BuildContext context, AppProvider provider, bool isDark) {
    final verse = provider.dailyVerse;
    if (verse == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF4A3B8C), Color(0xFF6B4FBF), Color(0xFF3D5A9E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4A3B8C).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Text('✦', style: TextStyle(color: Colors.white70, fontSize: 10)),
              const SizedBox(width: 4),
              const Text('VERSÍCULO DO DIA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ]),
          ),
          const Spacer(),
          _verseBtn(Icons.share_rounded, () => Share.share('"${verse['text']}"\n— ${verse['ref']}\n\n🕊️ Manual do Cristão')),
          const SizedBox(width: 6),
          _verseBtn(Icons.copy_rounded, () {
            Clipboard.setData(ClipboardData(text: '"${verse['text']}"\n— ${verse['ref']}'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Versículo copiado!'), duration: Duration(seconds: 2)));
          }),
        ]),
        const SizedBox(height: 16),
        Text(
          '"${verse['text']}"',
          style: const TextStyle(
            color: Colors.white, fontSize: 16,
            fontStyle: FontStyle.italic, height: 1.6,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Text(verse['ref']!, style: const TextStyle(color: Color(0xFFB8A8FF), fontWeight: FontWeight.w700, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Row(children: [
              Text('Ler contexto', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 16),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _verseBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );

  // ── Acesso Rápido ──────────────────────────────────────────────────────────
  Widget _offlineBanner(BuildContext context, bool isDark) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((p) => p.getBool('bible_downloaded') ?? false),
      builder: (context, snap) {
        final downloaded = snap.data ?? false;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: downloaded
                    ? [const Color(0xFF2AAE6E), const Color(0xFF1A8A55)]
                    : [const Color(0xFF1F3864), const Color(0xFF2E75B6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: (downloaded ? const Color(0xFF2AAE6E) : const Color(0xFF1F3864)).withOpacity(0.25),
                blurRadius: 12, offset: const Offset(0, 4),
              )],
            ),
            child: Row(children: [
              Icon(
                downloaded ? Icons.check_circle_rounded : Icons.cloud_download_rounded,
                color: Colors.white, size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  downloaded ? '✅ Bíblia disponível offline' : '📥 Baixar Bíblia para uso offline',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  downloaded ? 'Leia sem internet a qualquer hora' : 'Leia sem internet, sem gastar dados',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ])),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ]),
          ),
        );
      },
    );
  }

  Widget _quickAccess(BuildContext context, AppProvider provider, bool isDark) {
    final actions = [
      {'icon': Icons.shuffle_rounded,   'label': 'Versículo\nAleatório', 'color': const Color(0xFF3B6DDE), 'gradient': [const Color(0xFF3B6DDE), const Color(0xFF5B8FF5)]},
      {'icon': Icons.menu_book_rounded,  'label': 'Ler\nBíblia',           'color': const Color(0xFFE84393), 'gradient': [const Color(0xFFE84393), const Color(0xFFF56BB0)]},
      {'icon': Icons.bookmark_rounded,   'label': 'Meus\nFavoritos',       'color': const Color(0xFFE8832A), 'gradient': [const Color(0xFFE8832A), const Color(0xFFF5A54E)]},
      {'icon': Icons.highlight_rounded,  'label': 'Meus\nGrifos',          'color': const Color(0xFF2AAE6E), 'gradient': [const Color(0xFF2AAE6E), const Color(0xFF4ECF8F)]},
    ];

    return Row(children: actions.asMap().entries.map((e) {
      final i = e.key;
      final a = e.value;
      final colors = a['gradient'] as List<Color>;
      return Expanded(child: Padding(
        padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
        child: GestureDetector(
          onTap: () => _onQuickAction(context, provider, i),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: colors[0].withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(a['icon'] as IconData, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(a['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ]),
          ),
        ),
      ));
    }).toList());
  }

  void _onQuickAction(BuildContext context, AppProvider provider, int index) {
    switch (index) {
      case 0: // Versículo Aleatório
        final v = provider.getRandomVerse();
        showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('✨ Versículo Aleatório'),
          content: Text('"${v['text']}"\n\n— ${v['ref']}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          actions: [
            TextButton(onPressed: () { Clipboard.setData(ClipboardData(text: '"${v['text']}"\n— ${v['ref']}')); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado!'))); }, child: const Text('Copiar')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        ));
        break;
      case 1: // Ler Bíblia
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadScreen()));
        break;
      case 2: // Favoritos
        _showBookmarks(context, provider);
        break;
      case 3: // Grifos
        _showHighlights(context, provider);
        break;
    }
  }

  // ── Progresso ──────────────────────────────────────────────────────────────
  Widget _progress(BuildContext context, AppProvider provider, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2E45) : Colors.white;
    final border = isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0);

    return Row(children: [
      Expanded(child: _statCard(context, '${provider.totalBooksRead}', 'Livros\nConcluídos',
          const Color(0xFF2AAE6E), Icons.auto_stories_rounded, cardBg, border)),
      const SizedBox(width: 10),
      Expanded(child: _statCard(context, '${provider.dailyStreak}🔥', 'Dias\nSeguidos',
          const Color(0xFFE8832A), Icons.local_fire_department_rounded, cardBg, border)),
      const SizedBox(width: 10),
      Expanded(child: _statCard(context, '${(provider.overallProgress * 100).toStringAsFixed(0)}%', 'Bíblia\nLida',
          AppTheme.goldPrimary, Icons.pie_chart_rounded, cardBg, border)),
    ]);
  }

  Widget _statCard(BuildContext context, String value, String label, Color color, IconData icon, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.warmGray, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }

  // ── Plano ativo ────────────────────────────────────────────────────────────
  Widget _activePlan(BuildContext context, AppProvider provider, bool isDark) {
    if (provider.activePlan == null) {
      return GestureDetector(
        onTap: () => _planSelector(context, provider),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2E45) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: AppTheme.goldPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Iniciar Plano de Leitura', style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const Text('Leia a Bíblia em 1 ano, 6 meses ou 3 meses', style: TextStyle(color: AppTheme.warmGray, fontSize: 11)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
          ]),
        ),
      );
    }

    final plan = provider.activePlan!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6B42), Color(0xFF2AAE6E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF2AAE6E).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const Spacer(),
          Text('Dia ${plan.currentDay}/${plan.totalDays}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: plan.progress, backgroundColor: Colors.white24, color: Colors.white, minHeight: 6),
        ),
        const SizedBox(height: 6),
        Text('${(plan.progress * 100).toStringAsFixed(1)}% concluído', style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ]),
    );
  }

  // ── Vídeos ─────────────────────────────────────────────────────────────────
  Widget _videos(BuildContext context, bool isDark) {
    final videos = BibleData.getVideoLessons();
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final v = videos[i];
          return GestureDetector(
            onTap: () async {
              Uri url;
              if (v.youtubeId.startsWith('search:')) {
                final query = v.youtubeId.replaceFirst('search:', '');
                url = Uri.parse('https://www.youtube.com/results?search_query=\$query');
              } else {
                url = Uri.parse('https://www.youtube.com/watch?v=\${v.youtubeId}');
              }
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
            width: 210,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2E45) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  height: 78,
                  color: const Color(0xFF1A2E45),
                  child: Center(
                    child: Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1B2A), fontWeight: FontWeight.w600, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(v.duration, style: const TextStyle(color: AppTheme.warmGray, fontSize: 10)),
                ]),
              ),
            ]),
          ),
          );
        },
      ),
    );
  }

  // ── Ações e diálogos ───────────────────────────────────────────────────────
  void _showBookmarks(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2E45),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 14), width: 36, height: 4,
            decoration: BoxDecoration(color: AppTheme.warmGray.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
        Text('Favoritos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Expanded(child: provider.bookmarks.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.bookmark_border_rounded, color: AppTheme.warmGray, size: 48),
              const SizedBox(height: 12),
              Text('Nenhum favorito ainda', style: Theme.of(context).textTheme.bodyMedium),
            ]))
          : ListView.builder(itemCount: provider.bookmarks.length, itemBuilder: (c, i) {
              final bm = provider.bookmarks[i];
              return ListTile(
                leading: const Icon(Icons.bookmark_rounded, color: AppTheme.goldPrimary),
                title: Text(bm['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${bm['bookId']} ${bm['chapter']}:${bm['verse']}', style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11)),
              );
            })),
      ]),
    );
  }

  void _showHighlights(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2E45),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 14), width: 36, height: 4,
            decoration: BoxDecoration(color: AppTheme.warmGray.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
        Text('Meus Grifos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Expanded(child: provider.highlights.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.highlight_rounded, color: AppTheme.warmGray, size: 48),
              const SizedBox(height: 12),
              Text('Nenhum grifo ainda', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Selecione um versículo na leitura para grilar', style: TextStyle(color: AppTheme.warmGray, fontSize: 12), textAlign: TextAlign.center),
            ]))
          : ListView.builder(itemCount: provider.highlights.length, itemBuilder: (c, i) {
              final hl = provider.highlights[i];
              final color = Color(int.parse((hl['color'] ?? '#FFD700').replaceAll('#', '0xFF')));
              return ListTile(
                leading: Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                title: Text(hl['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${hl['bookId']} ${hl['chapter']}:${hl['verse']}', style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11)),
              );
            })),
      ]),
    );
  }

  void _planSelector(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2E45),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(bottom: 16), width: 36, height: 4,
            decoration: BoxDecoration(color: AppTheme.warmGray.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
        Text('Plano de Leitura', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ...[
          ('1year',   '📅 Bíblia em 1 Ano',     '~3 capítulos por dia',  365, const Color(0xFF3B6DDE)),
          ('6months', '⚡ Bíblia em 6 Meses',    '~6 capítulos por dia',  180, const Color(0xFFE8832A)),
          ('3months', '🚀 NT em 3 Meses',         'Novo Testamento',        90, const Color(0xFF2AAE6E)),
        ].map((p) => GestureDetector(
          onTap: () {
            provider.setActivePlan(provider.createReadingPlan(p.$1));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.$2} iniciado! 🎉')));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.$5.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.$5.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: p.$5.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(p.$2.split(' ').first, style: const TextStyle(fontSize: 20)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.$2.replaceFirst(RegExp(r'^[^\s]+ '), ''), style: TextStyle(color: p.$5, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(p.$3, style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: p.$5.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${p.$4}d', style: TextStyle(color: p.$5, fontWeight: FontWeight.bold, fontSize: 11))),
            ]),
          ),
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}
