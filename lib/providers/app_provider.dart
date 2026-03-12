import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/bible_models.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  Religion _religion = Religion.evangelical;
  BibleVersion _bibleVersion = BibleVersion.acf;
  List<BibleBook> _books = [];
  List<Note> _notes = [];
  List<Map<String, dynamic>> _highlights = [];
  List<Map<String, dynamic>> _bookmarks = [];
  ReadingPlan? _activePlan;
  int _readingFontSize = 18;
  bool _isLoading = false;
  Map<String, dynamic>? _dailyVerse;
  int _dailyStreak = 0;
  DateTime? _lastReadDate;

  // Getters
  bool get isDarkMode => _isDarkMode;
  Religion get religion => _religion;
  BibleVersion get bibleVersion => _bibleVersion;
  List<BibleBook> get books => _books;
  List<BibleBook> get oldTestamentBooks =>
      _books.where((b) => b.testament == Testament.old).toList();
  List<BibleBook> get newTestamentBooks =>
      _books.where((b) => b.testament == Testament.new_).toList();
  List<Note> get notes => _notes;
  List<Map<String, dynamic>> get highlights => _highlights;
  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  ReadingPlan? get activePlan => _activePlan;
  int get readingFontSize => _readingFontSize;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dailyVerse => _dailyVerse;
  int get dailyStreak => _dailyStreak;

  double get overallProgress {
    if (_books.isEmpty) return 0.0;
    return _books.fold(0.0, (sum, b) => sum + b.readingProgress) / _books.length;
  }

  int get totalBooksRead => _books.where((b) => b.isCompleted).length;

  AppProvider() {
    _books = BibleData.getBooks();
    _loadDailyVerse();
    _loadFromPrefs();
  }

  void _loadDailyVerse() {
    final verses = BibleData.getDailyVerses();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _dailyVerse = verses[dayOfYear % verses.length];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _readingFontSize = prefs.getInt('readingFontSize') ?? 18;
    _dailyStreak = prefs.getInt('dailyStreak') ?? 0;

    final religionIndex = prefs.getInt('religion') ?? 1;
    _religion = Religion.values[religionIndex];

    final versionIndex = prefs.getInt('bibleVersion') ?? 0;
    _bibleVersion = BibleVersion.values[versionIndex];

    // Load reading progress
    final progressJson = prefs.getString('readingProgress');
    if (progressJson != null) {
      final progress = json.decode(progressJson) as Map<String, dynamic>;
      for (final book in _books) {
        if (progress.containsKey(book.id)) {
          book.readingProgress = progress[book.id]['progress'] ?? 0.0;
          book.completedChapters = List<int>.from(progress[book.id]['chapters'] ?? []);
        }
      }
    }

    // Load notes
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final notesList = json.decode(notesJson) as List;
      _notes = notesList.map((n) => Note.fromJson(n)).toList();
    }

    // Load highlights
    final hlJson = prefs.getString('highlights');
    if (hlJson != null) {
      _highlights = List<Map<String, dynamic>>.from(json.decode(hlJson));
    }

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('readingFontSize', _readingFontSize);
    await prefs.setInt('dailyStreak', _dailyStreak);
    await prefs.setInt('religion', _religion.index);
    await prefs.setInt('bibleVersion', _bibleVersion.index);

    final progress = {
      for (final book in _books)
        book.id: {'progress': book.readingProgress, 'chapters': book.completedChapters}
    };
    await prefs.setString('readingProgress', json.encode(progress));

    await prefs.setString('notes', json.encode(_notes.map((n) => n.toJson()).toList()));
    await prefs.setString('highlights', json.encode(_highlights));
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  void setReligion(Religion religion) {
    _religion = religion;
    _saveToPrefs();
    notifyListeners();
  }

  void setBibleVersion(BibleVersion version) {
    _bibleVersion = version;
    _saveToPrefs();
    notifyListeners();
  }

  void setFontSize(int size) {
    _readingFontSize = size.clamp(14, 28);
    _saveToPrefs();
    notifyListeners();
  }

  void markChapterRead(String bookId, int chapter) {
    final book = _books.firstWhere((b) => b.id == bookId);
    if (!book.completedChapters.contains(chapter)) {
      book.completedChapters.add(chapter);
      book.readingProgress = book.completedChapters.length / book.chapters;
      _updateStreak();
      _saveToPrefs();
      notifyListeners();
    }
  }

  void _updateStreak() {
    final today = DateTime.now();
    if (_lastReadDate == null ||
        today.difference(_lastReadDate!).inDays == 1) {
      _dailyStreak++;
    } else if (today.difference(_lastReadDate!).inDays > 1) {
      _dailyStreak = 1;
    }
    _lastReadDate = today;
  }

  void addHighlight(String bookId, int chapter, int verse, String text, String color) {
    _highlights.removeWhere(
        (h) => h['bookId'] == bookId && h['chapter'] == chapter && h['verse'] == verse);
    _highlights.add({
      'bookId': bookId,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'color': color,
      'date': DateTime.now().toIso8601String(),
    });
    _saveToPrefs();
    notifyListeners();
  }

  void removeHighlight(String bookId, int chapter, int verse) {
    _highlights.removeWhere(
        (h) => h['bookId'] == bookId && h['chapter'] == chapter && h['verse'] == verse);
    _saveToPrefs();
    notifyListeners();
  }

  bool isHighlighted(String bookId, int chapter, int verse) {
    return _highlights.any(
        (h) => h['bookId'] == bookId && h['chapter'] == chapter && h['verse'] == verse);
  }

  String? getHighlightColor(String bookId, int chapter, int verse) {
    final hl = _highlights.firstWhere(
        (h) => h['bookId'] == bookId && h['chapter'] == chapter && h['verse'] == verse,
        orElse: () => {});
    return hl.isNotEmpty ? hl['color'] : null;
  }

  void addBookmark(String bookId, int chapter, int verse, String text) {
    if (!_bookmarks.any((b) => b['bookId'] == bookId && b['chapter'] == chapter && b['verse'] == verse)) {
      _bookmarks.add({
        'bookId': bookId,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'date': DateTime.now().toIso8601String(),
      });
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeBookmark(String bookId, int chapter, int verse) {
    _bookmarks.removeWhere(
        (b) => b['bookId'] == bookId && b['chapter'] == chapter && b['verse'] == verse);
    _saveToPrefs();
    notifyListeners();
  }

  bool isBookmarked(String bookId, int chapter, int verse) {
    return _bookmarks.any(
        (b) => b['bookId'] == bookId && b['chapter'] == chapter && b['verse'] == verse);
  }

  void addNote(Note note) {
    _notes.insert(0, note);
    _saveToPrefs();
    notifyListeners();
  }

  void updateNote(Note note) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  Map<String, dynamic> getRandomVerse() {
    final verses = BibleData.getDailyVerses();
    return verses[Random().nextInt(verses.length)];
  }

  void setActivePlan(ReadingPlan plan) {
    _activePlan = plan;
    _activePlan!.isActive = true;
    _activePlan!.startDate = DateTime.now();
    notifyListeners();
  }

  void markPlanDayComplete(int day) {
    if (_activePlan != null && day <= _activePlan!.dailyReadings.length) {
      _activePlan!.dailyReadings[day - 1].isCompleted = true;
      _activePlan!.dailyReadings[day - 1].completedAt = DateTime.now();
      if (day < _activePlan!.durationDays) {
        _activePlan!.currentDay = day + 1;
      }
      notifyListeners();
    }
  }

  ReadingPlan createReadingPlan(String type) {
    final books = BibleData.getBooks();
    List<DailyReading> dailyReadings = [];
    int durationDays;
    String name, description;

    switch (type) {
      case '1year':
        durationDays = 365;
        name = 'Bíblia em 1 Ano';
        description = 'Leia toda a Bíblia em 365 dias';
        break;
      case '6months':
        durationDays = 180;
        name = 'Bíblia em 6 Meses';
        description = 'Leia toda a Bíblia em 180 dias';
        break;
      case '3months':
        durationDays = 90;
        name = 'Novo Testamento em 3 Meses';
        description = 'Leia o Novo Testamento em 90 dias';
        break;
      default:
        durationDays = 365;
        name = 'Bíblia em 1 Ano';
        description = 'Leia toda a Bíblia em 365 dias';
    }

    // Build chapter list
    final List<ChapterReading> allChapters = [];
    final booksToRead = type == '3months'
        ? books.where((b) => b.testament == Testament.new_).toList()
        : books;

    for (final book in booksToRead) {
      for (int i = 1; i <= book.chapters; i++) {
        allChapters.add(ChapterReading(bookId: book.id, chapter: i));
      }
    }

    // Distribute chapters across days
    final chaptersPerDay = (allChapters.length / durationDays).ceil();
    for (int day = 1; day <= durationDays; day++) {
      final start = (day - 1) * chaptersPerDay;
      final end = min(start + chaptersPerDay, allChapters.length);
      if (start < allChapters.length) {
        dailyReadings.add(DailyReading(
          day: day,
          chapters: allChapters.sublist(start, end),
        ));
      }
    }

    return ReadingPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      durationDays: durationDays,
      dailyReadings: dailyReadings,
    );
  }
}
