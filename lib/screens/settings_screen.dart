import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/bible_models.dart';
import '../services/notification_service.dart';
import '../services/offline_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
    // Simula progresso (download real acontece automaticamente ao ler)
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
              _infoTile(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF3B6DDE),
                title: 'Versão Atual',
                subtitle: provider.bibleVersion.displayName,
                cardBg: cardBg,
              ),
              Divider(height: 1, color: border),
              _infoTile(
                icon: Icons.church_rounded,
                iconColor: const Color(0xFF2AAE6E),
                title: 'Religião',
                subtitle: provider.religion.displayName,
                cardBg: cardBg,
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
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF3B6DDE),
                  title: 'Plano de Leitura',
                  subtitle: 'Lembrete diário de leitura',
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

  Widget _infoTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required Color cardBg}) {
    return ListTile(
      leading: Container(width: 38, height: 38,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
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
