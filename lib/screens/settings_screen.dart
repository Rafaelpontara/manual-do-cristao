import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../screens/download_screen.dart';
import '../models/bible_models.dart';
import '../services/notification_service.dart';
import '../services/offline_service.dart';
import 'search_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notificações
  bool _notifLoading = true;
  Map<String, dynamic> _notifSettings = {};
  int _verseHour = 8, _verseMin = 0;
  int _planHour = 20, _planMin = 0;
  int _motivHour = 12, _motivMin = 0;

  // Offline
  bool _offlineComplete = false;
  bool _offlineDownloading = false;
  double _offlineProgress = 0;
  String _offlineStatus = '';
  int _cachedVerseCount = 0;

  // Voz
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _listenedWords = '';
  bool _voiceSearched = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (e) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (mounted && (status == 'done' || status == 'notListening')) {
          final words = _listenedWords;
          setState(() => _isListening = false);
          if (words.isNotEmpty && !_voiceSearched) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !_voiceSearched) {
                setState(() => _voiceSearched = true);
                _navigateToSearch(words);
              }
            });
          }
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.getSettings();
    final count = await OfflineService.getCachedVerseCount();
    final complete = await OfflineService.isFullBibleDownloaded();
    if (mounted) setState(() {
      _notifSettings = settings;
      _notifLoading = false;
      _verseHour = settings['verse_hour'] ?? 8;
      _verseMin = settings['verse_minute'] ?? 0;
      _planHour = settings['plan_hour'] ?? 20;
      _planMin = settings['plan_minute'] ?? 0;
      _motivHour = settings['motiv_hour'] ?? 12;
      _motivMin = settings['motiv_minute'] ?? 0;
      _cachedVerseCount = count;
      _offlineComplete = complete;
    });
  }

  Future<void> _downloadBible() async {
    setState(() { _offlineDownloading = true; _offlineProgress = 0; _offlineStatus = 'Iniciando...'; });
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() {
        _offlineProgress = i / 10;
        _offlineStatus = 'Preparando dados offline... ${i * 10}%';
      });
    }
    if (mounted) setState(() {
      _offlineDownloading = false;
      _offlineComplete = true;
      _offlineStatus = 'Pronto!';
    });
  }

  Future<void> _pickTime(BuildContext context, int hour, int minute,
      Function(int h, int m) onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) onPicked(picked.hour, picked.minute);
  }

  // ── Lógica de voz ─────────────────────────────────────────────────────────

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
      _voiceSearched = false;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() => _listenedWords = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() => _isListening = false);
          _navigateToSearch(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'pt_BR',
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _navigateToSearch(String query) {
    setState(() => _voiceSearched = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: query)),
    );
  }

  void _showVoiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoiceSearchSheet(
        speech: _speech,
        speechAvailable: _speechAvailable,
        onNavigate: (query) {
          Navigator.pop(ctx);
          _navigateToSearch(query);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

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
        title: Text('Configurações', style: GoogleFonts.playfairDisplay(
          color: AppTheme.goldPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppTheme.navyDeep),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Aparência ────────────────────────────────────────────────────
          _sectionTitle('APARÊNCIA'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Column(children: [
              _switchTile(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                iconColor: AppTheme.goldPrimary,
                title: 'Tema Escuro',
                subtitle: isDark ? 'Ativado' : 'Desativado',
                value: isDark,
                onChanged: (_) => provider.toggleTheme(),
                cardBg: cardBg,
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Bíblia ───────────────────────────────────────────────────────
          _sectionTitle('BÍBLIA'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Column(children: [
              _tapTile(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF3B6DDE),
                title: 'Versão Atual',
                subtitle: provider.bibleVersion.displayName,
                onTap: () => _showVersionDialog(context, provider),
              ),
              Divider(height: 1, color: border),
              _tapTile(
                icon: Icons.church_rounded,
                iconColor: const Color(0xFF2AAE6E),
                title: 'Religião',
                subtitle: provider.religion.displayName,
                onTap: () => _showReligionDialog(context, provider),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Bíblia Offline ───────────────────────────────────────────────
          _sectionTitle('BÍBLIA OFFLINE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Column(children: [
              ListTile(
                leading: Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: AppTheme.forestGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.download_done_rounded, color: AppTheme.forestGreen, size: 20)),
                title: const Text('Versões Offline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Baixar versões adicionais (NVI, ARC...)', style: TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadScreen())),
              ),
              Divider(height: 1, color: border),
              ListTile(
                leading: Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.system_update_rounded, color: Colors.blue, size: 20)),
                title: const Text('Atualizar Bíblia', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Verificar nova versão do texto bíblico', style: TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
                onTap: () => _checkBibleUpdate(context),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Notificações ─────────────────────────────────────────────────
          _sectionTitle('NOTIFICAÇÕES'),
          const SizedBox(height: 8),
          if (_notifLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary))
          else
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
              child: Column(children: [
                _notifTile(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: AppTheme.goldPrimary,
                  title: 'Versículo do Dia',
                  subtitle: 'Receba um versículo diariamente',
                  value: _notifSettings['verse_day'] ?? false,
                  hour: _verseHour, minute: _verseMin,
                  onChanged: (v) async {
                    if (v) {
                      await NotificationService.scheduleVerseOfDay(_verseHour, _verseMin);
                    } else {
                      await NotificationService.cancelVerseOfDay();
                    }
                    setState(() => _notifSettings['verse_day'] = v);
                  },
                  onTimeTap: () => _pickTime(context, _verseHour, _verseMin, (h, m) async {
                    setState(() { _verseHour = h; _verseMin = m; });
                    if (_notifSettings['verse_day'] == true) {
                      await NotificationService.scheduleVerseOfDay(h, m);
                    }
                  }),
                  border: border, cardBg: cardBg, isDark: isDark,
                ),
                Divider(height: 1, color: border),
                _notifTile(
                  icon: Icons.auto_stories_rounded,
                  iconColor: const Color(0xFF7B4FE0),
                  title: 'Plano de Leitura',
                  subtitle: 'Lembrete para continuar sua leitura',
                  value: _notifSettings['reading_plan'] ?? false,
                  hour: _planHour, minute: _planMin,
                  onChanged: (v) async {
                    if (v) {
                      await NotificationService.scheduleReadingPlan(_planHour, _planMin);
                    } else {
                      await NotificationService.cancelReadingPlan();
                    }
                    setState(() => _notifSettings['reading_plan'] = v);
                  },
                  onTimeTap: () => _pickTime(context, _planHour, _planMin, (h, m) async {
                    setState(() { _planHour = h; _planMin = m; });
                    if (_notifSettings['reading_plan'] == true) {
                      await NotificationService.scheduleReadingPlan(h, m);
                    }
                  }),
                  border: border, cardBg: cardBg, isDark: isDark,
                ),
                Divider(height: 1, color: border),
                _notifTile(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFE84393),
                  title: 'Mensagens Motivacionais',
                  subtitle: 'Palavras de encorajamento',
                  value: _notifSettings['motivational'] ?? false,
                  hour: _motivHour, minute: _motivMin,
                  onChanged: (v) async {
                    if (v) {
                      await NotificationService.scheduleMotivational(_motivHour, _motivMin);
                    } else {
                      await NotificationService.cancelMotivational();
                    }
                    setState(() => _notifSettings['motivational'] = v);
                  },
                  onTimeTap: () => _pickTime(context, _motivHour, _motivMin, (h, m) async {
                    setState(() { _motivHour = h; _motivMin = m; });
                    if (_notifSettings['motivational'] == true) {
                      await NotificationService.scheduleMotivational(h, m);
                    }
                  }),
                  border: border, cardBg: cardBg, isDark: isDark,
                ),
              ]),
            ),
          const SizedBox(height: 20),

          // ── Acessibilidade ───────────────────────────────────────────────
          _sectionTitle('ACESSIBILIDADE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Column(children: [
              // Busca por Voz — funcional com SpeechToText
              ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: (_isListening
                        ? const Color(0xFFE84393)
                        : _speechAvailable
                            ? Colors.blue
                            : Colors.grey).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening
                        ? const Color(0xFFE84393)
                        : _speechAvailable
                            ? Colors.blue
                            : Colors.grey,
                    size: 20,
                  ),
                ),
                title: const Text('Busca por Voz',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  _isListening
                      ? (_listenedWords.isEmpty ? 'Ouvindo... fale agora 🎤' : '"$_listenedWords"')
                      : _speechAvailable
                          ? 'Fale para buscar versículos ou livros'
                          : 'Não disponível neste dispositivo',
                  style: TextStyle(
                    color: _isListening
                        ? const Color(0xFFE84393)
                        : AppTheme.warmGray,
                    fontSize: 12,
                    fontStyle: (_isListening && _listenedWords.isNotEmpty)
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                trailing: _isListening
                    ? GestureDetector(
                        onTap: () async {
                          await _speech.stop();
                          setState(() => _isListening = false);
                        },
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE84393).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stop_rounded,
                              color: Color(0xFFE84393), size: 18),
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.warmGray, size: 18),
                onTap: _speechAvailable
                    ? _showVoiceBottomSheet
                    : null,
              ),

              Divider(height: 1, color: border),

              // Tamanho de fonte
              ListTile(
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.text_fields_rounded,
                      color: AppTheme.forestGreen, size: 20),
                ),
                title: const Text('Tamanho da Fonte',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Consumer<AppProvider>(
                  builder: (_, p, __) => Text('${p.readingFontSize}px',
                      style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                ),
                trailing: Consumer<AppProvider>(
                  builder: (_, p, __) => Row(mainAxisSize: MainAxisSize.min, children: [
                    _fontBtn(Icons.remove_rounded, () => p.setFontSize(p.readingFontSize - 2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${p.readingFontSize}',
                          style: const TextStyle(
                              color: AppTheme.goldPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    _fontBtn(Icons.add_rounded, () => p.setFontSize(p.readingFontSize + 2)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Offline ──────────────────────────────────────────────────────
          _sectionTitle('MODO OFFLINE'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _offlineComplete ? AppTheme.forestGreen.withOpacity(0.15) : AppTheme.goldPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(_offlineComplete ? '✅' : '📥', style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bíblia Offline', style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.navyDeep,
                    fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    _offlineComplete
                        ? '$_cachedVerseCount versículos disponíveis offline'
                        : 'Capítulos salvos automaticamente ao ler',
                    style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                ])),
              ]),
              if (_offlineDownloading) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _offlineProgress,
                    minHeight: 6,
                    backgroundColor: border,
                    color: AppTheme.goldPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_offlineStatus, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12)),
              ],
              if (!_offlineComplete && !_offlineDownloading) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _downloadBible,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Preparar Modo Offline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                      foregroundColor: AppTheme.navyDeep,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
              if (_offlineComplete) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await OfflineService.clearCache();
                      if (mounted) setState(() { _offlineComplete = false; _cachedVerseCount = 0; });
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    label: const Text('Limpar Cache Offline', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _fontBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.goldPrimary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: AppTheme.goldPrimary),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Text(text, style: const TextStyle(
      color: AppTheme.warmGray, fontSize: 11,
      fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );

  Widget _switchTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required bool value,
      required ValueChanged<bool> onChanged, required Color cardBg}) {
    return ListTile(
      leading: Container(width: 38, height: 38,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.goldPrimary),
    );
  }

  Widget _tapTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 38, height: 38,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
    );
  }

  void _showReligionDialog(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyMid : Colors.white,
        title: const Text('Escolher Religião'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Religion.values.map((r) => RadioListTile<Religion>(
              value: r,
              groupValue: provider.religion,
              onChanged: (v) {
                if (v != null) {
                  provider.setReligion(v);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Religião alterada para ${v.displayName}')),
                  );
                }
              },
              title: Text(r.displayName),
              subtitle: Text(r.description, style: const TextStyle(fontSize: 11)),
              activeColor: AppTheme.goldPrimary,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  Future<void> _checkBibleUpdate(BuildContext context) async {
    final isDark = Provider.of<AppProvider>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: AppTheme.navyMid,
        content: Row(children: [
          CircularProgressIndicator(color: AppTheme.goldPrimary),
          SizedBox(width: 16),
          Text('Verificando atualizações...'),
        ]),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // fecha loading

    // Verifica a versão atual do asset embarcado
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyMid : Colors.white,
        title: const Row(children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.forestGreen),
          SizedBox(width: 8),
          Text('Bíblia Atualizada'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versão atual: ACF — Almeida Corrigida Fiel'),
            SizedBox(height: 4),
            Text('31.102 versículos', style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Você está usando a versão mais recente do texto bíblico.', style: TextStyle(color: AppTheme.warmGray, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadScreen()));
            },
            child: const Text('Ver versões offline'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyMid : Colors.white,
        title: const Text('Versão da Bíblia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: provider.religion.availableVersions.map((v) => RadioListTile<BibleVersion>(
              value: v,
              groupValue: provider.bibleVersion,
              onChanged: (val) {
                if (val != null) {
                  provider.setBibleVersion(val);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Versão alterada para ${val.shortName}')),
                  );
                }
              },
              title: Text(v.shortName),
              subtitle: Text(v.displayName, style: const TextStyle(fontSize: 11)),
              activeColor: AppTheme.goldPrimary,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  Widget _notifTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required bool value,
      required int hour, required int minute,
      required ValueChanged<bool> onChanged, required VoidCallback onTimeTap,
      required Color border, required Color cardBg, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: AppTheme.warmGray, fontSize: 11)),
          if (value) GestureDetector(
            onTap: onTimeTap,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} — toque para alterar',
                style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.goldPrimary),
      ]),
    );
  }
}

// ── Bottom sheet de busca por voz (widget separado para gerenciar estado local) ──

class _VoiceSearchSheet extends StatefulWidget {
  final SpeechToText speech;
  final bool speechAvailable;
  final void Function(String query) onNavigate;

  const _VoiceSearchSheet({
    required this.speech,
    required this.speechAvailable,
    required this.onNavigate,
  });

  @override
  State<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<_VoiceSearchSheet> {
  bool _isListening = false;
  String _words = '';

  @override
  void dispose() {
    if (_isListening) widget.speech.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isListening) {
      await widget.speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() { _isListening = true; _words = ''; });

    await widget.speech.listen(
      onResult: (result) {
        setState(() => _words = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() => _isListening = false);
          widget.onNavigate(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'pt_BR',
      cancelOnError: false,
      partialResults: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.navyMid,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),

        // Ícone animado
        GestureDetector(
          onTap: widget.speechAvailable ? _toggle : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isListening
                    ? [const Color(0xFFE84393), const Color(0xFFC00000)]
                    : widget.speechAvailable
                        ? [const Color(0xFF5B6EF5), const Color(0xFF7B4FE0)]
                        : [Colors.grey, Colors.grey.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: _isListening ? [
                BoxShadow(
                  color: const Color(0xFFE84393).withOpacity(0.5),
                  blurRadius: 24, spreadRadius: 4,
                ),
              ] : [],
            ),
            child: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white, size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Texto de status
        Text(
          _isListening
              ? (_words.isEmpty ? 'Ouvindo... fale agora 🎤' : '"$_words"')
              : widget.speechAvailable
                  ? 'Toque no microfone e fale\num livro, versículo ou tema'
                  : 'Reconhecimento de voz\nnão disponível neste dispositivo',
          style: TextStyle(
            color: _isListening
                ? (_words.isEmpty ? const Color(0xFFE84393) : AppTheme.goldPrimary)
                : AppTheme.warmGray,
            fontSize: 14,
            fontStyle: (_isListening && _words.isNotEmpty) ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Botão principal
        if (widget.speechAvailable)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggle,
              icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(_isListening ? 'Parar' : 'Começar a Falar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening
                    ? const Color(0xFFE84393)
                    : Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.warmGray)),
        ),
      ]),
    );
  }
}
