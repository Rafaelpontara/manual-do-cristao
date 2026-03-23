import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'books_screen.dart';
import 'read_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'ai_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BooksScreen(),
    SearchScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: _currentIndex, children: _screens),

        // Botão flutuante de busca
        Positioned(
          bottom: 80, right: 20,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Configurações
            FloatingActionButton(
              heroTag: 'settings',
              mini: true,
              backgroundColor: isDark ? AppTheme.navyMid : Colors.white,
              foregroundColor: AppTheme.warmGray,
              elevation: 2,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              tooltip: 'Configurações',
              child: const Icon(Icons.settings_rounded, size: 20),
            ),
            const SizedBox(height: 8),
            // Busca
            FloatingActionButton(
              heroTag: 'search',
              mini: true,
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.navyDeep,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              tooltip: 'Buscar versículos',
              child: const Icon(Icons.search_rounded, size: 22),
            ),
          ]),
        ),
      ]),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyMid : Colors.white,
          border: Border(top: BorderSide(
              color: isDark ? const Color(0xFF1E3048) : const Color(0xFFE8DCC8), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Início', isDark),
                _navItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Livros', isDark),
                _navItem(2, Icons.search_rounded, Icons.search_outlined, 'Pesquisa', isDark),
                _navItem(3, Icons.edit_note_rounded, Icons.edit_note_outlined, 'Notas', isDark),
                _navItem(4, Icons.person_rounded, Icons.person_outlined, 'Perfil', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label, bool isDark) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.goldPrimary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? active : inactive,
            color: isActive ? AppTheme.goldPrimary : (isDark ? const Color(0xFF5A6E82) : Colors.grey[400]),
            size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppTheme.goldPrimary : (isDark ? const Color(0xFF5A6E82) : Colors.grey[400]),
          )),
        ]),
      ),
    );
  }
}
