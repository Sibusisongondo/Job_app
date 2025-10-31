import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'ad_manager.dart';

// --- Modern Color Palette & Fonts ---
const Color kPrimaryBlue = Color(0xFF1a365d);
const Color kDeepBlue = Color(0xFF2d3748);
const Color kAccentTeal = Color(0xFF0d9488);
const Color kAccentPurple = Color(0xFF7c3aed);
const Color kAccentOrange = Color(0xFFea580c);
const Color kBackground = Color(0xFFfafafa);
const Color kWhite = Color(0xFFFFFFFF);
const Color kCharcoal = Color(0xFF1f2937);
const Color kGray = Color(0xFF6b7280);
const Color kEmerald = Color(0xFF059669);

const rapidApiKey = 'ak_c64sigsmjo9gklyne4z4h55legp50l2ks8s6wan5bsg849a';
const apiHost = 'api.openwebninja.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.initialize();
  AdManager().loadInterstitialAd();
  runApp(const SAJobConnectSimple());
}

class SAJobConnectSimple extends StatelessWidget {
  const SAJobConnectSimple({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainNavigationPage(),
        ),
        GoRoute(
          path: '/job',
          redirect: (context, state) {
            final jobId = state.uri.queryParameters['id'];
            if (jobId != null && jobId.isNotEmpty) {
              deepLinkNotifier.setPendingJobId(jobId);
            }
            return '/';
          },
        ),
      ],
    );
    return MaterialApp.router(
      title: 'SAJobConnect',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryBlue,
          secondary: kAccentTeal,
          background: kBackground,
          surface: kWhite,
          error: kAccentOrange,
          onPrimary: kWhite,
          onSecondary: kWhite,
          onBackground: kCharcoal,
          onSurface: kCharcoal,
          onError: kWhite,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: kBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: kPrimaryBlue,
            letterSpacing: 1.1,
          ),
          iconTheme: IconThemeData(color: kAccentTeal),
          toolbarHeight: 60,
          shadowColor: kDeepBlue.withOpacity(0.10),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            color: kGray.withOpacity(0.7),
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: kWhite,
          shadowColor: kPrimaryBlue.withOpacity(0.06),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: kAccentTeal.withOpacity(0.15),
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: kAccentTeal,
            fontSize: 14,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(kAccentTeal),
            foregroundColor: MaterialStatePropertyAll(kWhite),
            padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
            textStyle: MaterialStatePropertyAll(TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              fontSize: 16,
            )),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            elevation: MaterialStatePropertyAll(2),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
          ),
          elevation: 8,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: kPrimaryBlue,
          secondary: kAccentTeal,
          background: kDeepBlue,
          surface: kCharcoal,
          error: kAccentOrange,
          onPrimary: kWhite,
          onSecondary: kWhite,
          onBackground: kWhite,
          onSurface: kWhite,
          onError: kWhite,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: kDeepBlue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: kWhite,
            letterSpacing: 1.1,
          ),
          iconTheme: IconThemeData(color: kAccentTeal),
          toolbarHeight: 60,
          shadowColor: kDeepBlue.withOpacity(0.10),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: kCharcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
          ),
          elevation: 8,
        ),
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  final GlobalKey<_JobListPageState> _jobListKey = GlobalKey<_JobListPageState>();
  
  late final List<Widget> _pages;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _hasShownInitialAd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      JobListPage(key: _jobListKey),
      const AboutPage(),
      const PrivacyPolicyPage(),
    ];
    
    deepLinkNotifier.addListener(_handleDeepLink);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deepLinkNotifier.pendingJobId != null) {
        _handleDeepLink();
      }
    });

    _loadBannerAd();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_hasShownInitialAd) {
        AdManager().showInterstitialAd();
        _hasShownInitialAd = true;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasShownInitialAd) {
      Future.delayed(const Duration(milliseconds: 500), () {
        AdManager().showInterstitialAd();
      });
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          _isBannerAdReady = false;
          ad.dispose();
          Future.delayed(const Duration(seconds: 30), () {
            _loadBannerAd();
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  void _handleDeepLink() {
    final jobId = deepLinkNotifier.pendingJobId;
    if (jobId != null) {
      print('🎯 Opening job: $jobId');
      setState(() => _currentIndex = 0);
      Future.delayed(const Duration(milliseconds: 300), () {
        _jobListKey.currentState?.openJobById(jobId);
        deepLinkNotifier.clearPendingJobId();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    deepLinkNotifier.removeListener(_handleDeepLink);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SAJobConnect', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: Icon(Icons.filter_list, color: kAccentTeal),
            tooltip: "Filter Jobs",
            onPressed: () {
              _jobListKey.currentState?.showFilterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: kAccentTeal),
            tooltip: "Refresh",
            onPressed: () {
              _jobListKey.currentState?.refreshJobs();
            },
          ),
        ] : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
    return Drawer(
      child: Column(
        children: [
          Container(
            height: isSmallScreen ? 100 : 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryBlue,
                  kAccentTeal,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        decoration: BoxDecoration(
                          color: kWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/icon/app_icon.png'),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'SAJobConnect',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (!isSmallScreen)
                        Text(
                          'Find your dream job',
                          style: TextStyle(
                            color: kWhite.withOpacity(0.8),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: 'Job Search',
                  index: 0,
                  isSelected: currentIndex == 0,
                  isSmallScreen: isSmallScreen,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  index: 1,
                  isSelected: currentIndex == 1,
                  isSmallScreen: isSmallScreen,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  index: 2,
                  isSelected: currentIndex == 2,
                  isSmallScreen: isSmallScreen,
                ),
                Divider(height: isSmallScreen ? 12 : 16, thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8, horizontal: 16),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: kGray,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: isSmallScreen ? 1 : 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? kAccentTeal.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 0 : 2),
        minTileHeight: isSmallScreen ? 40 : 50,
        leading: Icon(
          icon,
          color: isSelected ? kAccentTeal : kGray,
          size: isSmallScreen ? 20 : 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? kAccentTeal : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'Poppins',
            fontSize: isSmallScreen ? 13 : 15,
          ),
        ),
        onTap: () => onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryBlue, kAccentTeal],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/icon/app_icon.png'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'About SAJobConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'Our Mission',
              'SAJobConnect is dedicated to connecting talented South Africans with their dream careers. We believe that everyone deserves access to quality job opportunities, and we\'re here to make that journey easier.',
              Icons.rocket_launch,
            ),
            _buildInfoSection(
              'What We Do',
              'We aggregate job listings from across South Africa, providing you with a comprehensive platform to search, filter, and apply for positions that match your skills and career goals.',
              Icons.search,
            ),
            _buildInfoSection(
              'Why Choose Us',
              'Our platform focuses specifically on the South African job market, ensuring that all listings are relevant and accessible to local job seekers. We provide detailed job information, company ratings, and direct application links.',
              Icons.star,
            ),
            _buildInfoSection(
              'Contact Us',
              'Have questions or feedback? We\'d love to hear from you. Reach out to us at support@sajobconnect.co.za',
              Icons.email,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kAccentTeal.withOpacity(0.1),
                    kPrimaryBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccentTeal.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: kAccentOrange,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Made with ❤️ for South Africa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryBlue,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering careers, one job at a time',
                    style: TextStyle(
                      fontSize: 14,
                      color: kGray,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kAccentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: kAccentTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: kGray,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: kGray,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            _buildPolicySection(
              'Introduction',
              'SAJobConnect ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            _buildPolicySection(
              'Information We Collect',
              'We may collect information about you in a variety of ways. The information we may collect via the App includes:\n\n• Personal Data: When you use our search features, we may collect search queries and preferences to improve your experience.\n• Usage Data: We may collect information about how you access and use the App, including your device information, IP address, and usage patterns.\n• Location Data: With your permission, we may collect location information to provide location-based job recommendations.',
            ),
            _buildPolicySection(
              'Use of Your Information',
              'We may use the information we collect about you to:\n\n• Provide and maintain our App\n• Improve and personalize your experience\n• Send you relevant job recommendations\n• Respond to your inquiries and provide customer support\n• Monitor and analyze usage patterns\n• Comply with legal obligations',
            ),
            _buildPolicySection(
              'Sharing Your Information',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy:\n\n• Service Providers: We may share your information with trusted third-party service providers who assist us in operating our App.\n• Legal Requirements: We may disclose your information if required by law or to protect our rights.\n• Business Transfers: In the event of a merger or acquisition, your information may be transferred.',
            ),
            _buildPolicySection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure.',
            ),
            _buildPolicySection(
              'Third-Party Services',
              'Our App may contain links to third-party websites and services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.',
            ),
            _buildPolicySection(
              'Your Rights',
              'Depending on your location, you may have certain rights regarding your personal information:\n\n• Access: The right to access your personal data\n• Correction: The right to correct inaccurate information\n• Deletion: The right to request deletion of your data\n• Portability: The right to receive your data in a portable format',
            ),
            _buildPolicySection(
              'Children\'s Privacy',
              'Our App is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13.',
            ),
            _buildPolicySection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the App. Changes are effective immediately upon posting.',
            ),
            _buildPolicySection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@sajobconnect.co.za\nAddress: SAJobConnect, Cape Town, South Africa',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kAccentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccentTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: kAccentTeal,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your privacy and data security are our top priorities. We are committed to transparent and responsible data practices.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: kGray,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  List jobs = [];
  bool loading = true;
  String errorMsg = '';
  String searchQuery = 'all jobs in south africa';
  int currentPage = 1;
  int totalPages = 1;
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List> _jobCache = {};
  final Map<String, int> _pageCountCache = {};
  final Map<String, Map> _jobDetailsCache = {};

  final Map<int, NativeAd> _listNativeAds = {};
  final Map<int, bool> _listNativeAdsReady = {};

  Timer? _debounce;

  String selectedJobType = 'all';
  String selectedDatePosted = 'all';

  final List<String> jobTypes = [
    'all',
    'FULLTIME',
    'PARTTIME',
    'CONTRACTOR',
    'INTERN'
  ];

  final Map<String, String> dateFilters = {
    'all': 'All time',
    'today': 'Today',
    '3days': '3 days',
    'week': 'Week',
    'month': 'Month'
  };

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    fetchJobs();
  }

  void _loadNativeAdForPosition(int position) {
    if (_listNativeAds.containsKey(position)) return;

    final ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _listNativeAdsReady[position] = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('List native ad at position $position failed: $error');
          ad.dispose();
          _listNativeAds.remove(position);
          _listNativeAdsReady.remove(position);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: kWhite,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: kWhite,
          backgroundColor: kAccentTeal,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: kPrimaryBlue,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: kGray,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kAccentTeal,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      ),
    );

    _listNativeAds[position] = ad;
    _listNativeAdsReady[position] = false;
    ad.load();
  }

  void showFilterDialog() {
    _showFilterDialog();
  }

  void refreshJobs() {
    fetchJobs(page: currentPage);
  }

  Future<void> openJobById(String jobId) async {
    print('🔍 Looking for job: $jobId');

    final existingJob = jobs.firstWhere(
      (job) => job['job_id'] == jobId,
      orElse: () => null,
    );

    if (existingJob != null) {
      print('✅ Found in current list');
      _showJobDetails(context, existingJob);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kWhite,
                ),
              ),
              const SizedBox(width: 16),
              const Text('Loading job details...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: kAccentTeal,
        ),
      );
    }

    final jobDetails = await fetchJobDetails(jobId);

    if (jobDetails != null && mounted) {
      print('✅ Fetched job details');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showJobDetails(context, jobDetails);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load job listing'),
            backgroundColor: kAccentOrange,
          ),
        );
      }
    }
  }

  String _makeCacheKey(String query, int page) => '$query|$page';

  Future<void> fetchJobs({String? query, int? page}) async {
    setState(() {
      loading = true;
      errorMsg = '';
      jobs = [];
      if (query != null && query.isNotEmpty) searchQuery = query;
      if (page != null) currentPage = page;
    });

    final cacheKey = '${searchQuery}|${currentPage}|${selectedJobType}|${selectedDatePosted}';

    if (_jobCache.containsKey(cacheKey)) {
      setState(() {
        jobs = _jobCache[cacheKey]!;
        totalPages = _pageCountCache[searchQuery] ?? 1;
        loading = false;
      });
      return;
    }

    final url = Uri.https(apiHost, '/jsearch/search', {
      'query': searchQuery,
      'page': '$currentPage',
      'num_pages': '1',
      'country': 'rsa',
      'date_posted': selectedDatePosted,
      if (selectedJobType != 'all') 'employment_types': selectedJobType,
    });

    try {
      final resp = await http.get(
        url,
        headers: {
          'x-api-key': rapidApiKey,
        },
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final results = data['data'] ?? [];
        final pages = (data['metadata']?['total_pages'] ?? 1);

        final filtered = results.where((job) {
          final country = (job['job_country'] ?? '').toUpperCase();
          final location = ((job['job_location'] ?? job['location']) ?? '').toLowerCase();
          final isInSA = country == 'ZA' ||
              location.contains('south africa') ||
              location.contains('cape town') ||
              location.contains('johannesburg') ||
              location.contains('durban') ||
              location.contains('pretoria');
          bool jobTypeMatch = true;
          if (selectedJobType != 'all') {
            final jTypes = job['job_employment_types'] as List?;
            jobTypeMatch = jTypes?.contains(selectedJobType) ??
                (job['job_employment_type']?.toString().toUpperCase().contains(selectedJobType) ?? false);
          }
          return isInSA && jobTypeMatch;
        }).toList();

        filtered.sort((a, b) {
          final dateA = a['job_posted_at_timestamp'] as int? ?? 0;
          final dateB = b['job_posted_at_timestamp'] as int? ?? 0;
          return dateB.compareTo(dateA);
        });

        _jobCache[cacheKey] = filtered;
        _pageCountCache[searchQuery] = pages;

        setState(() {
          jobs = filtered;
          loading = false;
          totalPages = pages;
        });
      } else {
        setState(() {
          errorMsg = 'API error: ${resp.reasonPhrase}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to fetch jobs: $e';
        loading = false;
      });
    }
  }

  void _onSearch(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (text.trim().isEmpty) {
        fetchJobs(query: 'all jobs in south africa', page: 1);
      } else {
        String enhancedQuery = text.trim();
        if (!enhancedQuery.toLowerCase().contains('south africa') &&
            !enhancedQuery.toLowerCase().contains('cape town') &&
            !enhancedQuery.toLowerCase().contains('johannesburg') &&
            !enhancedQuery.toLowerCase().contains('durban')) {
          enhancedQuery += ' south africa';
        }
        fetchJobs(query: enhancedQuery, page: 1);
      }
    });
  }

  Future<Map?> fetchJobDetails(String jobId) async {
    if (_jobDetailsCache.containsKey(jobId)) {
      return _jobDetailsCache[jobId];
    }

    final url = Uri.https(apiHost, '/jsearch/job-details', {
      'job_id': jobId,
      'country': 'rsa',
    });

    try {
      final resp = await http.get(
        url,
        headers: {
          'x-api-key': rapidApiKey,
        },
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final jobDetails = data['data']?.isNotEmpty == true ? data['data'][0] : null;

        if (jobDetails != null) {
          _jobDetailsCache[jobId] = jobDetails;
          return jobDetails;
        }
      }
    } catch (e) {
      print('Error fetching job details: $e');
    }
    return null;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Filter Jobs',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Type:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedJobType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: jobTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type == 'all' ? 'All Types' : type,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            )),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedJobType = value!),
            ),
            const SizedBox(height: 16),
            Text('Date Posted:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDatePosted,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: dateFilters.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            )),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedDatePosted = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedJobType = 'all';
                selectedDatePosted = 'all';
              });
              Navigator.pop(context);
              fetchJobs(page: 1);
            },
            child: Text('Reset',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              fetchJobs(page: 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentTeal,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _formatSalary(Map job) {
    final minSalary = job['job_min_salary'];
    final maxSalary = job['job_max_salary'];
    final period = job['job_salary_period'];

    if (minSalary != null && maxSalary != null) {
      return 'R${_formatNumber(minSalary)} - R${_formatNumber(maxSalary)}${period != null ? '/$period' : ''}';
    } else if (minSalary != null) {
      return 'From R${_formatNumber(minSalary)}${period != null ? '/$period' : ''}';
    } else if (maxSalary != null) {
      return 'Up to R${_formatNumber(maxSalary)}${period != null ? '/$period' : ''}';
    }
    return '';
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  void _showJobDetails(BuildContext context, Map job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return SafeArea(
          bottom: false,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              initialChildSize: 0.80,
              snap: true,
              snapSizes: [0.5, 0.92],
              builder: (_, controller) => JobDetailsContent(
                job: job,
                controller: controller,
                onFetchDetails: fetchJobDetails,
                onShare: () => _shareJob(job),
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareJob(Map job) {
    final jobId = job['job_id'];
    final jobTitle = job['job_title'] ?? 'Job Opening';
    final company = job['employer_name'] ?? '';
    final location = job['job_location'] ?? job['location'] ?? '';

    if (jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to share this job'),
          backgroundColor: kAccentOrange,
        ),
      );
      return;
    }

    final link = 'https://sajobconnect.co.za/job?id=$jobId';

    final message = '''
🎯 Check out this job opportunity!

📋 $jobTitle${company.isNotEmpty ? '\n🏢 $company' : ''}${location.isNotEmpty ? '\n📍 $location' : ''}

👉 View full details: $link

Shared via SAJobConnect 💼
''';

    final box = context.findRenderObject() as RenderBox?;

    Share.share(
      message,
      subject: 'Job Opportunity: $jobTitle',
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    ).then((result) {
      if (result.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: kWhite),
                const SizedBox(width: 12),
                const Expanded(child: Text('Job shared successfully!')),
              ],
            ),
            backgroundColor: kAccentTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $error'),
            backgroundColor: kAccentOrange,
          ),
        );
      }
    });
  }

  static String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  int _getItemCount() {
    int adCount = jobs.length ~/ 5;
    return jobs.length + adCount;
  }

  int? _getAdPosition(int listIndex) {
    if ((listIndex + 1) % 6 == 0 && listIndex >= 5) {
      return ((listIndex + 1) ~/ 6);
    }
    return null;
  }

  int _getJobIndex(int listIndex) {
    int adsBeforeThisIndex = listIndex ~/ 6;
    return listIndex - adsBeforeThisIndex;
  }

  @override
  void dispose() {
    for (var ad in _listNativeAds.values) {
      ad.dispose();
    }
    _listNativeAds.clear();
    _listNativeAdsReady.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(24),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                  fontSize: 17, fontFamily: 'Poppins', color: kCharcoal),
              decoration: InputDecoration(
                hintText:
                    'Search jobs (e.g. software engineer, cape town)...',
                prefixIcon: Icon(Icons.search, color: kAccentTeal),
                border: InputBorder.none,
                filled: true,
                fillColor: kWhite,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: kGray),
                  onPressed: () {
                    _searchController.clear();
                    fetchJobs(query: 'all jobs in south africa', page: 1);
                  },
                ),
              ),
              onChanged: _onSearch,
              onSubmitted: (text) => fetchJobs(query: text.trim(), page: 1),
            ),
          ),
        ),
        if (loading)
          const Expanded(
              child: Center(
                  child: CircularProgressIndicator(color: kAccentTeal)))
        else if (errorMsg.isNotEmpty)
          Expanded(
              child: Center(
                  child: Text(errorMsg,
                      style: const TextStyle(
                          color: kAccentOrange, fontFamily: 'Poppins'))))
        else if (jobs.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off,
                      size: 60,
                      color: kAccentTeal.withOpacity(0.18)),
                  const SizedBox(height: 14),
                  const Text('No jobs found.',
                      style: TextStyle(
                          fontSize: 18, color: kGray, fontFamily: 'Poppins')),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _getItemCount(),
              separatorBuilder: (_, __) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final adPosition = _getAdPosition(index);
                if (adPosition != null) {
                  _loadNativeAdForPosition(adPosition);

                  if (_listNativeAdsReady[adPosition] == true &&
                      _listNativeAds[adPosition] != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: SizedBox(
                        height: 250,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: kGray.withOpacity(0.2), width: 1),
                          ),
                          child: AdWidget(ad: _listNativeAds[adPosition]!),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                final jobIndex = _getJobIndex(index);
                final job = jobs[jobIndex];
                final salary = _formatSalary(job);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: kAccentTeal.withOpacity(0.07),
                      radius: 28,
                      child: job['employer_logo'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                job['employer_logo'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.work,
                                  color: kAccentTeal,
                                  size: 32,
                                ),
                              ),
                            )
                          : Icon(Icons.work, color: kAccentTeal, size: 32),
                    ),
                    title: Text(
                      job['job_title'] ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${job['employer_name'] ?? ''} • ${job['job_location'] ?? job['location'] ?? ''}',
                            style: TextStyle(
                                fontSize: 14,
                                color: kAccentTeal,
                                fontFamily: 'Poppins'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (salary.isNotEmpty) ...[
                            Text(
                              salary,
                              style: TextStyle(
                                fontSize: 13,
                                color: kEmerald,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 13,
                                  color: kAccentPurple.withOpacity(0.15)),
                              const SizedBox(width: 4),
                              Text(
                                job['job_posted_at_datetime_utc'] != null
                                    ? _formatDate(
                                        job['job_posted_at_datetime_utc'])
                                    : job['job_posted_at'] ?? '',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: kGray,
                                    fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(
                            job['job_employment_type'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kAccentTeal,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          backgroundColor: kAccentTeal.withOpacity(0.15),
                        ),
                      ],
                    ),
                    onTap: () => _showJobDetails(context, job),
                    onLongPress: () => _shareJob(job),
                  ),
                );
              },
            ),
          ),
        if (!loading && jobs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.arrow_back_ios,
                      size: 13, color: kAccentTeal),
                  label: Text('Prev',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: kAccentTeal)),
                  onPressed: currentPage > 1 && !loading
                      ? () => fetchJobs(page: currentPage - 1)
                      : null,
                ),
                const SizedBox(width: 18),
                Text(
                  'Page $currentPage${totalPages > 1 ? ' of $totalPages' : ''}',
                  style: TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 18),
                OutlinedButton.icon(
                  icon: Icon(Icons.arrow_forward_ios,
                      size: 13, color: kAccentTeal),
                  label: Text('Next',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: kAccentTeal)),
                  onPressed: !loading && (currentPage < totalPages)
                      ? () => fetchJobs(page: currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class JobDetailsContent extends StatefulWidget {
  final Map job;
  final ScrollController controller;
  final Future<Map?> Function(String) onFetchDetails;
  final VoidCallback onShare;

  const JobDetailsContent({
    super.key,
    required this.job,
    required this.controller,
    required this.onFetchDetails,
    required this.onShare,
  });

  @override
  State<JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<JobDetailsContent> {
  Map? detailedJob;
  bool loadingDetails = false;

  NativeAd? _nativeAd1;
  NativeAd? _nativeAd2;
  bool _isNativeAd1Ready = false;
  bool _isNativeAd2Ready = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
    _loadNativeAd1();
    _loadNativeAd2();
  }

  void _loadNativeAd1() {
    _nativeAd1 = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isNativeAd1Ready = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad 1 failed to load: $error');
          _isNativeAd1Ready = false;
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: kWhite,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: kWhite,
          backgroundColor: kAccentTeal,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: kPrimaryBlue,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: kGray,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kAccentTeal,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    _nativeAd1!.load();
  }

  void _loadNativeAd2() {
    _nativeAd2 = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isNativeAd2Ready = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad 2 failed to load: $error');
          _isNativeAd2Ready = false;
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: kWhite,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: kWhite,
          backgroundColor: kAccentTeal,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: kPrimaryBlue,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: kGray,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kAccentTeal,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    _nativeAd2!.load();
  }

  Future<void> _loadJobDetails() async {
    final jobId = widget.job['job_id'];
    if (jobId != null) {
      setState(() => loadingDetails = true);

      final details = await widget.onFetchDetails(jobId);
      if (details != null && mounted) {
        setState(() {
          detailedJob = details;
          loadingDetails = false;
        });
      } else {
        setState(() => loadingDetails = false);
      }
    }
  }

  Map get currentJob => detailedJob ?? widget.job;

  String _formatSalary(Map job) {
    final minSalary = job['job_min_salary'];
    final maxSalary = job['job_max_salary'];
    final period = job['job_salary_period'];

    if (minSalary != null && maxSalary != null) {
      return 'R${_formatNumber(minSalary)} - R${_formatNumber(maxSalary)}${period != null ? ' per ${period.toLowerCase()}' : ''}';
    } else if (minSalary != null) {
      return 'From R${_formatNumber(minSalary)}${period != null ? ' per ${period.toLowerCase()}' : ''}';
    } else if (maxSalary != null) {
      return 'Up to R${_formatNumber(maxSalary)}${period != null ? ' per ${period.toLowerCase()}' : ''}';
    }
    return '';
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dt).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else if (difference < 30) {
        final weeks = (difference / 7).round();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else {
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildHighlightSection(String title, List<dynamic>? highlights, IconData icon) {
    if (highlights == null || highlights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 1.2),
        Row(
          children: [
            Icon(icon, color: kAccentTeal, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 12),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: kAccentTeal,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  highlight.toString(),
                  style: const TextStyle(fontSize: 15, height: 1.4, fontFamily: 'Poppins', color: kGray),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildEmployerReview() {
    final reviews = currentJob['employer_reviews'] as List?;
    if (reviews == null || reviews.isEmpty) return const SizedBox.shrink();

    final review = reviews[0];
    final score = review['score'] ?? 0.0;
    final reviewCount = review['review_count'] ?? 0;
    final maxScore = review['max_score'] ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 1.2),
        Row(
          children: [
            Icon(Icons.star_rate, color: Colors.amber[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Company Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Row(
                children: List.generate(maxScore, (index) {
                  return Icon(
                    index < score ? Icons.star : Icons.star_border,
                    color: Colors.amber[600],
                    size: 24,
                  );
                }),
              ),
              const SizedBox(width: 12),
              Text(
                '$score/$maxScore',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Text(
                '$reviewCount reviews',
                style: TextStyle(
                  fontSize: 14,
                  color: kGray,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nativeAd1?.dispose();
    _nativeAd2?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salary = _formatSalary(currentJob);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(bottom: BorderSide(color: kGray.withOpacity(0.2), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Job Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryBlue, fontFamily: 'Poppins')),
              Row(
                children: [
                  IconButton(icon: Icon(Icons.share, color: kAccentTeal), onPressed: widget.onShare, tooltip: 'Share Job'),
                  IconButton(icon: Icon(Icons.close, color: kGray), onPressed: () => Navigator.pop(context), tooltip: 'Close'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.controller,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loadingDetails)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: kAccentTeal)),
                        const SizedBox(width: 8),
                        Text('Loading detailed information...', style: TextStyle(fontSize: 12, color: kAccentTeal, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                Text(currentJob['job_title'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryBlue, letterSpacing: 1.1, fontFamily: 'Poppins')),
                const SizedBox(height: 10),
                Row(children: [Icon(Icons.business, size: 18, color: kAccentTeal), const SizedBox(width: 6), Flexible(child: Text(currentJob['employer_name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'Poppins', color: kCharcoal)))]),
                const SizedBox(height: 7),
                Row(children: [Icon(Icons.location_on, size: 18, color: kAccentOrange), const SizedBox(width: 6), Flexible(child: Text(currentJob['job_location'] ?? currentJob['location'] ?? '', style: TextStyle(fontSize: 15, fontFamily: 'Poppins', color: kGray)))]),
                if (salary.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: kEmerald.withOpacity(0.13), borderRadius: BorderRadius.circular(8), border: Border.all(color: kEmerald.withOpacity(0.3))), child: Row(children: [Icon(Icons.payments, size: 18, color: kEmerald), const SizedBox(width: 6), Expanded(child: Text(salary, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kEmerald, fontFamily: 'Poppins')))])),
                ],
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: Text(currentJob['job_employment_type'] ?? 'Unknown', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: kAccentTeal.withOpacity(0.15), labelStyle: TextStyle(color: kAccentTeal, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  if (currentJob['job_posted_at_datetime_utc'] != null || currentJob['job_posted_at'] != null)
                    Chip(label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_today, size: 14, color: kAccentPurple), const SizedBox(width: 4), Text(currentJob['job_posted_at_datetime_utc'] != null ? _formatDate(currentJob['job_posted_at_datetime_utc']) : currentJob['job_posted_at'] ?? '', style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))]), backgroundColor: kAccentPurple.withOpacity(0.08)),
                  if (currentJob['job_is_remote'] == true)
                    Chip(label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.home_work, size: 14, color: kAccentPurple), const SizedBox(width: 4), const Text('Remote')]), backgroundColor: kAccentPurple.withOpacity(0.08)),
                ]),
                _buildEmployerReview(),
                const Divider(height: 30, thickness: 1.2),
                Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryBlue, fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                Text(currentJob['job_description'] ?? 'No description available.', style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Poppins', color: kGray)),
                
                if (_isNativeAd1Ready && _nativeAd1 != null) ...[
                  const SizedBox(height: 20),
                  ConstrainedBox(constraints: const BoxConstraints(maxHeight: 280, minHeight: 150), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: kGray.withOpacity(0.2), width: 1)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AdWidget(ad: _nativeAd1!)))),
                  const SizedBox(height: 20),
                ],
                
                _buildHighlightSection('Qualifications', currentJob['job_highlights']?['Qualifications'], Icons.checklist),
                _buildHighlightSection('Responsibilities', currentJob['job_highlights']?['Responsibilities'], Icons.work_outline),
                _buildHighlightSection('Benefits', currentJob['job_highlights']?['Benefits'], Icons.card_giftcard),
                
                if (_isNativeAd2Ready && _nativeAd2 != null) ...[
                  const SizedBox(height: 24),
                  ConstrainedBox(constraints: const BoxConstraints(maxHeight: 280, minHeight: 150), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: kGray.withOpacity(0.2), width: 1)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AdWidget(ad: _nativeAd2!)))),
                  const SizedBox(height: 24),
                ],
                
                if (currentJob['job_apply_link'] != null)
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.open_in_new), label: const Text('Apply Now'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: kAccentTeal, foregroundColor: kWhite, textStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)), onPressed: () async {final url = currentJob['job_apply_link']; if (await canLaunchUrl(Uri.parse(url))) {await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);} else {if (context.mounted) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch link')));}}})),
                if (currentJob['apply_options'] != null && (currentJob['apply_options'] as List).length > 1) ...[
                  const SizedBox(height: 12),
                  Text('Apply via other platforms:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGray, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: ((currentJob['apply_options'] as List?) ?? []).skip(1).map<Widget>((option) => OutlinedButton(onPressed: () async {final url = option['apply_link']; if (url != null && await canLaunchUrl(Uri.parse(url))) {await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);}}, child: Text(option['publisher'] ?? 'Apply', style: TextStyle(fontFamily: 'Poppins')))).toList()),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}