import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _searched = false;
  bool _isListening = false;

  final List<String> _suggestions = [
    'amor', 'paz', 'fé', 'esperança', 'graça',
    'salvação', 'perdão', 'oração', 'força', 'alegria',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(widget.initialQuery!));
    }
  }

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
      _controller.text = ctrl.text.trim();
      _search(ctrl.text.trim());
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _loading = true; _searched = true; });
    final provider = Provider.of<AppProvider>(context, listen: false);
    final results = await BibleService.searchVerses(query.trim(), provider.bibleVersion);
    setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Buscar Versículos', style: GoogleFonts.playfairDisplay(color: AppTheme.goldPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Buscar por palavra, tema ou versículo...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _controller.clear();
                              setState(() { _results = []; _searched = false; });
                            })
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _search(_controller.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  minimumSize: Size.zero,
                ),
                child: const Icon(Icons.search_rounded, size: 20),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _startVoiceSearch(context),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFE84393), const Color(0xFF7B4FE0)]
                          : [const Color(0xFF5B6EF5), const Color(0xFF7B4FE0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white, size: 22),
                ),
              ),
            ]),
          ),

          // Sugestões
          if (!_searched) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Temas populares', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 13, color: AppTheme.warmGray)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((s) => GestureDetector(
                    onTap: () {
                      _controller.text = s;
                      _search(s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                      ),
                      child: Text(s, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 13)),
                    ),
                  )).toList(),
                ),
              ]),
            ),
          ],

          // Loading
          if (_loading)
            const Expanded(child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircularProgressIndicator(color: AppTheme.goldPrimary),
                SizedBox(height: 16),
                Text('Buscando versículos...', style: TextStyle(color: AppTheme.warmGray)),
              ]),
            )),

          // Sem resultados
          if (_searched && !_loading && _results.isEmpty)
            Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.search_off_rounded, color: AppTheme.warmGray, size: 48),
              const SizedBox(height: 16),
              Text('Nenhum versículo encontrado', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Tente outro termo ou palavra-chave', style: Theme.of(context).textTheme.bodySmall),
            ]))),

          // Resultados
          if (!_loading && _results.isNotEmpty)
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${_results.length} resultado(s) encontrado(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.goldPrimary)),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final r = _results[i];
                    return _buildResultCard(context, r, isDark);
                  },
                ),
              ),
            ])),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> r, bool isDark) {
    final ref = r['reference'] ?? '';
    final text = r['text'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Referência
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(ref, style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          // Texto
          Text('"$text"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.7,
                color: isDark ? AppTheme.creamWhite : AppTheme.navyDeep,
              )),
          const SizedBox(height: 12),
          // Ações
          Row(children: [
            const Spacer(),
            _iconBtn(Icons.copy_rounded, 'Copiar', () {
              Clipboard.setData(ClipboardData(text: '"$text"\n— $ref'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Versículo copiado!')),
              );
            }),
            const SizedBox(width: 8),
            _iconBtn(Icons.share_rounded, 'Compartilhar', () {
              Share.share('"$text"\n— $ref\n\n🕊️ Manual do Cristão');
            }),
          ]),
        ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.goldPrimary, size: 16),
        ),
      ),
    );
  }
}
