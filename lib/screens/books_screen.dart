import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';
import 'chapters_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text('Livros da Bíblia',
                style: Theme.of(context).textTheme.headlineLarge),
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Testament Selector - Prominent
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.navyMid : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A3F5A)
                              : const Color(0xFFE8DCC8)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.goldPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: AppTheme.navyDeep,
                      unselectedLabelColor:
                          isDark ? AppTheme.warmGray : Colors.grey[500],
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      padding: const EdgeInsets.all(4),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📜'),
                              const SizedBox(width: 6),
                              const Text('Antigo Testamento'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('✝️'),
                              const SizedBox(width: 6),
                              const Text('Novo Testamento'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar livro...',
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBookList(
                context, provider, Testament.old, isDark),
            _buildBookList(
                context, provider, Testament.new_, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, AppProvider provider,
      Testament testament, bool isDark) {
    var books = testament == Testament.old
        ? provider.oldTestamentBooks
        : provider.newTestamentBooks;

    if (_searchQuery.isNotEmpty) {
      books = books
          .where((b) =>
              b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              b.abbreviation
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Group by category
    final categories = <String>['Todos'];
    for (final b in books) {
      if (!categories.contains(b.category)) {
        categories.add(b.category);
      }
    }

    final filteredBooks = _selectedCategory == 'Todos'
        ? books
        : books.where((b) => b.category == _selectedCategory).toList();

    // Overall testament progress
    final totalProgress = books.isEmpty
        ? 0.0
        : books.fold(0.0, (s, b) => s + b.readingProgress) / books.length;

    return Column(
      children: [
        // Testament progress header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: testament == Testament.old
                  ? [
                      AppTheme.warmGray.withOpacity(0.3),
                      AppTheme.goldDark.withOpacity(0.2)
                    ]
                  : [
                      AppTheme.forestGreen.withOpacity(0.3),
                      AppTheme.forestGreen.withOpacity(0.1)
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                testament == Testament.old
                    ? '📜 ${books.length} livros'
                    : '✝️ ${books.length} livros',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(totalProgress * 100).toStringAsFixed(0)}% lido',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.goldPrimary),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: totalProgress,
                      backgroundColor:
                          Colors.white.withOpacity(0.2),
                      color: testament == Testament.old
                          ? AppTheme.goldPrimary
                          : AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Category filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.goldPrimary
                        : isDark
                            ? AppTheme.navyMid
                            : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.goldPrimary
                          : isDark
                              ? const Color(0xFF2A3F5A)
                              : const Color(0xFFE8DCC8),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.navyDeep
                          : isDark
                              ? AppTheme.creamWhite
                              : AppTheme.navyDeep,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Books grid
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(
                  child: Text('Nenhum livro encontrado',
                      style: Theme.of(context).textTheme.bodyMedium))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (ctx, i) =>
                      _buildBookCard(ctx, filteredBooks[i], isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, BibleBook book, bool isDark) {
    final progress = book.readingProgress;
    final isCompleted = book.isCompleted;
    final color = isCompleted
        ? AppTheme.forestGreen
        : progress > 0
            ? AppTheme.goldPrimary
            : (isDark ? AppTheme.navyLight : const Color(0xFFE8DCC8));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChaptersScreen(book: book),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyMid : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? AppTheme.forestGreen.withOpacity(0.4)
                : progress > 0
                    ? AppTheme.goldPrimary.withOpacity(0.3)
                    : isDark
                        ? const Color(0xFF2A3F5A)
                        : const Color(0xFFE8DCC8),
          ),
        ),
        child: Stack(
          children: [
            // Progress fill background
            if (progress > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    color: isDark
                        ? const Color(0xFF1E3048)
                        : const Color(0xFFEEE0CA),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.forestGreen
                            : AppTheme.goldPrimary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.abbreviation,
                          style: TextStyle(
                            color: isCompleted
                                ? AppTheme.forestGreen
                                : progress > 0
                                    ? AppTheme.goldPrimary
                                    : AppTheme.warmGray,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.forestGreen, size: 16),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    book.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? AppTheme.creamWhite
                              : AppTheme.navyDeep,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${book.chapters} cap. · ${progress > 0 ? '${(progress * 100).toStringAsFixed(0)}%' : book.category}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
