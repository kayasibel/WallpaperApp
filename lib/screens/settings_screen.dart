import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ClipRRect(
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
                    // Dil seçeneklerini dinamik olarak oluştur - Scrollable
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: LanguageProvider.supportedLanguages.map((
                          lang,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildLanguageOption(
                              context,
                              '${lang['flag']} ${lang['name']}',
                              lang['code']!,
                              langProvider,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
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

  // Uygulama değerlendirme - Hibrit Dialog
  void _rateApp(BuildContext context, LanguageProvider langProvider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _RatingDialog(langProvider: langProvider);
      },
    );
  }

  // Uygulamayı paylaş
  void _shareApp(BuildContext context, LanguageProvider langProvider) async {
    const appUrl =
        'https://play.google.com/store/apps/details?id=com.anime.theme.wallpaper';
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
  void _openPrivacyPolicy(
    BuildContext context,
    LanguageProvider langProvider,
  ) async {
    final url = Uri.parse(
      'https://gist.githubusercontent.com/kayasibel/3ef78d8ccd2a7d6756901c23d2ded357/raw/97fd40193dc9f4d6801e722853722e6b2272f5de/privacy-policy.md',
    );

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

// Hibrit Rating Dialog Widget
class _RatingDialog extends StatefulWidget {
  final LanguageProvider langProvider;

  const _RatingDialog({required this.langProvider});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // Firestore'a feedback kaydet
  Future<bool> _submitFeedback() async {
    if (_rating == 0) return false;

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'rating': _rating,
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'locale': widget.langProvider.currentLocale.languageCode,
      });
      return true;
    } catch (e) {
      debugPrint('Feedback gönderme hatası: $e');
      return false;
    }
  }

  // Play Store'u aç
  Future<void> _openPlayStore() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.sibelkaya.vibeset.themes',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Play Store açma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.langProvider;
    final isHighRating = _rating >= 4;
    final showContent = _rating > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Text(
                  lang.getText('rate_dialog_title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Yıldızlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = starIndex;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _rating >= starIndex
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 44,
                          color: _rating >= starIndex
                              ? Colors.amber
                              : Colors.grey[600],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Rating sonrası içerik
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showContent
                      ? isHighRating
                          ? _buildHighRatingContent(lang)
                          : _buildLowRatingContent(lang)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4-5 yıldız için içerik
  Widget _buildHighRatingContent(LanguageProvider lang) {
    return Column(
      key: const ValueKey('high_rating'),
      children: [
        // Teşekkür ikonu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 48,
            color: Colors.pinkAccent,
          ),
        ),
        const SizedBox(height: 16),

        // Teşekkür mesajı
        Text(
          lang.getText('rate_thanks_message'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),

        // Play Store butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _openPlayStore();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.star_rounded, color: Colors.white),
            label: Text(
              lang.getText('rate_on_playstore'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 1-3 yıldız için içerik
  Widget _buildLowRatingContent(LanguageProvider lang) {
    return Column(
      key: const ValueKey('low_rating'),
      children: [
        // Feedback mesajı
        Text(
          lang.getText('rate_feedback_message'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),

        // TextField
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: lang.getText('rate_feedback_hint'),
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Gönder butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending
                ? null
                : () async {
                    setState(() {
                      _isSending = true;
                    });

                    final success = await _submitFeedback();
                    
                    if (!mounted) return;

                    Navigator.pop(context);

                    if (success) {
                      showCustomSnackBar(
                        lang.getText('rate_feedback_sent'),
                        type: SnackBarType.success,
                      );
                    } else {
                      showCustomSnackBar(
                        lang.getText('rate_feedback_error'),
                        type: SnackBarType.error,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    lang.getText('rate_send'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
