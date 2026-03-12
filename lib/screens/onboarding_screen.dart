import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  Religion? _selectedReligion;
  BibleVersion? _selectedVersion;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _fadeController.reverse().then((_) {
      setState(() => _currentPage++);
      _fadeController.forward();
    });
  }

  Future<void> _complete() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (_selectedReligion != null) provider.setReligion(_selectedReligion!);
    if (_selectedVersion != null) provider.setBibleVersion(_selectedVersion!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDeep,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _currentPage == 0
            ? _buildWelcomePage()
            : _currentPage == 1
                ? _buildReligionPage()
                : _buildVersionPage(),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.goldPrimary, AppTheme.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppTheme.navyDeep,
                size: 60,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Palavra Viva',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    letterSpacing: -1,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sua jornada espiritual começa aqui.\nLeia, estude, medite e cresça na fé.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.warmGray,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            _buildFeatureRow(Icons.book_outlined, 'Todos os livros bíblicos'),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.highlight, 'Grifos e anotações'),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.calendar_today, 'Planos de leitura'),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.play_circle_outline, 'Vídeos explicativos'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Começar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.goldPrimary, size: 18),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.creamWhite,
              ),
        ),
      ],
    );
  }

  Widget _buildReligionPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Sua tradição',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha sua denominação para personalizarmos sua experiência:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            ...Religion.values.map((r) => _buildReligionCard(r)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReligion != null ? _nextPage : null,
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReligionCard(Religion religion) {
    final isSelected = _selectedReligion == religion;
    final icons = {
      Religion.catholic: '✝️',
      Religion.evangelical: '📖',
      Religion.orthodox: '☦️',
    };

    return GestureDetector(
      onTap: () => setState(() => _selectedReligion = religion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary.withOpacity(0.15)
              : AppTheme.navyMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : const Color(0xFF2A3F5A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icons[religion]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    religion.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isSelected ? AppTheme.goldPrimary : AppTheme.creamWhite,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    religion.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.goldPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionPage() {
    final versions = _selectedReligion?.availableVersions ?? BibleVersion.values;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Versão da Bíblia',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha sua tradução preferida:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            ...versions.map((v) => _buildVersionCard(v)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedVersion != null ? _complete : null,
                child: const Text('Começar a Ler'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(BibleVersion version) {
    final isSelected = _selectedVersion == version;

    return GestureDetector(
      onTap: () => setState(() => _selectedVersion = version),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary.withOpacity(0.15)
              : AppTheme.navyMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : const Color(0xFF2A3F5A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.goldPrimary
                    : AppTheme.goldPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                version.shortName,
                style: TextStyle(
                  color: isSelected ? AppTheme.navyDeep : AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                version.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppTheme.goldPrimary : AppTheme.creamWhite,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.goldPrimary),
          ],
        ),
      ),
    );
  }
}
