import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bible_models.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImage(AppProvider provider) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navyMid,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppTheme.warmGray, borderRadius: BorderRadius.circular(2))),
          Text('Foto de Perfil', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.goldPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.photo_library_rounded, color: AppTheme.goldPrimary),
            ),
            title: const Text('Escolher da Galeria'),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await _picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
              if (picked != null) provider.setProfileImage(picked.path);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
            ),
            title: const Text('Tirar Foto'),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 80, maxWidth: 512);
              if (picked != null) provider.setProfileImage(picked.path);
            },
          ),
          if (provider.profileImagePath.isNotEmpty)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_rounded, color: Colors.red),
              ),
              title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                provider.setProfileImage('');
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.creamLight,
      appBar: AppBar(
        title: Text('Perfil & Configurações', style: GoogleFonts.playfairDisplay(color: AppTheme.goldPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  GestureDetector(
                    onTap: () => _pickImage(provider),
                    child: Stack(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [AppTheme.goldPrimary, AppTheme.goldDark],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: provider.profileImagePath.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(provider.profileImagePath),
                                  width: 72, height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      color: AppTheme.navyDeep, size: 36),
                                ),
                              )
                            : const Icon(Icons.person_rounded,
                                color: AppTheme.navyDeep, size: 36),
                      ),
                      // Botão de câmera sobre o avatar
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.navyMid, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: AppTheme.navyDeep, size: 12),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.userName.isNotEmpty
                              ? provider.userName
                              : 'Minha Conta',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
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
                  const Text('🕊️ Manual do Cristão',
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
