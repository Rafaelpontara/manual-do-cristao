import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_models.dart';
import 'dart:math';

// Notificações desativadas temporariamente por incompatibilidade de versão
class NotificationService {
  static Future<void> init() async {}

  static Future<bool> requestPermission() async => false;

  static Future<void> scheduleVerseOfDay(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_verse_day', true);
    await prefs.setInt('notif_verse_hour', hour);
    await prefs.setInt('notif_verse_minute', minute);
  }

  static Future<void> scheduleReadingPlan(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_reading_plan', true);
    await prefs.setInt('notif_plan_hour', hour);
    await prefs.setInt('notif_plan_minute', minute);
  }

  static Future<void> scheduleMotivational(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_motivational', true);
    await prefs.setInt('notif_motiv_hour', hour);
    await prefs.setInt('notif_motiv_minute', minute);
  }

  static Future<void> cancelVerseOfDay() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_verse_day', false);
  }

  static Future<void> cancelReadingPlan() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_reading_plan', false);
  }

  static Future<void> cancelMotivational() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_motivational', false);
  }

  static Future<void> cancelAll() async {}

  static Future<Map<String, dynamic>> getSettings() async {
    final p = await SharedPreferences.getInstance();
    return {
      'verse_day':    p.getBool('notif_verse_day') ?? false,
      'reading_plan': p.getBool('notif_reading_plan') ?? false,
      'motivational': p.getBool('notif_motivational') ?? false,
      'verse_hour':   p.getInt('notif_verse_hour') ?? 8,
      'verse_minute': p.getInt('notif_verse_minute') ?? 0,
      'plan_hour':    p.getInt('notif_plan_hour') ?? 20,
      'plan_minute':  p.getInt('notif_plan_minute') ?? 0,
      'motiv_hour':   p.getInt('notif_motiv_hour') ?? 12,
      'motiv_minute': p.getInt('notif_motiv_minute') ?? 0,
    };
  }
}
