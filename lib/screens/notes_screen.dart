import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;
    final notes = _searchQuery.isEmpty
        ? provider.notes
        : provider.notes
            .where((n) =>
                n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                n.content.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Anotações', style: GoogleFonts.playfairDisplay(color: AppTheme.goldPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar anotações...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: AppTheme.goldPrimary, size: 48),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Nenhuma Anotação'
                        : 'Nenhum resultado',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque em + para criar sua primeira anotação',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final note = notes[i];
                return _buildNoteCard(context, note, isDark, provider);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(context, provider, isDark),
        backgroundColor: AppTheme.goldPrimary,
        foregroundColor: AppTheme.navyDeep,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Nota',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note, bool isDark,
      AppProvider provider) {
    final noteColors = {
      'gold': AppTheme.goldPrimary,
      'green': AppTheme.forestGreen,
      'blue': Colors.lightBlue,
      'purple': AppTheme.purple,
      'red': AppTheme.crimsonAccent,
      null: null,
    };

    final accentColor = noteColors[note.colorTag];

    return GestureDetector(
      onTap: () => _openNoteEditor(context, provider, isDark, note: note),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyMid : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor?.withOpacity(0.4) ??
                (isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
          ),
          boxShadow: accentColor != null
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (accentColor != null)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, provider, note),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppTheme.warmGray, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (note.verseReference != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_rounded,
                                  color: AppTheme.goldPrimary, size: 10),
                              const SizedBox(width: 3),
                              Text(
                                note.verseReference!,
                                style: const TextStyle(
                                    color: AppTheme.goldPrimary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      Text(
                        _formatDate(note.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(
      BuildContext context, AppProvider provider, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Anotação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(note.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _openNoteEditor(BuildContext context, AppProvider provider, bool isDark,
      {Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note, isDark: isDark),
      ),
    ).then((result) {
      if (result != null) {
        if (note == null) {
          provider.addNote(result as Note);
        } else {
          provider.updateNote(result as Note);
        }
      }
    });
  }
}

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final bool isDark;

  const NoteEditorScreen({Key? key, this.note, required this.isDark})
      : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _refController;
  String? _selectedColor;
  final _uuid = const Uuid();

  final List<(String, Color, String)> _colorOptions = [
    ('gold', AppTheme.goldPrimary, '🌟'),
    ('green', AppTheme.forestGreen, '🌿'),
    ('blue', Colors.lightBlue, '💙'),
    ('purple', AppTheme.purple, '🔮'),
    ('red', AppTheme.crimsonAccent, '❤️'),
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _refController =
        TextEditingController(text: widget.note?.verseReference ?? '');
    _selectedColor = widget.note?.colorTag;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um título')),
      );
      return;
    }

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      verseReference: _refController.text.trim().isNotEmpty
          ? _refController.text.trim()
          : null,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      colorTag: _selectedColor ?? 'gold',
    );
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Nova Anotação' : 'Editar Anotação',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(
                  color: AppTheme.goldPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color selector
            Row(
              children: [
                Text('Cor:', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _selectedColor = null),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == null
                            ? AppTheme.goldPrimary
                            : AppTheme.warmGray,
                        width: _selectedColor == null ? 2 : 1,
                      ),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppTheme.warmGray),
                  ),
                ),
                ..._colorOptions.map((c) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = c.$1),
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: c.$2.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == c.$1
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: _selectedColor == c.$1
                              ? [
                                  BoxShadow(
                                    color: c.$2.withOpacity(0.5),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                        child: _selectedColor == c.$1
                            ? const Center(
                                child: Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16),
                              )
                            : null,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            // Title
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 20,
                  ),
              decoration: InputDecoration(
                hintText: 'Título da anotação',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.navyMid : Colors.white,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            // Verse reference
            TextField(
              controller: _refController,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.goldPrimary,
                  ),
              decoration: InputDecoration(
                hintText: 'Versículo de referência (ex: João 3:16)',
                prefixIcon: const Icon(Icons.bookmark_rounded,
                    color: AppTheme.goldPrimary, size: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.navyMid : Colors.white,
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            // Content
            TextField(
              controller: _contentController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Escreva sua anotação...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.navyMid : Colors.white,
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              minLines: 8,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }
}
