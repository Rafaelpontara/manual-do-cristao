import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'books_screen.dart';
import 'read_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BooksScreen(),
    const ReadScreen(),
    const NotesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyMid : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF1E3048)
                  : const Color(0xFFE8DCC8),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Início'),
                _buildNavItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Livros'),
                _buildNavItem(2, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Ler'),
                _buildNavItem(3, Icons.edit_note_rounded, Icons.edit_note_outlined, 'Notas'),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outlined, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.goldPrimary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive
                  ? AppTheme.goldPrimary
                  : isDark
                      ? const Color(0xFF5A6E82)
                      : Colors.grey[400],
              size: 22, // Smaller icons as requested
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppTheme.goldPrimary
                    : isDark
                        ? const Color(0xFF5A6E82)
                        : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
