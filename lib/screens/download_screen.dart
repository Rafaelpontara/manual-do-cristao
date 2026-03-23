import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> with TickerProviderStateMixin {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  double _progress = 0.0;
  String _statusMsg = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _versions = [
    {'id': 'acf',  'name': 'Almeida Corrigida Fiel',      'abbr': 'ACF',  'size': '12 MB', 'selected': false},
    {'id': 'arc',  'name': 'Almeida Revista e Corrigida', 'abbr': 'ARC',  'size': '11 MB', 'selected': false},
    {'id': 'ntlh', 'name': 'Nova Tradução na Linguagem de Hoje', 'abbr': 'NTLH', 'size': '13 MB', 'selected': false},
    {'id': 'nvi',  'name': 'Nova Versão Internacional',   'abbr': 'NVI',  'size': '12 MB', 'selected': false},
    {'id': 'teb',  'name': 'Tradução Ecumênica da Bíblia','abbr': 'TEB',  'size': '14 MB', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadSavedState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDownloaded = prefs.getBool('bible_downloaded') ?? false;
      for (var v in _versions) {
        v['selected'] = prefs.getBool('downloaded_${v['id']}') ?? false;
      }
    });
  }

  Future<void> _startDownload() async {
    final selected = _versions.where((v) => v['selected'] == true).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma versão para baixar'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isDownloading = true; _progress = 0.0; });

    // Simula download progressivo
    for (int i = 0; i < selected.length; i++) {
      final version = selected[i];
      setState(() => _statusMsg = 'Baixando ${version['abbr']}...');
      for (double p = 0; p <= 1.0; p += 0.05) {
        await Future.delayed(const Duration(milliseconds: 60));
        setState(() => _progress = (i / selected.length) + (p / selected.length));
      }
    }

    setState(() { _statusMsg = 'Finalizando...'; });
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bible_downloaded', true);
    for (var v in _versions) {
      if (v['selected'] == true) await prefs.setBool('downloaded_${v['id']}', true);
    }

    setState(() { _isDownloading = false; _isDownloaded = true; _progress = 1.0; _statusMsg = ''; });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Bíblia disponível offline!'),
          backgroundColor: Color(0xFF2AAE6E),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteDownload() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover dados offline'),
        content: const Text('Deseja remover a Bíblia offline? Você precisará de internet para ler.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('bible_downloaded', false);
      for (var v in _versions) {
        await prefs.setBool('downloaded_${v['id']}', false);
        v['selected'] = false;
      }
      setState(() { _isDownloaded = false; _progress = 0.0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final bg = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F0E8);
    final cardBg = isDark ? const Color(0xFF1A2E45) : Colors.white;
    final border = isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0D1B2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Acesso Offline',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            fontWeight: FontWeight.w700, fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Banner de status
          _statusBanner(isDark, cardBg, border),
          const SizedBox(height: 24),

          // Benefícios
          _sectionLabel('POR QUE USAR OFFLINE?', isDark),
          const SizedBox(height: 12),
          _benefitsCard(cardBg, border),
          const SizedBox(height: 24),

          // Seleção de versões
          if (!_isDownloaded) ...[
            _sectionLabel('ESCOLHA AS VERSÕES', isDark),
            const SizedBox(height: 12),
            ..._versions.map((v) => _versionTile(v, isDark, cardBg, border)).toList(),
            const SizedBox(height: 24),
          ],

          // Progresso do download
          if (_isDownloading) ...[
            _downloadProgress(isDark, cardBg, border),
            const SizedBox(height: 24),
          ],

          // Botão de ação
          if (!_isDownloading) _actionButton(),
          const SizedBox(height: 16),

          // Botão de remover
          if (_isDownloaded && !_isDownloading)
            Center(
              child: TextButton.icon(
                onPressed: _deleteDownload,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                label: const Text('Remover dados offline', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      color: isDark ? const Color(0xFF5A7A99) : AppTheme.warmGray,
      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
    ),
  );

  Widget _statusBanner(bool isDark, Color cardBg, Color border) {
    if (_isDownloaded) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2AAE6E), Color(0xFF1A8A55)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF2AAE6E).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bíblia disponível offline!', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${_versions.where((v) => v['selected'] == true).length} versões baixadas',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
            ),
          ])),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1F3864), const Color(0xFF2E75B6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1F3864).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bíblia Offline', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Leia sem internet, a qualquer hora e em qualquer lugar.',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
        ])),
      ]),
    );
  }

  Widget _benefitsCard(Color cardBg, Color border) {
    final items = [
      {'icon': Icons.wifi_off_rounded, 'color': const Color(0xFF3B6DDE), 'text': 'Leia sem internet em qualquer lugar'},
      {'icon': Icons.bolt_rounded, 'color': const Color(0xFFE8832A), 'text': 'Carregamento instantâneo, sem espera'},
      {'icon': Icons.battery_saver_rounded, 'color': const Color(0xFF2AAE6E), 'text': 'Economiza bateria e dados móveis'},
      {'icon': Icons.lock_rounded, 'color': AppTheme.goldPrimary, 'text': 'Acesso garantido em viagens e áreas rurais'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item['text'] as String, style: const TextStyle(fontSize: 14))),
        ]),
      )).toList()),
    );
  }

  Widget _versionTile(Map<String, dynamic> version, bool isDark, Color cardBg, Color border) {
    final isSelected = version['selected'] == true;
    return GestureDetector(
      onTap: () => setState(() => version['selected'] = !isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary.withOpacity(0.08) : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppTheme.goldPrimary : border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.goldPrimary : (isDark ? const Color(0xFF243B55) : const Color(0xFFF0EAD8)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(
              version['abbr'],
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.warmGray,
                fontSize: 11, fontWeight: FontWeight.w800,
              ),
            )),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(version['name'], style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            )),
            const SizedBox(height: 2),
            Text('Tamanho: ${version['size']}', style: TextStyle(
              color: AppTheme.warmGray, fontSize: 12,
            )),
          ])),
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isSelected ? AppTheme.goldPrimary : AppTheme.warmGray,
            size: 22,
          ),
        ]),
      ),
    );
  }

  Widget _downloadProgress(bool isDark, Color cardBg, Color border) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldPrimary),
          ),
          const SizedBox(width: 12),
          Text(_statusMsg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: isDark ? const Color(0xFF243B55) : const Color(0xFFE0D5C0),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldPrimary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}% concluído',
          style: TextStyle(color: AppTheme.warmGray, fontSize: 12),
        ),
      ]),
    );
  }

  Widget _actionButton() {
    if (_isDownloaded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
          label: const Text('Ler a Bíblia Offline', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2AAE6E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
        ),
      );
    }

    final selected = _versions.where((v) => v['selected'] == true).toList();
    final totalSize = selected.length * 12;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startDownload,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          selected.isEmpty
              ? 'Selecione uma versão acima'
              : 'Baixar ${selected.length} versão(ões) • ~${totalSize} MB',
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected.isEmpty ? AppTheme.warmGray : AppTheme.goldPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: selected.isEmpty ? 0 : 4,
        ),
      ),
    );
  }
}
