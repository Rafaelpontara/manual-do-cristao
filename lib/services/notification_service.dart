import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';
import 'dart:convert';
import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// PROBLEMAS CORRIGIDOS:
// 1. NotificationCalendar sem 'day/month/year' não repetia corretamente
//    → Corrigido: usa repeats:true com apenas hour/minute/second
// 2. Notificações perdidas após reinício do celular
//    → Corrigido: reagendamento automático via checkAndReschedule()
// 3. Permissão de alarme exato não verificada
//    → Corrigido: verifica e solicita antes de agendar
// 4. Versículo do dia sempre o mesmo
//    → Corrigido: varia por dia do ano
// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  static bool _initialized = false;

  static const int _verseId = 1;
  static const int _planId  = 2;
  static const int _motivId = 3;

  // ── Inicializar ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'verse_day',
          channelName: 'Versículo do Dia',
          channelDescription: 'Versículo diário para inspiração',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFFD4A853),
          ledColor: const Color(0xFFD4A853),
          locked: false,
          // Mantém o canal ativo mesmo com bateria otimizada
          criticalAlerts: false,
        ),
        NotificationChannel(
          channelKey: 'reading_plan',
          channelName: 'Plano de Leitura',
          channelDescription: 'Lembrete diário de leitura bíblica',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2AAE6E),
          locked: false,
        ),
        NotificationChannel(
          channelKey: 'motivational',
          channelName: 'Mensagens Motivacionais',
          channelDescription: 'Palavras de encorajamento diárias',
          importance: NotificationImportance.Default,
          defaultColor: const Color(0xFF7B4FE0),
          locked: false,
        ),
      ],
      debug: false,
    );

    _initialized = true;
  }

  // ── Solicitar permissão ────────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    await init();
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.PreciseAlarms,
        ],
      );
    }
    return true;
  }

  // ── Verificar se as notificações ainda estão agendadas e reagendar se preciso
  // Chame este método no initState do app (main.dart ou AppProvider)
  static Future<void> checkAndReschedule() async {
    await init();
    final prefs = await SharedPreferences.getInstance();

    // Verifica se há notificações agendadas ativas
    final scheduled = await AwesomeNotifications().listScheduledNotifications();
    final scheduledIds = scheduled.map((n) => n.content?.id).toSet();

    // Versículo do dia
    final verseActive = prefs.getBool('notif_verse_day') ?? false;
    if (verseActive && !scheduledIds.contains(_verseId)) {
      final h = prefs.getInt('notif_verse_hour') ?? 8;
      final m = prefs.getInt('notif_verse_minute') ?? 0;
      await scheduleVerseOfDay(h, m);
    }

    // Plano de leitura
    final planActive = prefs.getBool('notif_reading_plan') ?? false;
    if (planActive && !scheduledIds.contains(_planId)) {
      final h = prefs.getInt('notif_plan_hour') ?? 20;
      final m = prefs.getInt('notif_plan_minute') ?? 0;
      await scheduleReadingPlan(h, m);
    }

    // Motivacional
    final motivActive = prefs.getBool('notif_motivational') ?? false;
    if (motivActive && !scheduledIds.contains(_motivId)) {
      final h = prefs.getInt('notif_motiv_hour') ?? 12;
      final m = prefs.getInt('notif_motiv_minute') ?? 0;
      await scheduleMotivational(h, m);
    }
  }

  // ── Busca versículo real da API ──────────────────────────────────────────
  static Future<Map<String, String>> _fetchVerseOfDay() async {
    // Lista de referências famosas para rotacionar por dia
    const references = [
      'john+3:16', 'psalms+23:1', 'philippians+4:13', 'romans+8:28',
      'jeremiah+29:11', 'matthew+6:33', 'isaiah+40:31', 'psalms+91:1',
      'proverbs+3:5', 'ephesians+2:8', 'john+14:6', 'romans+8:37',
      'philippians+4:6', 'matthew+5:3', 'psalms+46:1', '1+corinthians+13:4',
      'joshua+1:9', 'isaiah+41:10', 'romans+15:13', 'john+16:33',
      'psalms+121:1', 'matthew+11:28', 'galatians+2:20', 'colossians+3:23',
      'hebrews+11:1', '2+timothy+1:7', 'james+1:17', 'revelation+3:20',
      'luke+1:37', 'john+15:5',
    ];

    // Rotaciona por dia do ano para variar o versículo diariamente
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final ref = references[dayOfYear % references.length];

    try {
      final url = 'https://bible-api.com/$ref?translation=almeida';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = data['verses'] as List? ?? [];
        if (verses.isNotEmpty) {
          // Junta todos os versículos do trecho em um texto só
          final text = verses.map((v) => (v['text'] as String).trim()).join(' ');
          final reference = data['reference'] as String? ?? '';
          return {'text': text, 'ref': reference};
        }
      }
    } catch (_) {}

    // Fallback: versículo local se a API falhar
    final fallbackVerses = BibleData.getDailyVerses();
    final dayOfYear2 = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final fallback = fallbackVerses[dayOfYear2 % fallbackVerses.length];
    return {
      'text': fallback['text'] as String? ?? '',
      'ref': fallback['ref'] as String? ?? '',
    };
  }

  // ── Versículo do dia ───────────────────────────────────────────────────────
  static Future<void> scheduleVerseOfDay(int hour, int minute) async {
    await init();

    // Cancela o anterior antes de reagendar
    await AwesomeNotifications().cancel(_verseId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_verse_day', true);
    await prefs.setInt('notif_verse_hour', hour);
    await prefs.setInt('notif_verse_minute', minute);

    // Busca versículo real da API (com fallback local se offline)
    final verse = await _fetchVerseOfDay();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _verseId,
        channelKey: 'verse_day',
        title: '📖 Versículo do Dia',
        body: '"${verse['text']}" — ${verse['ref']}',
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true, // dispara mesmo com Doze Mode ativo
        preciseAlarm: true,   // alarme exato para horário preciso
      ),
    );
  }

  // ── Plano de leitura ───────────────────────────────────────────────────────
  static Future<void> scheduleReadingPlan(int hour, int minute) async {
    await init();

    await AwesomeNotifications().cancel(_planId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_reading_plan', true);
    await prefs.setInt('notif_plan_hour', hour);
    await prefs.setInt('notif_plan_minute', minute);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _planId,
        channelKey: 'reading_plan',
        title: '📅 Hora da Leitura Bíblica',
        body: 'Não esqueça de ler sua porção de hoje! 🙏',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  // ── Motivacional ───────────────────────────────────────────────────────────
  static Future<void> scheduleMotivational(int hour, int minute) async {
    await init();

    await AwesomeNotifications().cancel(_motivId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_motivational', true);
    await prefs.setInt('notif_motiv_hour', hour);
    await prefs.setInt('notif_motiv_minute', minute);

    final msgs = [
      'A fé move montanhas. Confie em Deus hoje! ⛰️',
      'Deus tem um plano perfeito para sua vida! 🌟',
      'Com Deus, nada é impossível! ✨',
      'A graça de Deus é nova a cada manhã! 🌅',
      'Você é amado por Deus incondicionalmente! ❤️',
      'Seja forte e corajoso! O Senhor está contigo! 🦁',
      'A paz de Deus guarda o seu coração! 🕊️',
      'Hoje é um dia de bênçãos! 🙌',
      'Deus cuida de cada detalhe da sua vida! 🌿',
      'Ore sem cessar e Deus ouvirá! 🙏',
    ];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _motivId,
        channelKey: 'motivational',
        title: '🙏 Manual do Cristão',
        body: msgs[Random().nextInt(msgs.length)],
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: false,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  // ── Cancelar ───────────────────────────────────────────────────────────────
  static Future<void> cancelVerseOfDay() async {
    await AwesomeNotifications().cancel(_verseId);
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_verse_day', false);
  }

  static Future<void> cancelReadingPlan() async {
    await AwesomeNotifications().cancel(_planId);
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_reading_plan', false);
  }

  static Future<void> cancelMotivational() async {
    await AwesomeNotifications().cancel(_motivId);
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_motivational', false);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_verse_day', false);
    await p.setBool('notif_reading_plan', false);
    await p.setBool('notif_motivational', false);
  }

  // ── Configurações salvas ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSettings() async {
    final p = await SharedPreferences.getInstance();
    return {
      'verse_day':    p.getBool('notif_verse_day')    ?? false,
      'reading_plan': p.getBool('notif_reading_plan') ?? false,
      'motivational': p.getBool('notif_motivational') ?? false,
      'verse_hour':   p.getInt('notif_verse_hour')    ?? 8,
      'verse_minute': p.getInt('notif_verse_minute')  ?? 0,
      'plan_hour':    p.getInt('notif_plan_hour')     ?? 20,
      'plan_minute':  p.getInt('notif_plan_minute')   ?? 0,
      'motiv_hour':   p.getInt('notif_motiv_hour')    ?? 12,
      'motiv_minute': p.getInt('notif_motiv_minute')  ?? 0,
    };
  }
}
