import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

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

const rapidApiKey = '4731ae8585msh4c8cf1638196dd3p1b4089jsn70a6475624b6';
const apiHost = 'jsearch.p.rapidapi.com';

void main() {
  runApp(const SAJobConnectSimple());
}

class SAJobConnectSimple extends StatelessWidget {
  const SAJobConnectSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ),
      home: const JobListPage(),
      debugShowCheckedModeBanner: false,
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

    final url = Uri.https(apiHost, '/search', {
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
          'x-rapidapi-host': apiHost,
          'x-rapidapi-key': rapidApiKey,
        },
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final results = data['data'] ?? [];
        final pages = (data['metadata']?['total_pages'] ?? 1);

        // --- Strict South Africa Only Filter ---
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

    final url = Uri.https(apiHost, '/job-details', {
      'job_id': jobId,
      'country': 'rsa',
    });

    try {
      final resp = await http.get(
        url,
        headers: {
          'x-rapidapi-host': apiHost,
          'x-rapidapi-key': rapidApiKey,
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

  // Replace the entire _showFilterDialog method with this updated version:

void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).colorScheme.surface, // Use theme surface color
      title: Text(
        'Filter Jobs', 
        style: TextStyle(
          fontFamily: 'Poppins', 
          color: Theme.of(context).colorScheme.onSurface, // Use theme text color
          fontWeight: FontWeight.bold
        )
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Type:', 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onSurface // Visible text color
            )
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedJobType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline, // Visible border
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface, // Proper background
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, // Visible dropdown text
              fontFamily: 'Poppins',
            ),
            dropdownColor: Theme.of(context).colorScheme.surface, // Dropdown background
            items: jobTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(
                type == 'all' ? 'All Types' : type, 
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.onSurface, // Visible item text
                )
              ),
            )).toList(),
            onChanged: (value) => setState(() => selectedJobType = value!),
          ),
          const SizedBox(height: 16),
          Text(
            'Date Posted:', 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onSurface // Visible text color
            )
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedDatePosted,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, // Visible dropdown text
              fontFamily: 'Poppins',
            ),
            dropdownColor: Theme.of(context).colorScheme.surface, // Dropdown background
            items: dateFilters.entries.map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value, 
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.onSurface, // Visible item text
                )
              ),
            )).toList(),
            onChanged: (value) => setState(() => selectedDatePosted = value!),
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
          child: Text(
            'Reset', 
            style: TextStyle(
              fontFamily: 'Poppins', 
              color: Theme.of(context).colorScheme.primary // Visible button text
            )
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            fetchJobs(page: 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentTeal,
            foregroundColor: kWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.95,
            minChildSize: 0.55,
            initialChildSize: 0.85,
            builder: (_, controller) => JobDetailsContent(
              job: job,
              controller: controller,
              onFetchDetails: fetchJobDetails,
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SAJobConnect', style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: kAccentTeal),
            tooltip: "Filter Jobs",
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: kAccentTeal),
            tooltip: "Refresh",
            onPressed: () => fetchJobs(page: currentPage),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 17, fontFamily: 'Poppins', color: kCharcoal),
                  decoration: InputDecoration(
                    hintText: 'Search jobs (e.g. software engineer, cape town)...',
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
              const Expanded(child: Center(child: CircularProgressIndicator(color: kAccentTeal)))
            else if (errorMsg.isNotEmpty)
              Expanded(child: Center(child: Text(errorMsg, style: const TextStyle(color: kAccentOrange, fontFamily: 'Poppins'))))
            else if (jobs.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 60, color: kAccentTeal.withOpacity(0.18)),
                      const SizedBox(height: 14),
                      const Text('No jobs found.', style: TextStyle(fontSize: 18, color: kGray, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 1),
                  itemBuilder: (context, i) {
                    final job = jobs[i];
                    final salary = _formatSalary(job);

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Poppins', color: Theme.of(context).colorScheme.onSurface),
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
                                style: TextStyle(fontSize: 14, color: kAccentTeal, fontFamily: 'Poppins'),
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
                                  Icon(Icons.calendar_today, size: 13, color: kAccentPurple.withOpacity(0.15)),
                                  const SizedBox(width: 4),
                                  Text(
                                    job['job_posted_at_datetime_utc'] != null
                                        ? _formatDate(job['job_posted_at_datetime_utc'])
                                        : job['job_posted_at'] ?? '',
                                    style: TextStyle(fontSize: 13, color: kGray, fontFamily: 'Poppins'),
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
                      icon: Icon(Icons.arrow_back_ios, size: 13, color: kAccentTeal),
                      label: Text('Prev', style: TextStyle(fontFamily: 'Poppins', color: kAccentTeal)),
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
                      icon: Icon(Icons.arrow_forward_ios, size: 13, color: kAccentTeal),
                      label: Text('Next', style: TextStyle(fontFamily: 'Poppins', color: kAccentTeal)),
                      onPressed: !loading && (currentPage < totalPages)
                          ? () => fetchJobs(page: currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class JobDetailsContent extends StatefulWidget {
  final Map job;
  final ScrollController controller;
  final Future<Map?> Function(String) onFetchDetails;

  const JobDetailsContent({
    super.key,
    required this.job,
    required this.controller,
    required this.onFetchDetails,
  });

  @override
  State<JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<JobDetailsContent> {
  Map? detailedJob;
  bool loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
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
  Widget build(BuildContext context) {
    final salary = _formatSalary(currentJob);

    return SingleChildScrollView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loadingDetails)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kAccentTeal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading detailed information...',
                    style: TextStyle(
                      fontSize: 12,
                      color: kAccentTeal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          Text(
            currentJob['job_title'] ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
              letterSpacing: 1.1,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.business, size: 18, color: kAccentTeal),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  currentJob['employer_name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: kCharcoal,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: kAccentOrange),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  currentJob['job_location'] ?? currentJob['location'] ?? '',
                  style: TextStyle(fontSize: 15, fontFamily: 'Poppins', color: kGray),
                ),
              )
            ],
          ),
          if (salary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kEmerald.withOpacity(0.13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kEmerald.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.payments, size: 18, color: kEmerald),
                  const SizedBox(width: 6),
                  Text(
                    salary,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kEmerald,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(currentJob['job_employment_type'] ?? 'Unknown'),
                backgroundColor: kAccentTeal.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: kAccentTeal,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              if (currentJob['job_posted_at_datetime_utc'] != null ||
                  currentJob['job_posted_at'] != null)
                Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: kAccentPurple),
                      const SizedBox(width: 4),
                      Text(
                        currentJob['job_posted_at_datetime_utc'] != null
                            ? _formatDate(currentJob['job_posted_at_datetime_utc'])
                            : currentJob['job_posted_at'] ?? '',
                        style: TextStyle(
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: kAccentPurple.withOpacity(0.08),
                  labelStyle: TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              if (currentJob['job_is_remote'] == true)
                Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_work, size: 14, color: kAccentPurple),
                      const SizedBox(width: 4),
                      const Text('Remote'),
                    ],
                  ),
                  backgroundColor: kAccentPurple.withOpacity(0.08),
                  labelStyle: TextStyle(
                    color: kAccentPurple,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
            ],
          ),
          _buildEmployerReview(),
          const Divider(height: 30, thickness: 1.2),
          Text(
            'Job Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentJob['job_description'] ?? 'No description available.',
            style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Poppins', color: kGray),
          ),
          _buildHighlightSection(
            'Qualifications',
            currentJob['job_highlights']?['Qualifications'],
            Icons.checklist,
          ),
          _buildHighlightSection(
            'Responsibilities',
            currentJob['job_highlights']?['Responsibilities'],
            Icons.work_outline,
          ),
          _buildHighlightSection(
            'Benefits',
            currentJob['job_highlights']?['Benefits'],
            Icons.card_giftcard,
          ),
          const SizedBox(height: 26),
          if (currentJob['job_apply_link'] != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: kAccentTeal,
                  foregroundColor: kWhite,
                  textStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () async {
                  final url = currentJob['job_apply_link'];
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch link')),
                      );
                    }
                  }
                },
              ),
            ),
          if (currentJob['apply_options'] != null &&
              (currentJob['apply_options'] as List).length > 1) ...[
            const SizedBox(height: 12),
            Text(
              'Apply via other platforms:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kGray,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ((currentJob['apply_options'] as List?) ?? [])
                  .skip(1)
                  .map<Widget>((option) => OutlinedButton(
                        onPressed: () async {
                          final url = option['apply_link'];
                          if (url != null && await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(option['publisher'] ?? 'Apply', style: TextStyle(fontFamily: 'Poppins')),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}