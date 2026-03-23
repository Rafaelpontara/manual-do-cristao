import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../models/bible_models.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({Key? key}) : super(key: key);
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  // Humor
  String? _moodResult;
  String? _selectedMood;

  // Comparação de versões
  final _verseRefController = TextEditingController();
  String? _compareResult;
  bool _compareLoading = false;

  // Plano de leitura
  final _goalController = TextEditingController();
  int _planDays = 30;
  int _planMinutes = 20;
  String? _planResult;
  bool _planLoading = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😰', 'label': 'Ansioso', 'value': 'ansioso e preocupado com o futuro'},
    {'emoji': '😢', 'label': 'Triste', 'value': 'triste e precisando de conforto'},
    {'emoji': '😤', 'label': 'Com raiva', 'value': 'com raiva e precisando de paz interior'},
    {'emoji': '😔', 'label': 'Desanimado', 'value': 'desanimado e sem esperança'},
    {'emoji': '😊', 'label': 'Grato', 'value': 'grato e querendo louvar a Deus'},
    {'emoji': '💪', 'label': 'Com fé', 'value': 'cheio de fé e querendo crescer espiritualmente'},
    {'emoji': '🤔', 'label': 'Com dúvidas', 'value': 'com dúvidas sobre a fé e a vida'},
    {'emoji': '❤️', 'label': 'Amoroso', 'value': 'cheio de amor e querendo servir ao próximo'},
    {'emoji': '😴', 'label': 'Cansado', 'value': 'cansado espiritualmente e precisando de renovação'},
    {'emoji': '🙌', 'label': 'Vitória', 'value': 'celebrando uma vitória e querendo agradecer'},
    {'emoji': '💔', 'label': 'Ferido', 'value': 'com o coração ferido e precisando de cura'},
    {'emoji': '🌱', 'label': 'Crescendo', 'value': 'querendo crescer na fé e aprender mais'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final religion = Provider.of<AppProvider>(context, listen: false).religion;
    _chatHistory.add({
      'role': 'assistant',
      'content': '✨ Olá! Sou a **Luz**, sua assistente bíblica com IA.\n\nEstou configurada para a tradição **${religion.displayName}** ${religion.emoji}\n\nPosso explicar versículos, comparar traduções, criar planos de leitura e muito mais!\n\nComo posso te ajudar hoje?',
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _verseRefController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _chatController.clear();
    final religion = Provider.of<AppProvider>(context, listen: false).religion;
    setState(() {
      _chatHistory.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();
    final msgs = _chatHistory.map((m) => {'role': m['role']!, 'content': m['content']!}).toList();
    final response = await AiService.chat(msgs, religion);
    setState(() {
      _chatHistory.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: AppTheme.goldPrimary, shape: BoxShape.circle),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Assistente IA', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 16)),
            Text(provider.religion.displayName, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 10)),
          ]),
        ]),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.goldPrimary,
          unselectedLabelColor: AppTheme.warmGray,
          indicatorColor: AppTheme.goldPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 16), text: 'Chat'),
            Tab(icon: Icon(Icons.mood_rounded, size: 16), text: 'Humor'),
            Tab(icon: Icon(Icons.compare_arrows_rounded, size: 16), text: 'Comparar'),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 16), text: 'Plano IA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(isDark, provider.religion),
          _buildMoodTab(isDark, provider.religion),
          _buildCompareTab(isDark, provider),
          _buildPlanTab(isDark, provider),
        ],
      ),
    );
  }

  // ── Aba Chat ───────────────────────────────────────────────────────────────
  Widget _buildChatTab(bool isDark, Religion religion) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i == _chatHistory.length) return _typingIndicator();
            final msg = _chatHistory[i];
            return _bubble(msg['content']!, msg['role'] == 'user', isDark);
          },
        ),
      ),
      // Sugestões rápidas
      if (_chatHistory.length <= 1)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _quickBtn('Explique João 3:16', isDark),
            _quickBtn('O que é graça?', isDark),
            _quickBtn('Como orar melhor?', isDark),
            _quickBtn('Fale sobre a fé', isDark),
          ]),
        ),
      // Input
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyMid : Colors.white,
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E3048) : const Color(0xFFE8DCC8))),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              maxLines: 3, minLines: 1,
              onSubmitted: _sendMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Pergunte sobre a Bíblia...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? AppTheme.navyLight : AppTheme.creamLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_chatController.text),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: AppTheme.goldPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: AppTheme.navyDeep, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _quickBtn(String text, bool isDark) => GestureDetector(
    onTap: () => _sendMessage(text),
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.goldPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12)),
    ),
  );

  Widget _bubble(String content, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.goldPrimary : (isDark ? AppTheme.navyMid : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Text('✨', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                const Text('Luz', style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () { Clipboard.setData(ClipboardData(text: content)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado!'))); },
                  child: const Icon(Icons.copy_rounded, size: 12, color: AppTheme.warmGray),
                ),
              ]),
            ),
          Text(content, style: TextStyle(
            color: isUser ? AppTheme.navyDeep : (isDark ? AppTheme.creamWhite : AppTheme.navyDeep),
            fontSize: 14, height: 1.6,
          )),
        ]),
      ),
    );
  }

  Widget _typingIndicator() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.navyMid, borderRadius: BorderRadius.circular(16)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('✨ Luz está pensando...', style: TextStyle(color: AppTheme.warmGray, fontSize: 13)),
        SizedBox(width: 8),
        SizedBox(width: 20, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldPrimary)),
      ]),
    ),
  );

  // ── Aba Humor ──────────────────────────────────────────────────────────────
  Widget _buildMoodTab(bool isDark, Religion religion) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Como você está se sentindo?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Receba versículos personalizados para o seu momento', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
          children: _moods.map((m) {
            final sel = _selectedMood == m['value'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = m['value']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.goldPrimary.withOpacity(0.18) : (isDark ? AppTheme.navyMid : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppTheme.goldPrimary : (isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)), width: sel ? 2 : 1),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(m['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(m['label']!, style: TextStyle(fontSize: 9, fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? AppTheme.goldPrimary : AppTheme.warmGray), textAlign: TextAlign.center),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedMood == null || _isLoading ? null : () async {
              setState(() { _isLoading = true; _moodResult = null; });
              final r = await AiService.suggestByMood(_selectedMood!, religion);
              setState(() { _moodResult = r; _isLoading = false; });
            },
            icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navyDeep)) : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(_isLoading ? 'Buscando...' : 'Receber Versículos com IA'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        if (_moodResult != null) ...[
          const SizedBox(height: 16),
          _resultCard(isDark, '✨ Versículos para você', _moodResult!),
        ],
      ]),
    );
  }

  // ── Aba Comparar Versões ───────────────────────────────────────────────────
  Widget _buildCompareTab(bool isDark, AppProvider provider) {
    final versions = provider.religion.availableVersions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Comparar Traduções com IA', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('A IA analisa as diferenças entre versões da Bíblia para qualquer versículo', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),

        // Versões disponíveis
        Text('Versões disponíveis para ${provider.religion.displayName}:', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 13, color: AppTheme.warmGray)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: versions.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: v == provider.bibleVersion ? AppTheme.goldPrimary.withOpacity(0.2) : (isDark ? AppTheme.navyMid : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: v == provider.bibleVersion ? AppTheme.goldPrimary : (isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8))),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.shortName, style: TextStyle(color: v == provider.bibleVersion ? AppTheme.goldPrimary : null, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(v.description, style: const TextStyle(fontSize: 10, color: AppTheme.warmGray)),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 20),

        // Referência do versículo
        TextField(
          controller: _verseRefController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Ex: João 3:16 ou Filipenses 4:13',
            prefixIcon: const Icon(Icons.menu_book_rounded, size: 18),
            labelText: 'Versículo para comparar',
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verseRefController.text.trim().isEmpty || _compareLoading ? null : () async {
              setState(() { _compareLoading = true; _compareResult = null; });
              // Texto de exemplo para demo
              final versionTexts = { for (final v in versions) v.shortName: '"${_verseRefController.text.trim()}" — texto da versão ${v.shortName}' };
              final result = await AiService.compareVersions(
                reference: _verseRefController.text.trim(),
                bookName: _verseRefController.text.split(' ').first,
                chapter: 1, verse: 1,
                versionTexts: versionTexts,
                religion: provider.religion,
              );
              setState(() { _compareResult = result; _compareLoading = false; });
            },
            icon: _compareLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navyDeep)) : const Icon(Icons.compare_arrows_rounded, size: 18),
            label: Text(_compareLoading ? 'Comparando...' : 'Comparar com IA'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),

        // Sugestões rápidas
        const SizedBox(height: 12),
        Text('Versículos populares para comparar:', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['João 3:16', 'Filipenses 4:13', 'Salmos 23:1', 'Romanos 8:28', 'Jeremias 29:11'].map((ref) =>
            GestureDetector(
              onTap: () => setState(() => _verseRefController.text = ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                ),
                child: Text(ref, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12)),
              ),
            )
          ).toList(),
        ),

        if (_compareResult != null) ...[
          const SizedBox(height: 20),
          _resultCard(isDark, '📊 Análise das Traduções', _compareResult!),
        ],
      ]),
    );
  }

  // ── Aba Plano de Leitura por IA ────────────────────────────────────────────
  Widget _buildPlanTab(bool isDark, AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Plano de Leitura por IA', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('A IA cria um plano personalizado baseado nos seus objetivos e disponibilidade', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),

        // Objetivo
        TextField(
          controller: _goalController,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Ex: Conhecer os evangelhos, estudar o Antigo Testamento, ler a Bíblia em 1 ano...',
            labelText: 'Qual é o seu objetivo?',
            prefixIcon: const Icon(Icons.flag_rounded, size: 18),
          ),
        ),
        const SizedBox(height: 16),

        // Dias
        Row(children: [
          const Icon(Icons.calendar_today_rounded, color: AppTheme.goldPrimary, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Duração do plano: $_planDays dias', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14)),
            Slider(value: _planDays.toDouble(), min: 7, max: 365, divisions: 20, activeColor: AppTheme.goldPrimary,
              label: '$_planDays dias',
              onChanged: (v) => setState(() => _planDays = v.toInt())),
          ])),
        ]),
        const SizedBox(height: 8),

        // Minutos
        Row(children: [
          const Icon(Icons.access_time_rounded, color: AppTheme.goldPrimary, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tempo diário: $_planMinutes min', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14)),
            Slider(value: _planMinutes.toDouble(), min: 5, max: 60, divisions: 11, activeColor: AppTheme.goldPrimary,
              label: '$_planMinutes min',
              onChanged: (v) => setState(() => _planMinutes = v.toInt())),
          ])),
        ]),
        const SizedBox(height: 8),

        // Info religião
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(provider.religion.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tradição: ${provider.religion.displayName}', style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('O plano levará em conta sua tradição religiosa', style: Theme.of(context).textTheme.bodySmall),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _planLoading ? null : () async {
              setState(() { _planLoading = true; _planResult = null; });
              final goal = _goalController.text.trim().isEmpty ? 'ler a Bíblia completa' : _goalController.text.trim();
              final result = await AiService.generateReadingPlan(
                goal: goal,
                daysAvailable: _planDays,
                minutesPerDay: _planMinutes,
                religion: provider.religion,
                preferredBooks: [],
              );
              setState(() { _planResult = result; _planLoading = false; });
            },
            icon: _planLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navyDeep)) : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(_planLoading ? 'Criando plano...' : 'Gerar Plano com IA'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),

        if (_planResult != null) ...[
          const SizedBox(height: 20),
          _resultCard(isDark, '📅 Seu Plano Personalizado', _planResult!),
        ],
      ]),
    );
  }

  // ── Card de resultado ──────────────────────────────────────────────────────
  Widget _resultCard(bool isDark, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          GestureDetector(
            onTap: () { Clipboard.setData(ClipboardData(text: content)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado!'))); },
            child: const Icon(Icons.copy_rounded, color: AppTheme.warmGray, size: 16),
          ),
        ]),
        const SizedBox(height: 12),
        Text(content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7)),
      ]),
    );
  }
}
