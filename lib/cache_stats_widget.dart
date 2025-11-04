// ========================================
// STEP 3 (OPTIONAL): Add Cache Statistics
// Create a new file: cache_stats_widget.dart
// ========================================

import 'package:flutter/material.dart';
import 'firebase_cache_service.dart';
import 'main.dart'; // For color constants

class CacheStatsWidget extends StatefulWidget {
  const CacheStatsWidget({super.key});

  @override
  State<CacheStatsWidget> createState() => _CacheStatsWidgetState();
}

class _CacheStatsWidgetState extends State<CacheStatsWidget> {
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final firebaseCache = FirebaseCacheService();
    final data = await firebaseCache.getStats();
    
    if (mounted) {
      setState(() {
        stats = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: kAccentTeal),
          ),
        ),
      );
    }

    if (stats == null) {
      return const SizedBox.shrink();
    }

    final apiCallsSaved = stats!['api_calls_saved'] ?? 0;
    final cacheHits = stats!['cache_hits'] ?? 0;
    final cacheMisses = stats!['cache_misses'] ?? 0;
    final totalRequests = cacheHits + cacheMisses;
    final hitRate = totalRequests > 0 
        ? (cacheHits / totalRequests * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kAccentTeal.withOpacity(0.1),
              kPrimaryBlue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kAccentTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: kAccentTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Caching',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Saving API calls & speeding up searches',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGray,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: kAccentTeal),
                  onPressed: () {
                    setState(() => loading = true);
                    _loadStats();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.savings,
                    label: 'API Calls Saved',
                    value: _formatNumber(apiCallsSaved),
                    color: kEmerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed,
                    label: 'Cache Hit Rate',
                    value: '$hitRate%',
                    color: kAccentTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccentOrange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco, color: kAccentOrange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Every cached result saves server resources & speeds up your search!',
                      style: TextStyle(
                        fontSize: 12,
                        color: kCharcoal,
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: kGray,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// ========================================
// TO ADD THIS TO YOUR ABOUT PAGE:
// ========================================
// In your AboutPage widget, add this after the mission sections:

/*
const SizedBox(height: 24),
const CacheStatsWidget(),
const SizedBox(height: 24),
*/