import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  DateTime? _lastInterstitialShown;

  // Initialize ads
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Show Interstitial Ad (with frequency control)
  Future<void> showInterstitialAd() async {
    // Only show ad if at least 3 minutes have passed since last ad
    if (_lastInterstitialShown != null) {
      final difference = DateTime.now().difference(_lastInterstitialShown!);
      if (difference.inMinutes < 3) {
        print('Too soon to show another interstitial ad');
        return;
      }
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      _lastInterstitialShown = DateTime.now();
      _isInterstitialAdReady = false;
    } else {
      print('Interstitial ad not ready');
      loadInterstitialAd(); // Try to load if not ready
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}