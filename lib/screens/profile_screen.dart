import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Perfil & Configurações',
            style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.navyMid, AppTheme.navyLight],
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.goldPrimary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [AppTheme.goldPrimary, AppTheme.goldDark],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppTheme.navyDeep, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Minha Conta',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.religion.displayName} · ${provider.bibleVersion.shortName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniStat(context, '🔥',
                                '${provider.dailyStreak}', 'dias'),
                            const SizedBox(width: 16),
                            _buildMiniStat(context, '📖',
                                '${provider.totalBooksRead}', 'livros'),
                            const SizedBox(width: 16),
                            _buildMiniStat(
                                context,
                                '✍️',
                                '${provider.notes.length}',
                                'notas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings sections
            _buildSectionTitle(context, '🎨 Aparência'),
            _buildSettingItem(
              context,
              isDark: isDark,
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              iconColor: AppTheme.goldPrimary,
              title: 'Tema',
              subtitle: isDark ? 'Modo Escuro' : 'Modo Claro',
              trailing: Switch(
                value: isDark,
                onChanged: (_) => provider.toggleTheme(),
                activeColor: AppTheme.goldPrimary,
              ),
            ),
            _buildSettingItem(
              context,
              isDark: isDark,
              icon: Icons.text_fields_rounded,
              iconColor: AppTheme.forestGreen,
              title: 'Tamanho da Fonte',
              subtitle: '${provider.readingFontSize}px',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () =>
                        provider.setFontSize(provider.readingFontSize - 2),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove_rounded,
                          size: 14, color: AppTheme.goldPrimary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${provider.readingFontSize}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.goldPrimary)),
                  ),
                  GestureDetector(
                    onTap: () =>
                        provider.setFontSize(provider.readingFontSize + 2),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 14, color: AppTheme.goldPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '⛪ Preferências Espirituais'),
            _buildClickableSettingItem(
              context,
              isDark: isDark,
              icon: Icons.church_rounded,
              iconColor: AppTheme.purple,
              title: 'Religião',
              subtitle: provider.religion.displayName,
              onTap: () => _showReligionDialog(context, provider),
            ),
            _buildClickableSettingItem(
              context,
              isDark: isDark,
              icon: Icons.book_rounded,
              iconColor: AppTheme.goldPrimary,
              title: 'Versão da Bíblia',
              subtitle: provider.bibleVersion.displayName,
              onTap: () => _showVersionDialog(context, provider),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🔔 Notificações'),
            _buildClickableSettingItem(
              context,
              isDark: isDark,
              icon: Icons.notifications_rounded,
              iconColor: AppTheme.crimsonAccent,
              title: 'Lembretes Diários',
              subtitle: 'Configurar notificações de leitura',
              onTap: () => _showNotificationDialog(context),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '♿ Acessibilidade'),
            _buildClickableSettingItem(
              context,
              isDark: isDark,
              icon: Icons.mic_rounded,
              iconColor: Colors.blue,
              title: 'Busca por Voz',
              subtitle: 'Fale para buscar versículos ou livros',
              onTap: () => _showVoiceSearch(context),
            ),
            _buildClickableSettingItem(
              context,
              isDark: isDark,
              icon: Icons.accessibility_new_rounded,
              iconColor: AppTheme.forestGreen,
              title: 'Modo Acessível (Idosos)',
              subtitle: 'Interface simplificada com fonte maior',
              onTap: () => _showAccessibilitySettings(context, provider),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '📊 Estatísticas'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.navyMid : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3F5A)
                      : const Color(0xFFE8DCC8),
                ),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                      context,
                      'Livros Concluídos',
                      '${provider.totalBooksRead} / ${provider.books.length}',
                      AppTheme.forestGreen),
                  const Divider(height: 20),
                  _buildStatRow(
                      context,
                      'Progresso Total',
                      '${(provider.overallProgress * 100).toStringAsFixed(1)}%',
                      AppTheme.goldPrimary),
                  const Divider(height: 20),
                  _buildStatRow(context, 'Anotações', '${provider.notes.length}',
                      AppTheme.purple),
                  const Divider(height: 20),
                  _buildStatRow(
                      context,
                      'Versículos Grifados',
                      '${provider.highlights.length}',
                      AppTheme.crimsonAccent),
                  const Divider(height: 20),
                  _buildStatRow(
                      context,
                      'Favoritos',
                      '${provider.bookmarks.length}',
                      Colors.lightBlue),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Text('🕊️ Palavra Viva',
                      style: TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('v1.0.0 · Feito com fé e amor',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
      BuildContext context, String emoji, String value, String label) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '$emoji ', style: const TextStyle(fontSize: 12)),
              TextSpan(
                text: value,
                style: const TextStyle(
                    color: AppTheme.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
        ),
        Text(label, style: const TextStyle(color: AppTheme.warmGray, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
    );
  }

  Widget _buildSettingItem(BuildContext context,
      {required bool isDark,
      required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        subtitle:
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: trailing,
      ),
    );
  }

  Widget _buildClickableSettingItem(BuildContext context,
      {required bool isDark,
      required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyMid : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isDark ? const Color(0xFF2A3F5A) : const Color(0xFFE8DCC8)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        subtitle:
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.warmGray, size: 18),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  void _showReligionDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('Escolher Religião'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Religion.values.map((r) {
            return RadioListTile<Religion>(
              value: r,
              groupValue: provider.religion,
              onChanged: (v) {
                if (v != null) {
                  provider.setReligion(v);
                  Navigator.pop(ctx);
                }
              },
              title: Text(r.displayName),
              subtitle: Text(r.description,
                  style: const TextStyle(fontSize: 11)),
              activeColor: AppTheme.goldPrimary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showVersionDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('Versão da Bíblia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: provider.religion.availableVersions.map((v) {
            return RadioListTile<BibleVersion>(
              value: v,
              groupValue: provider.bibleVersion,
              onChanged: (val) {
                if (val != null) {
                  provider.setBibleVersion(val);
                  Navigator.pop(ctx);
                }
              },
              title: Text(v.shortName),
              subtitle: Text(v.displayName,
                  style: const TextStyle(fontSize: 11)),
              activeColor: AppTheme.goldPrimary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('🔔 Notificações'),
        content: const Text(
            'Configure seus lembretes diários para leitura bíblica. '
            'As notificações serão enviadas no horário escolhido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Notificações configuradas!')),
              );
            },
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _showVoiceSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navyMid,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                    colors: [Colors.blue.withOpacity(0.3), Colors.transparent]),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.4), blurRadius: 20)
                  ],
                ),
                child: const Icon(Icons.mic_rounded,
                    color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text('Busca por Voz',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Fale o nome de um livro, versículo ou passagem bíblica',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🎤 Microfone ativado — fale agora!')),
                );
              },
              icon: const Icon(Icons.mic_rounded),
              label: const Text('Começar a Falar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAccessibilitySettings(
      BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text('♿ Acessibilidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Para melhor experiência para idosos:'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.setFontSize(24);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonte aumentada para 24px')),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Aumentar Fonte ao Máximo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                provider.setFontSize(18);
                Navigator.pop(ctx);
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Restaurar Tamanho Padrão'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar')),
        ],
      ),
    );
  }
}
