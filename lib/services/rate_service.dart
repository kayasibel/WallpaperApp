import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/custom_snackbar.dart';
import 'language_service.dart';

/// Rating hatırlatma servisi
/// Kullanıcıya belirli aralıklarla değerlendirme hatırlatması gösterir
class RateService {
  static const String _keyHasRated = 'has_rated';
  static const String _keyAppOpenCount = 'app_open_count';
  static const String _keyLastPromptDate = 'last_prompt_date';

  // Singleton pattern
  static final RateService _instance = RateService._internal();
  factory RateService() => _instance;
  RateService._internal();

  /// Uygulama açılışında çağrılır - sayacı artırır
  Future<void> incrementAppOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyAppOpenCount) ?? 0;
    await prefs.setInt(_keyAppOpenCount, currentCount + 1);
    debugPrint('📊 App open count: ${currentCount + 1}');
  }

  /// Rating dialog gösterilmeli mi kontrol eder
  Future<bool> shouldShowRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Daha önce değerlendirme yaptıysa veya "asla sorma" dediyse gösterme
    final hasRated = prefs.getBool(_keyHasRated) ?? false;
    if (hasRated) {
      debugPrint('📊 User already rated or dismissed permanently');
      return false;
    }

    final appOpenCount = prefs.getInt(_keyAppOpenCount) ?? 0;
    final lastPromptDateStr = prefs.getString(_keyLastPromptDate);

    // Koşul 1: 2. açılış veya sonrası
    if (appOpenCount >= 2) {
      debugPrint('📊 Condition met: App opened $appOpenCount times (>=2)');

      // Eğer daha önce hiç prompt gösterilmediyse göster
      if (lastPromptDateStr == null) {
        return true;
      }

      // Koşul 2: Son hatırlatmanın üzerinden 1 gün geçmiş mi?
      final lastPromptDate = DateTime.tryParse(lastPromptDateStr);
      if (lastPromptDate != null) {
        final daysSinceLastPrompt =
            DateTime.now().difference(lastPromptDate).inDays;
        debugPrint('📊 Days since last prompt: $daysSinceLastPrompt');

        if (daysSinceLastPrompt >= 1) {
          return true;
        }
      }
    }

    return false;
  }

  /// Rating hatırlatma kontrolü - 45 saniye sonra dialog gösterir
  Future<void> checkRatingPrompt(BuildContext context) async {
    final shouldShow = await shouldShowRatingPrompt();

    if (!shouldShow) {
      debugPrint('📊 Rating prompt skipped');
      return;
    }

    debugPrint('📊 Will show rating prompt after 45 seconds');

    // 45 saniye bekle
    await Future.delayed(const Duration(seconds: 45));

    // Context hala geçerli mi kontrol et
    if (!context.mounted) {
      debugPrint('📊 Context no longer mounted, skipping rating prompt');
      return;
    }

    // Rating hatırlatma dialog'unu göster
    _showRatingReminderDialog(context);
  }

  /// Rating hatırlatma dialog'u
  void _showRatingReminderDialog(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                    // İkon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Başlık
                    Text(
                      langProvider.getText('rate_reminder_title'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Açıklama
                    Text(
                      langProvider.getText('rate_reminder_message'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Değerlendir butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          // has_rated = true yap
                          await _setHasRated(true);
                          // Hibrit rating dialog'u göster
                          if (context.mounted) {
                            _showHybridRatingDialog(context, langProvider);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              langProvider.getText('rate_now'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Şimdi Değil ve Asla Sorma butonları
                    Row(
                      children: [
                        // Şimdi Değil
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              // Son prompt tarihini güncelle
                              await _updateLastPromptDate();
                              showCustomSnackBar(
                                langProvider.getText('rate_later_message'),
                                type: SnackBarType.info,
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              langProvider.getText('rate_later'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Asla Sorma
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              // has_rated = true yap (bir daha sormaz)
                              await _setHasRated(true);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              langProvider.getText('rate_never'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// has_rated değerini ayarla
  Future<void> _setHasRated(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, value);
    debugPrint('📊 has_rated set to: $value');
  }

  /// Son prompt tarihini güncelle
  Future<void> _updateLastPromptDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastPromptDate, DateTime.now().toIso8601String());
    debugPrint('📊 last_prompt_date updated to: ${DateTime.now()}');
  }

  /// Hibrit rating dialog'u göster (settings_screen.dart'taki ile aynı)
  void _showHybridRatingDialog(
      BuildContext context, LanguageProvider langProvider) {
    // settings_screen.dart'taki _RatingDialog'u import edemeyeceğimiz için
    // Navigator ile settings ekranına gidip oradan çağırabiliriz
    // veya burada da aynı dialog'u implement edebiliriz

    // Şimdilik doğrudan settings_screen'deki dialog'u kullanmak için
    // Navigator kullanarak _rateApp'i çağıralım
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _HybridRatingScreen(),
      ),
    );
  }
}

/// Hibrit Rating Dialog için geçici ekran
/// Bu ekran açılır açılmaz dialog'u gösterir ve kapanınca geri döner
class _HybridRatingScreen extends StatefulWidget {
  const _HybridRatingScreen();

  @override
  State<_HybridRatingScreen> createState() => _HybridRatingScreenState();
}

class _HybridRatingScreenState extends State<_HybridRatingScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz dialog'u göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRatingDialog();
    });
  }

  void _showRatingDialog() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _RatingDialog(langProvider: langProvider);
      },
    ).then((_) {
      // Dialog kapandığında geri dön
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Şeffaf ekran - sadece dialog göstermek için
    return const Scaffold(
      backgroundColor: Colors.transparent,
    );
  }
}

// Hibrit Rating Dialog Widget (settings_screen.dart'tan kopyalandı)
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
        'source': 'rating_reminder', // Nereden geldiğini belirt
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
