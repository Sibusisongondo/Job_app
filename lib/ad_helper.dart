import 'dart:io';

class AdHelper {
  // Replace these with your actual AdMob Ad Unit IDs
  // Get them from https://apps.admob.com
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // For testing, use test ID
      return 'ca-app-pub-3940256099942544/6300978111';
      // For production, replace with your actual ID:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-3940256099942544/1033173712';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-3940256099942544/2247696110';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}