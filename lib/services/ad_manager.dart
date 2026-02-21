import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

/// Reklam durumları
enum AdStatus { initial, loading, loaded, failed }

/// AdManager - Singleton reklam yönetimi sınıfı
///
/// Interstitial ve Rewarded reklamları yönetir.
/// Test reklam ID'leri kullanılmaktadır.
class AdManager {
  // Singleton pattern
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // TEST: Reklamları devre dışı bırak
  // Production'da false yapın
  static const bool _adsDisabled = true;

  // Test Reklam ID'leri (Google'ın resmi test ID'leri)
  // Gerçek uygulama için kendi AdMob ID'lerinizi kullanın
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS test ID
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  // Reklam nesneleri
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Reklam durumları
  AdStatus _interstitialStatus = AdStatus.initial;
  AdStatus _rewardedStatus = AdStatus.initial;

  // Completer'lar - reklam yüklendiğinde tamamlanır
  Completer<bool>? _rewardedAdCompleter;
  Completer<bool>? _interstitialAdCompleter;

  // Getter'lar
  AdStatus get interstitialStatus => _interstitialStatus;
  AdStatus get rewardedStatus => _rewardedStatus;
  bool get isInterstitialReady =>
      _adsDisabled || (_interstitialAd != null && _interstitialStatus == AdStatus.loaded);
  bool get isRewardedReady =>
      _adsDisabled || (_rewardedAd != null && _rewardedStatus == AdStatus.loaded);

  /// Reklam kullanılabilir mi? (Hazır veya yükleniyor)
  bool get isRewardedAvailable =>
      _adsDisabled || isRewardedReady || _rewardedStatus == AdStatus.loading;
  bool get isInterstitialAvailable =>
      _adsDisabled || isInterstitialReady || _interstitialStatus == AdStatus.loading;

  // Retry sayaçları
  int _interstitialRetryAttempt = 0;
  int _rewardedRetryAttempt = 0;
  static const int maxRetryAttempts = 3;

  // Timeout sabitleri
  static const Duration adLoadTimeout = Duration(seconds: 4);

  /// SDK'yı başlat
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('✅ Google Mobile Ads SDK başlatıldı');
  }

  // ==================== INTERSTITIAL ADS ====================

  /// Interstitial reklamı yükle
  void loadInterstitialAd() {
    if (_adsDisabled) return;
    if (_interstitialStatus == AdStatus.loading) {
      print('⏳ Interstitial reklam zaten yükleniyor...');
      return;
    }

    _interstitialStatus = AdStatus.loading;
    print('📥 Interstitial reklam yükleniyor...');

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial reklam yüklendi');
          _interstitialAd = ad;
          _interstitialStatus = AdStatus.loaded;
          _interstitialRetryAttempt = 0;

          // Reklam kapatıldığında yeni reklam yükle
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print(
                '🔄 Interstitial reklam kapatıldı, yeni reklam yükleniyor...',
              );
              ad.dispose();
              _interstitialAd = null;
              _interstitialStatus = AdStatus.initial;
              loadInterstitialAd(); // Yeni reklam yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Interstitial gösterme hatası: ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              _interstitialStatus = AdStatus.failed;
            },
            onAdShowedFullScreenContent: (ad) {
              print('📺 Interstitial reklam gösterildi');
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial yükleme hatası: ${error.message}');
          _interstitialAd = null;
          _interstitialStatus = AdStatus.failed;

          // Retry mantığı
          _interstitialRetryAttempt++;
          if (_interstitialRetryAttempt < maxRetryAttempts) {
            print(
              '🔄 Interstitial retry ${_interstitialRetryAttempt}/$maxRetryAttempts',
            );
            Future.delayed(
              Duration(seconds: _interstitialRetryAttempt * 2),
              loadInterstitialAd,
            );
          }
        },
      ),
    );
  }

  /// Interstitial reklamı göster
  ///
  /// [onAdClosed] - Reklam kapatıldığında çağrılır
  Future<bool> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (_adsDisabled) {
      onAdClosed?.call();
      return true;
    }
    if (!isInterstitialReady) {
      print('⚠️ Interstitial reklam hazır değil');
      loadInterstitialAd(); // Reklam yüklemeyi başlat
      return false;
    }

    // Callback'i ayarla
    if (onAdClosed != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('🔄 Interstitial kapatıldı');
          ad.dispose();
          _interstitialAd = null;
          _interstitialStatus = AdStatus.initial;
          onAdClosed();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Interstitial gösterme hatası: ${error.message}');
          ad.dispose();
          _interstitialAd = null;
          _interstitialStatus = AdStatus.failed;
        },
      );
    }

    await _interstitialAd!.show();
    return true;
  }

  // ==================== REWARDED ADS ====================

  /// Rewarded reklamı yükle (arka planda, sessizce)
  void loadRewardedAd() {
    if (_adsDisabled) return;
    if (_rewardedStatus == AdStatus.loading) {
      print('⏳ Rewarded reklam zaten yükleniyor...');
      return;
    }

    _rewardedStatus = AdStatus.loading;
    _rewardedAdCompleter = Completer<bool>();
    print('📥 Rewarded reklam yükleniyor...');

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded reklam yüklendi');
          _rewardedAd = ad;
          _rewardedStatus = AdStatus.loaded;
          _rewardedRetryAttempt = 0;

          // Completer'ı tamamla
          if (_rewardedAdCompleter != null &&
              !_rewardedAdCompleter!.isCompleted) {
            _rewardedAdCompleter!.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          print('❌ Rewarded yükleme hatası: ${error.message}');
          _rewardedAd = null;
          _rewardedStatus = AdStatus.failed;

          // Completer'ı tamamla (başarısız)
          if (_rewardedAdCompleter != null &&
              !_rewardedAdCompleter!.isCompleted) {
            _rewardedAdCompleter!.complete(false);
          }

          // Retry mantığı
          _rewardedRetryAttempt++;
          if (_rewardedRetryAttempt < maxRetryAttempts) {
            print(
              '🔄 Rewarded retry ${_rewardedRetryAttempt}/$maxRetryAttempts',
            );
            Future.delayed(
              Duration(seconds: _rewardedRetryAttempt * 2),
              loadRewardedAd,
            );
          }
        },
      ),
    );
  }

  /// Reklam hazır olana kadar bekle (timeout ile)
  /// Kullanıcı butona bastığında çağrılır
  Future<bool> waitForRewardedAd({Duration? timeout}) async {
    // Zaten hazırsa hemen true dön
    if (isRewardedReady) {
      return true;
    }

    // Yükleme başlamamışsa başlat
    if (_rewardedStatus != AdStatus.loading) {
      loadRewardedAd();
    }

    // Completer yoksa veya tamamlanmışsa yeni oluştur
    if (_rewardedAdCompleter == null || _rewardedAdCompleter!.isCompleted) {
      // Zaten loading ama completer yok - kısa bekle
      _rewardedAdCompleter = Completer<bool>();
    }

    try {
      // Timeout ile bekle
      final result = await _rewardedAdCompleter!.future.timeout(
        timeout ?? adLoadTimeout,
        onTimeout: () {
          print('⏰ Rewarded reklam yükleme timeout');
          return false;
        },
      );
      return result && isRewardedReady;
    } catch (e) {
      print('❌ waitForRewardedAd hatası: $e');
      return false;
    }
  }

  /// Reklamın hazır olmasını garanti et (initState'te çağrılmalı)
  void ensureRewardedAdLoaded() {
    if (!isRewardedReady && _rewardedStatus != AdStatus.loading) {
      print('🔄 ensureRewardedAdLoaded: Reklam yükleniyor...');
      loadRewardedAd();
    } else if (isRewardedReady) {
      print('✅ ensureRewardedAdLoaded: Reklam zaten hazır');
    } else {
      print('⏳ ensureRewardedAdLoaded: Reklam zaten yükleniyor');
    }
  }

  /// Rewarded reklamı göster
  ///
  /// [onUserEarnedReward] - Kullanıcı ödülü kazandığında VE reklam kapandıktan SONRA çağrılır
  /// [onAdDismissed] - Reklam kapatıldığında çağrılır (ödül kazanılmadan)
  /// [onAdFailedToShow] - Reklam gösterilemediğinde çağrılır
  Future<bool> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
    void Function(String error)? onAdFailedToShow,
  }) async {
    if (_adsDisabled) {
      // Test modunda direkt ödül ver
      onUserEarnedReward();
      return true;
    }
    if (!isRewardedReady) {
      print('⚠️ Rewarded reklam hazır değil');
      loadRewardedAd(); // Reklam yüklemeyi başlat
      return false;
    }

    bool rewardEarned = false;

    // Callback'leri ayarla
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('🔄 Rewarded reklam kapatıldı (rewardEarned: $rewardEarned)');
        ad.dispose();
        _rewardedAd = null;
        _rewardedStatus = AdStatus.initial;

        // Önce yeni reklamı yükle
        loadRewardedAd();

        // Reklam KAPANDIKTAN SONRA callback'i çağır
        // Bu sayede uygulama ön planda olur ve navigation bozulmaz
        if (rewardEarned) {
          print('🎁 Ödül callback\'i çağrılıyor (reklam kapandı)');
          onUserEarnedReward();
        } else {
          onAdDismissed?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Rewarded gösterme hatası: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _rewardedStatus = AdStatus.failed;
        onAdFailedToShow?.call(error.message);
      },
      onAdShowedFullScreenContent: (ad) {
        print('📺 Rewarded reklam gösterildi');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('🎁 Ödül kazanıldı: ${reward.amount} ${reward.type}');
        // Sadece flag'i set et, callback'i reklam kapandığında çağıracağız
        rewardEarned = true;
      },
    );
    return true;
  }

  // ==================== UTILITY ====================

  /// Tüm reklamları önceden yükle
  void preloadAllAds() {
    if (_adsDisabled) {
      print('⚠️ Reklamlar devre dışı (test modu)');
      return;
    }
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// Tüm reklamları dispose et
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _interstitialStatus = AdStatus.initial;
    _rewardedStatus = AdStatus.initial;
    print('🧹 Tüm reklamlar dispose edildi');
  }
}
