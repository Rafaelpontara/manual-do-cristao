import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../services/offline_service.dart';
import '../theme/app_theme.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});
  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Estado geral ───────────────────────────────────────────────────────────
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusMsg = '';
  bool _cancelRequested = false;
  int _cachedVerses = 0;

  // ── Versão embarcada (acf.json) ────────────────────────────────────────────
  static const String _embeddedVersion = 'acf';
  static const String _embeddedVersionName = 'Almeida Corrigida Fiel';
  static const int _embeddedTotalVerses = 31102;
  bool _embeddedLoaded = false;

  // ── Versões adicionais para download ──────────────────────────────────────
  final List<Map<String, dynamic>> _extraVersions = [
    {
      'id': 'nvi',
      'name': 'Nova Versão Internacional',
      'abbr': 'NVI',
      'desc': 'Linguagem contemporânea e fiel ao original',
      'selected': false,
      'downloaded': false,
      'verseCount': 0,
    },
    {
      'id': 'arc',
      'name': 'Almeida Revista e Corrigida',
      'abbr': 'ARC',
      'desc': 'Clássica revisão da Almeida',
      'selected': false,
      'downloaded': false,
      'verseCount': 0,
    },
    {
      'id': 'ntlh',
      'name': 'Nova Tradução na Linguagem de Hoje',
      'abbr': 'NTLH',
      'desc': 'Linguagem simples e acessível',
      'selected': false,
      'downloaded': false,
      'verseCount': 0,
    },
    {
      'id': 'naa',
      'name': 'Nova Almeida Atualizada',
      'abbr': 'NAA',
      'desc': 'Versão atualizada da Almeida',
      'selected': false,
      'downloaded': false,
      'verseCount': 0,
    },
  ];

  // Livros com capítulos para download
  static const List<Map<String, dynamic>> _bibleBooks = [
    {'id': 'gn','name': 'Gênesis','chapters': 50},
    {'id': 'ex','name': 'Êxodo','chapters': 40},
    {'id': 'lv','name': 'Levítico','chapters': 27},
    {'id': 'nm','name': 'Números','chapters': 36},
    {'id': 'dt','name': 'Deuteronômio','chapters': 34},
    {'id': 'js','name': 'Josué','chapters': 24},
    {'id': 'jz','name': 'Juízes','chapters': 21},
    {'id': 'rt','name': 'Rute','chapters': 4},
    {'id': '1sm','name': '1 Samuel','chapters': 31},
    {'id': '2sm','name': '2 Samuel','chapters': 24},
    {'id': '1rs','name': '1 Reis','chapters': 22},
    {'id': '2rs','name': '2 Reis','chapters': 25},
    {'id': '1cr','name': '1 Crônicas','chapters': 29},
    {'id': '2cr','name': '2 Crônicas','chapters': 36},
    {'id': 'ed','name': 'Esdras','chapters': 10},
    {'id': 'ne','name': 'Neemias','chapters': 13},
    {'id': 'et','name': 'Ester','chapters': 10},
    {'id': 'jo','name': 'Jó','chapters': 42},
    {'id': 'sl','name': 'Salmos','chapters': 150},
    {'id': 'pv','name': 'Provérbios','chapters': 31},
    {'id': 'ec','name': 'Eclesiastes','chapters': 12},
    {'id': 'ct','name': 'Cantares','chapters': 8},
    {'id': 'is','name': 'Isaías','chapters': 66},
    {'id': 'jr','name': 'Jeremias','chapters': 52},
    {'id': 'lm','name': 'Lamentações','chapters': 5},
    {'id': 'ez','name': 'Ezequiel','chapters': 48},
    {'id': 'dn','name': 'Daniel','chapters': 12},
    {'id': 'os','name': 'Oséias','chapters': 14},
    {'id': 'jl','name': 'Joel','chapters': 3},
    {'id': 'am','name': 'Amós','chapters': 9},
    {'id': 'ob','name': 'Obadias','chapters': 1},
    {'id': 'jn','name': 'Jonas','chapters': 4},
    {'id': 'mq','name': 'Miquéias','chapters': 7},
    {'id': 'na','name': 'Naum','chapters': 3},
    {'id': 'hc','name': 'Habacuque','chapters': 3},
    {'id': 'sf','name': 'Sofonias','chapters': 3},
    {'id': 'ag','name': 'Ageu','chapters': 2},
    {'id': 'zc','name': 'Zacarias','chapters': 14},
    {'id': 'ml','name': 'Malaquias','chapters': 4},
    {'id': 'mt','name': 'Mateus','chapters': 28},
    {'id': 'mc','name': 'Marcos','chapters': 16},
    {'id': 'lc','name': 'Lucas','chapters': 24},
    {'id': 'jo2','name': 'João','chapters': 21},
    {'id': 'at','name': 'Atos','chapters': 28},
    {'id': 'rm','name': 'Romanos','chapters': 16},
    {'id': '1co','name': '1 Coríntios','chapters': 16},
    {'id': '2co','name': '2 Coríntios','chapters': 13},
    {'id': 'gl','name': 'Gálatas','chapters': 6},
    {'id': 'ef','name': 'Efésios','chapters': 6},
    {'id': 'fp','name': 'Filipenses','chapters': 4},
    {'id': 'cl','name': 'Colossenses','chapters': 4},
    {'id': '1ts','name': '1 Tessalonicenses','chapters': 5},
    {'id': '2ts','name': '2 Tessalonicenses','chapters': 3},
    {'id': '1tm','name': '1 Timóteo','chapters': 6},
    {'id': '2tm','name': '2 Timóteo','chapters': 4},
    {'id': 'tt','name': 'Tito','chapters': 3},
    {'id': 'fm','name': 'Filemom','chapters': 1},
    {'id': 'hb','name': 'Hebreus','chapters': 13},
    {'id': 'tg','name': 'Tiago','chapters': 5},
    {'id': '1pe','name': '1 Pedro','chapters': 5},
    {'id': '2pe','name': '2 Pedro','chapters': 3},
    {'id': '1jo','name': '1 João','chapters': 5},
    {'id': '2jo','name': '2 João','chapters': 1},
    {'id': '3jo','name': '3 João','chapters': 1},
    {'id': 'jd','name': 'Judas','chapters': 1},
    {'id': 'ap','name': 'Apocalipse','chapters': 22},
  ];

  static const int _totalChapters = 1189;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await OfflineService.getCachedVerseCount();

    // Verifica se o acf.json embarcado está carregado
    bool embedded = false;
    try {
      await rootBundle.loadString('assets/bible/acf.json');
      embedded = true;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _embeddedLoaded = embedded;
        _cachedVerses = count;
        for (final v in _extraVersions) {
          v['downloaded'] = prefs.getBool('downloaded_${v['id']}') ?? false;
          v['verseCount'] = prefs.getInt('verses_${v['id']}') ?? 0;
        }
      });
    }
  }

  // ── Download de versão adicional via bible-api.com ────────────────────────
  Future<void> _startDownload() async {
    final selected = _extraVersions.where((v) => v['selected'] == true).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma versão'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _cancelRequested = false;
      _statusMsg = 'Iniciando download...';
    });

    final prefs = await SharedPreferences.getInstance();
    int totalDone = 0;
    final totalOps = selected.length * _totalChapters;

    for (final version in selected) {
      if (_cancelRequested) break;
      final versionId = version['id'] as String;
      int versesCount = 0;

      for (final book in _bibleBooks) {
        if (_cancelRequested) break;
        final bookId = book['id'] as String;
        final apiBookId = bookId == 'jo2' ? 'JHN' : bookId.toUpperCase();
        final chapters = book['chapters'] as int;

        for (int ch = 1; ch <= chapters; ch++) {
          if (_cancelRequested) break;

          final alreadyCached = await OfflineService.isChapterDownloaded(
              bookId, ch, versionId);
          if (!alreadyCached) {
            try {
              // Usa bible-api.com como fonte principal
              final url =
                  'https://bible-api.com/data/almeida/$apiBookId/$ch';
              final response = await http
                  .get(Uri.parse(url))
                  .timeout(const Duration(seconds: 15));

              if (response.statusCode == 200) {
                final data = json.decode(response.body);
                final versesList = data['verses'] as List? ?? [];
                final verses = versesList
                    .map<Map<String, String>>((v) => {
                          'verse': '${v['verse'] ?? ''}',
                          'text': '${(v['text'] as String? ?? '').trim()}',
                        })
                    .toList();

                if (verses.isNotEmpty) {
                  await OfflineService.saveChapter(
                      bookId, ch, versionId, verses);
                  versesCount += verses.length;
                }
              }
              await Future.delayed(const Duration(milliseconds: 800));
            } catch (_) {}
          }

          totalDone++;
          if (mounted) {
            setState(() {
              _progress = totalDone / totalOps;
              _statusMsg =
                  '${version['abbr']}: ${book['name']} cap. $ch';
            });
          }
        }
      }

      await prefs.setBool('downloaded_$versionId', true);
      await prefs.setInt('verses_$versionId', versesCount);
      if (mounted) {
        setState(() {
          version['downloaded'] = true;
          version['verseCount'] = versesCount;
        });
      }
    }

    final count = await OfflineService.getCachedVerseCount();
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _progress = _cancelRequested ? _progress : 1.0;
        _statusMsg = _cancelRequested ? 'Cancelado.' : '';
        _cachedVerses = count;
      });

      if (!_cancelRequested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Versão disponível offline!'),
            backgroundColor: Color(0xFF2AAE6E),
          ),
        );
      }
    }
  }

  // ── Remover versão adicional ───────────────────────────────────────────────
  Future<void> _deleteVersion(Map<String, dynamic> version) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: Text('Remover ${version['abbr']}'),
        content: Text(
            'Deseja remover a versão ${version['name']} do armazenamento offline?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OfflineService.clearVersionCache(version['id'] as String);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('downloaded_${version['id']}', false);
      await prefs.setInt('verses_${version['id']}', 0);
      if (mounted) {
        setState(() {
          version['downloaded'] = false;
          version['verseCount'] = 0;
          version['selected'] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${version['abbr']} removida do armazenamento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final bg = isDark ? AppTheme.navyDeep : AppTheme.creamLight;
    final cardBg = isDark ? AppTheme.navyMid : Colors.white;
    final border = isDark ? AppTheme.navyLight : const Color(0xFFE8DCC8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Versões Offline',
            style: TextStyle(
                color: AppTheme.goldPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppTheme.navyDeep),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.goldPrimary,
          unselectedLabelColor: AppTheme.warmGray,
          indicatorColor: AppTheme.goldPrimary,
          tabs: const [
            Tab(text: 'Versões Disponíveis'),
            Tab(text: 'Gerenciar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDownloadTab(isDark, cardBg, border),
          _buildManageTab(isDark, cardBg, border),
        ],
      ),
    );
  }

  // ── Aba 1: Baixar versões adicionais ──────────────────────────────────────
  Widget _buildDownloadTab(bool isDark, Color cardBg, Color border) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Card da versão embarcada (ACF)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.forestGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.forestGreen.withOpacity(0.4)),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.forestGreen, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Almeida Corrigida Fiel (ACF)',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.forestGreen)),
                Text(
                  _embeddedLoaded
                      ? '✅ Incluída no app — ${_embeddedTotalVerses.toString()} versículos'
                      : '⚠️ Arquivo não encontrado — verifique o pubspec.yaml',
                  style: TextStyle(
                      fontSize: 12,
                      color: _embeddedLoaded
                          ? AppTheme.warmGray
                          : Colors.orange),
                ),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 20),

        // Título
        const Text('VERSÕES ADICIONAIS',
            style: TextStyle(
                color: AppTheme.warmGray,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text(
          'Selecione versões adicionais para usar offline. Requer internet para download (~30 min por versão).',
          style: TextStyle(color: AppTheme.warmGray, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 16),

        // Lista de versões
        ..._extraVersions.map((v) => _buildVersionCard(v, isDark, cardBg, border)),
        const SizedBox(height: 16),

        // Barra de progresso (durante download)
        if (_isDownloading) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? const Color(0xFF1E3048)
                  : const Color(0xFFE8DCC8),
              color: AppTheme.goldPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text(
              _statusMsg,
              style: const TextStyle(
                  color: AppTheme.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: AppTheme.goldPrimary, fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 16),
        ],

        // Botões
        if (_isDownloading)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _cancelRequested = true),
              icon: const Icon(Icons.stop_rounded, color: Colors.red),
              label: const Text('Cancelar Download',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        else
          _buildDownloadButton(),
      ]),
    );
  }

  Widget _buildVersionCard(Map<String, dynamic> v, bool isDark, Color cardBg, Color border) {
    final isSelected = v['selected'] as bool;
    final isDownloaded = v['downloaded'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.goldPrimary.withOpacity(0.08)
            : cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.goldPrimary
              : isDownloaded
                  ? AppTheme.forestGreen.withOpacity(0.4)
                  : border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: isDownloaded
            ? null
            : () => setState(() => v['selected'] = !isSelected),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isDownloaded
                ? AppTheme.forestGreen.withOpacity(0.15)
                : AppTheme.goldPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              v['abbr'] as String,
              style: TextStyle(
                color: isDownloaded
                    ? AppTheme.forestGreen
                    : AppTheme.goldPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        title: Text(v['name'] as String,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDownloaded ? AppTheme.forestGreen : null)),
        subtitle: Text(
          isDownloaded
              ? '✅ Disponível offline (${v['verseCount']} versículos)'
              : v['desc'] as String,
          style: TextStyle(
              fontSize: 11,
              color: isDownloaded ? AppTheme.forestGreen : AppTheme.warmGray),
        ),
        trailing: isDownloaded
            ? const Icon(Icons.check_circle_rounded,
                color: AppTheme.forestGreen, size: 20)
            : Checkbox(
                value: isSelected,
                onChanged: (_) =>
                    setState(() => v['selected'] = !isSelected),
                activeColor: AppTheme.goldPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    final selected = _extraVersions.where((v) => v['selected'] == true).toList();
    final allDownloaded = _extraVersions.every((v) => v['downloaded'] == true);

    if (allDownloaded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.forestGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.forestGreen.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.forestGreen),
            SizedBox(width: 8),
            Text('Todas as versões estão disponíveis offline!',
                style: TextStyle(
                    color: AppTheme.forestGreen, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: selected.isEmpty ? null : _startDownload,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          selected.isEmpty
              ? 'Selecione uma versão acima'
              : 'Baixar ${selected.length} versão(ões) selecionada(s)',
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected.isEmpty ? AppTheme.warmGray : AppTheme.goldPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: selected.isEmpty ? 0 : 4,
        ),
      ),
    );
  }

  // ── Aba 2: Gerenciar versões offline ──────────────────────────────────────
  Widget _buildManageTab(bool isDark, Color cardBg, Color border) {
    final downloadedExtras =
        _extraVersions.where((v) => v['downloaded'] == true).toList();
    final totalOffline =
        (_embeddedLoaded ? _embeddedTotalVerses : 0) +
        downloadedExtras.fold<int>(
            0, (sum, v) => sum + (v['verseCount'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Resumo geral
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.navyMid, AppTheme.navyLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.goldPrimary.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.storage_rounded,
                color: AppTheme.goldPrimary, size: 32),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Armazenamento Offline',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text(
                  '$totalOffline versículos disponíveis',
                  style: const TextStyle(
                      color: AppTheme.warmGray, fontSize: 12),
                ),
                Text(
                  '${1 + downloadedExtras.length} versão(ões) instalada(s)',
                  style: const TextStyle(
                      color: AppTheme.goldPrimary, fontSize: 12),
                ),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 20),

        const Text('VERSÕES INSTALADAS',
            style: TextStyle(
                color: AppTheme.warmGray,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 12),

        // ACF embarcada (não pode ser removida)
        _buildInstalledCard(
          abbr: 'ACF',
          name: 'Almeida Corrigida Fiel',
          verseCount: _embeddedLoaded ? _embeddedTotalVerses : 0,
          isEmbedded: true,
          isDark: isDark,
          cardBg: cardBg,
          border: border,
        ),

        // Versões adicionais baixadas
        ...downloadedExtras.map((v) => _buildInstalledCard(
          abbr: v['abbr'] as String,
          name: v['name'] as String,
          verseCount: v['verseCount'] as int,
          isEmbedded: false,
          isDark: isDark,
          cardBg: cardBg,
          border: border,
          onDelete: () => _deleteVersion(v),
        )),

        if (downloadedExtras.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded,
                  color: AppTheme.warmGray, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nenhuma versão adicional instalada.\nVá para "Versões Disponíveis" para baixar.',
                  style: TextStyle(
                      color: AppTheme.warmGray, fontSize: 13, height: 1.5),
                ),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 24),
        const Text('CACHE DE LEITURA',
            style: TextStyle(
                color: AppTheme.warmGray,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cached_rounded,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cache de capítulos lidos',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('$_cachedVerses versículos em cache',
                      style: const TextStyle(
                          color: AppTheme.warmGray, fontSize: 12)),
                ],
              )),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await OfflineService.clearCache();
                  final count = await OfflineService.getCachedVerseCount();
                  if (mounted) setState(() => _cachedVerses = count);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache limpo!')),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
                label: const Text('Limpar Cache',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildInstalledCard({
    required String abbr,
    required String name,
    required int verseCount,
    required bool isEmbedded,
    required bool isDark,
    required Color cardBg,
    required Color border,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isEmbedded
                ? AppTheme.forestGreen.withOpacity(0.3)
                : border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isEmbedded
                ? AppTheme.forestGreen.withOpacity(0.15)
                : AppTheme.goldPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(abbr,
                style: TextStyle(
                  color: isEmbedded
                      ? AppTheme.forestGreen
                      : AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            Text(
              isEmbedded
                  ? '📦 Incluída no app — $verseCount versículos'
                  : '💾 Baixada — $verseCount versículos',
              style: const TextStyle(
                  color: AppTheme.warmGray, fontSize: 11),
            ),
          ],
        )),
        if (isEmbedded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('PADRÃO',
                style: TextStyle(
                    color: AppTheme.forestGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          )
        else
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 20),
            onPressed: onDelete,
            tooltip: 'Remover versão',
          ),
      ]),
    );
  }
}
