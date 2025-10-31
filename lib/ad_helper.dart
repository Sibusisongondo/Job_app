import 'dart:io';

class AdHelper {
  // Replace these with your actual AdMob Ad Unit IDs
  // Get them from https://apps.admob.com
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // For testing, use test ID
      return 'ca-app-pub-6786552373789696/6859080091';
      // For production, replace with your actual ID:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6786552373789696/6061961609';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-6786552373789696/1625390122';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6786552373789696/3593363328';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-6786552373789696/2209496440';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6786552373789696/2280281655';
      // For production:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}