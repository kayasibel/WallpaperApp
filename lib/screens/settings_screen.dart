import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/language_service.dart';
import '../utils/custom_snackbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
            pinned: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildGlassCircleButton(
                context,
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              langProvider.getText('settings'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Genel Ayarlar
                  _buildSectionCard(
                    context,
                    title: langProvider.getText('general'),
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.language,
                        title: langProvider.getText('language'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LanguageProvider.supportedLanguages.firstWhere(
                                    (lang) =>
                                        lang['code'] ==
                                        langProvider.currentLocale.languageCode,
                                    orElse: () => {'name': 'English'},
                                  )['name'] ??
                                  'English',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () => _showLanguageDialog(context, langProvider),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        icon: Icons.delete_sweep_outlined,
                        title: langProvider.getText('clear_cache'),
                        onTap: () => _clearCache(context, langProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Uygulama Hakkında
                  _buildSectionCard(
                    context,
                    title: langProvider.getText('application'),
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.star_outline,
                        title: langProvider.getText('rate'),
                        onTap: () => _rateApp(context, langProvider),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        icon: Icons.share_outlined,
                        title: langProvider.getText('share'),
                        onTap: () => _shareApp(context, langProvider),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        icon: Icons.security_outlined,
                        title: langProvider.getText('privacy'),
                        onTap: () => _openPrivacyPolicy(context, langProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Versiyon Bilgisi
                  Text(
                    '${langProvider.getText('version')} 1.0.0',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cam efektli section card
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  // Settings tile
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  // Cam efektli yuvarlak buton
  Widget _buildGlassCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onTap,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // Dil seçimi dialog
  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider langProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    langProvider.getText('select_lang'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Dil seçeneklerini dinamik olarak oluştur
                  ...LanguageProvider.supportedLanguages.map((lang) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildLanguageOption(
                        context,
                        '${lang['flag']} ${lang['name']}',
                        lang['code']!,
                        langProvider,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String code,
    LanguageProvider langProvider,
  ) {
    final isSelected = langProvider.currentLocale.languageCode == code;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurple.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.deepPurple.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                langProvider.setLanguage(code);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.deepPurple : Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          langProvider.getText('active'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Önbellek temizleme
  void _clearCache(BuildContext context, LanguageProvider langProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(langProvider.getText('clear_cache_title')),
        content: Text(langProvider.getText('clear_cache_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(langProvider.getText('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Dil ayarını cihaz diline sıfırla
              await langProvider.resetToDeviceLanguage();

              showCustomSnackBar(
                langProvider.getText('cache_cleared'),
                type: SnackBarType.success,
              );
            },
            child: Text(langProvider.getText('clear')),
          ),
        ],
      ),
    );
  }

  // Uygulama değerlendirme
  void _rateApp(BuildContext context, LanguageProvider langProvider) async {
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.sibelkaya.vibeset.themes');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar(
          langProvider.getText('cannot_open_link'),
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        langProvider.getText('error_opening_link'),
        type: SnackBarType.error,
      );
    }
  }

  // Uygulamayı paylaş
  void _shareApp(BuildContext context, LanguageProvider langProvider) async {
    const appUrl = 'https://play.google.com/store/apps/details?id=com.sibelkaya.vibeset.themes';
    final shareText = '${langProvider.getText('check_out_app')}\n$appUrl';
    
    try {
      await Share.share(shareText);
    } catch (e) {
      showCustomSnackBar(
        langProvider.getText('error_sharing'),
        type: SnackBarType.error,
      );
    }
  }

  // Gizlilik politikası
  void _openPrivacyPolicy(BuildContext context, LanguageProvider langProvider) async {
    final url = Uri.parse('https://gist.githubusercontent.com/kayasibel/398f09b1ceb5873479eb51fddd7b6aa7/raw/0555975cbd22f7aab1a7c4f41f3efe4c8d712b4f/privacy-policy.md');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar(
          langProvider.getText('cannot_open_link'),
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        langProvider.getText('error_opening_link'),
        type: SnackBarType.error,
      );
    }
  }
}
