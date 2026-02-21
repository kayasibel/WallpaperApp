import 'package:flutter/material.dart';
import '../services/ad_manager.dart';

/// Ödüllü Reklam Butonu Örneği
/// 
/// Bu widget, ödüllü reklam gösterip kullanıcıya ödül veren bir buton örneğidir.
/// Kendi uygulamanızda bu pattern'i kullanabilirsiniz.
class RewardedAdButton extends StatefulWidget {
  /// Ödül kazanıldığında çağrılacak fonksiyon
  final VoidCallback onRewardEarned;
  
  /// Buton metni
  final String buttonText;
  
  /// Ödül açıklaması (örn: "Premium özellik aç")
  final String rewardDescription;

  const RewardedAdButton({
    super.key,
    required this.onRewardEarned,
    this.buttonText = '🎁 Reklam İzle ve Ödül Kazan',
    this.rewardDescription = 'Ödül kazanmak için reklam izleyin',
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  final AdManager _adManager = AdManager();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Eğer reklam yüklü değilse yükle
    if (!_adManager.isRewardedReady) {
      _adManager.loadRewardedAd();
    }
  }

  Future<void> _showRewardedAd() async {
    setState(() => _isLoading = true);

    final shown = await _adManager.showRewardedAd(
      onUserEarnedReward: () {
        // Kullanıcı reklamı sonuna kadar izledi ve ödül kazandı
        print('🎉 Ödül kazanıldı!');
        
        // Callback'i çağır
        widget.onRewardEarned();
        
        // Kullanıcıya bildirim göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎁 Tebrikler! Ödülünüz kazanıldı!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onAdDismissed: () {
        // Reklam kapatıldı ama ödül kazanılmadı
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      onAdFailedToShow: (error) {
        // Reklam gösterilemedi
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Reklam gösterilemedi: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    if (!shown && mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Reklam yükleniyor, lütfen tekrar deneyin...'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.rewardDescription,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _showRewardedAd,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_circle_outline),
          label: Text(_isLoading ? 'Reklam Yükleniyor...' : widget.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== KULLANIM ÖRNEĞİ ====================
// 
// RewardedAdButton(
//   buttonText: '🎁 Premium Tema Aç',
//   rewardDescription: 'Reklam izleyerek bu temayı ücretsiz açın',
//   onRewardEarned: () {
//     // Kullanıcı ödülü kazandı, premium özelliği aç
//     setState(() {
//       _isPremiumUnlocked = true;
//     });
//   },
// )
//
// ==================== INTERSTITIAL KULLANIMI ====================
//
// Sayfa geçişlerinde veya belirli aksiyonlarda:
// 
// final adManager = AdManager();
// await adManager.showInterstitialAd(
//   onAdClosed: () {
//     // Reklam kapatıldıktan sonra yapılacak işlem
//     Navigator.push(context, ...);
//   },
// );
