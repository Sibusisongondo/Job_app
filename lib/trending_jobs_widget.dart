import 'package:flutter/material.dart';
import 'firebase_cache_service.dart';
// Import your main.dart color constants

class TrendingJobsSection extends StatefulWidget {
  final Function(String) onSearchTap;
  final Function(Map) onJobTap;
  
  const TrendingJobsSection({
    super.key,
    required this.onSearchTap,
    required this.onJobTap,
  });

  @override
  State<TrendingJobsSection> createState() => _TrendingJobsSectionState();
}

class _TrendingJobsSectionState extends State<TrendingJobsSection> {
  List<Map<String, dynamic>> trendingSearches = [];
  List<Map<String, dynamic>> hotJobs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingData();
  }

  Future<void> _loadTrendingData() async {
    final firebaseCache = FirebaseCacheService();
    
    try {
      final trending = await firebaseCache.getTrendingSearches(limit: 5);
      final hot = await firebaseCache.getHotJobs(limit: 10);
      
      if (mounted) {
        setState(() {
          trendingSearches = trending;
          hotJobs = hot;
          loading = false;
        });
      }
    } catch (e) {
      print('❌ Failed to load trending data: $e');
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: Color(0xFF0d9488)), // kAccentTeal
      );
    }

    // Don't show section if no data
    if (trendingSearches.isEmpty && hotJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending Searches Section
        if (trendingSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFFea580c), size: 20), // kAccentOrange
                const SizedBox(width: 8),
                Text(
                  'Trending Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a365d), // kPrimaryBlue
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                Text(
                  '${trendingSearches.length} popular',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6b7280), // kGray
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: trendingSearches.length,
              itemBuilder: (context, index) {
                final trending = trendingSearches[index];
                final searchCount = trending['count'] ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.search,
                      size: 16,
                      color: Color(0xFF0d9488), // kAccentTeal
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trending['query'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (searchCount > 1) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFea580c).withOpacity(0.2), // kAccentOrange
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$searchCount',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFea580c),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    backgroundColor: Color(0xFF0d9488).withOpacity(0.1),
                    side: BorderSide(color: Color(0xFF0d9488).withOpacity(0.3)),
                    onPressed: () {
                      widget.onSearchTap(trending['query']);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Hot Jobs Section
        if (hotJobs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Color(0xFFea580c), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Hot Jobs Right Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a365d),
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFFea580c).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.whatshot, size: 12, color: Color(0xFFea580c)),
                      const SizedBox(width: 4),
                      Text(
                        '${hotJobs.length} live',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFea580c),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: hotJobs.length,
              itemBuilder: (context, index) {
                final job = hotJobs[index];
                return _buildHotJobCard(job);
              },
            ),
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1, color: Color(0xFF6b7280).withOpacity(0.2)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildHotJobCard(Map job) {
    final salary = _formatSalary(job);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => widget.onJobTap(job),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF0d9488).withOpacity(0.1),
                      radius: 24,
                      child: job['employer_logo'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                job['employer_logo'],
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.work,
                                  color: Color(0xFF0d9488),
                                  size: 24,
                                ),
                              ),
                            )
                          : Icon(Icons.work, color: Color(0xFF0d9488), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['job_title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Color(0xFF1a365d),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Company name
                Text(
                  job['employer_name'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0d9488),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 13, color: Color(0xFF6b7280)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['job_location'] ?? job['location'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Salary if available
                if (salary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.payments, size: 13, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salary,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const Spacer(),
                
                // Hot badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFea580c).withOpacity(0.2),
                        Color(0xFFea580c).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFea580c).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.whatshot, size: 14, color: Color(0xFFea580c)),
                      const SizedBox(width: 4),
                      Text(
                        'Trending Now',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFea580c),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSalary(Map job) {
    final minSalary = job['job_min_salary'];
    final maxSalary = job['job_max_salary'];

    if (minSalary != null && maxSalary != null) {
      return 'R${_formatNumber(minSalary)} - R${_formatNumber(maxSalary)}';
    } else if (minSalary != null) {
      return 'From R${_formatNumber(minSalary)}';
    } else if (maxSalary != null) {
      return 'Up to R${_formatNumber(maxSalary)}';
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
}

// ========== ADD TO JobListPage build method ==========
// Replace the Column children in your JobListPage widget with:

/*
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // Search bar
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(24),
          child: TextField(
            controller: _searchController,
            // ... your existing TextField code
          ),
        ),
      ),
      
      // ADD THIS: Show trending section when on default/empty search
      if (!loading && searchQuery == 'all jobs in south africa' && currentPage == 1)
        TrendingJobsSection(
          onSearchTap: (query) {
            _searchController.text = query;
            fetchJobs(query: query, page: 1);
          },
          onJobTap: (job) {
            _showJobDetails(context, job);
          },
        ),
      
      // Rest of your existing UI
      if (loading)
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(color: kAccentTeal)
          )
        )
      else if (errorMsg.isNotEmpty)
        // ... existing error handling
      else if (jobs.isEmpty)
        // ... existing empty state
      else
        // ... existing job list
    ],
  );
}
*/