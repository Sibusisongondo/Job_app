import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FirebaseCacheService {
  static final FirebaseCacheService _instance = FirebaseCacheService._internal();
  factory FirebaseCacheService() => _instance;
  FirebaseCacheService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SharedPreferences? _prefs;

  // ⭐ NEW: In-memory cache (Tier 1 - fastest!)
  final Map<String, Map<String, dynamic>> _memoryCache = {};
  final Map<String, DateTime> _memoryCacheTimestamps = {};
  static const Duration _memoryCacheDuration = Duration(minutes: 5);

  
  // Collections
  static const String _jobsCollection = 'cached_jobs';
  static const String _searchesCollection = 'cached_searches';
  static const String _trendingCollection = 'trending_searches';
  static const String _statsCollection = 'app_stats';

  // Cache duration (2 days for Firebase, 12 hours for local)
  static const Duration _firebaseCacheDuration = Duration(days: 2);
  static const Duration _localCacheDuration = Duration(hours: 12);

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// THREE-TIER CACHE SYSTEM:
  /// 1. Memory (instant)
  /// 2. Local Storage (SharedPreferences - fast)
  /// 3. Firebase (shared across users - slower)
  
  // ============== SEARCH CACHING ==============
  
  /// Get cached search results (checks all 3 tiers)
  Future<Map<String, dynamic>?> getCachedSearch({
    required String query,
    required int page,
    required String jobType,
    required String datePosted,
  }) async {
    await initialize();
    final cacheKey = _generateCacheKey(query, page, jobType, datePosted);
    
    // ⭐ TIER 1: Check in-memory cache (INSTANT!)
    if (_memoryCache.containsKey(cacheKey)) {
      final timestamp = _memoryCacheTimestamps[cacheKey]!;
      if (DateTime.now().difference(timestamp) < _memoryCacheDuration) {
        print('⚡ MEMORY cache HIT: $query (page $page) - INSTANT!');
        return _memoryCache[cacheKey];
      } else {
        // Expired
        _memoryCache.remove(cacheKey);
        _memoryCacheTimestamps.remove(cacheKey);
      }
    }

    // TIER 2: Check local storage
    final localData = await _getLocalCache(cacheKey);
    if (localData != null) {
      // Save to memory for next time
      _memoryCache[cacheKey] = localData;
      _memoryCacheTimestamps[cacheKey] = DateTime.now();
      
      print('✅ LOCAL cache HIT: $query (page $page)');
      return localData;
    }
    
    // TIER 3: Check Firebase (shared cache)
    try {
      final doc = await _firestore
          .collection(_searchesCollection)
          .doc(cacheKey)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final cachedAt = (data['cached_at'] as Timestamp).toDate();
      
      // Check if cache is still valid (within 2 days)
      if (DateTime.now().difference(cachedAt) > _firebaseCacheDuration) {
        _deleteExpiredCache(cacheKey);
        return null;
      }

      // Update access stats (async, don't wait)
      _incrementSearchCount(cacheKey);

      final result = {
        'jobs': data['jobs'],
        'total_pages': data['total_pages'],
        'cached_at': cachedAt,
      };

      // Save to faster caches
      _memoryCache[cacheKey] = result;
      _memoryCacheTimestamps[cacheKey] = DateTime.now();

      // Save to local cache for next time
      await _saveLocalCache(cacheKey, result);

      print('✅ FIREBASE cache HIT: $query (page $page)');
      return result;
    } catch (e) {
      print('❌ Firebase cache error: $e');
      return null;
    }
  }

  /// Save search results to all cache tiers
  Future<void> cacheSearch({
    required String query,
    required int page,
    required String jobType,
    required String datePosted,
    required List<dynamic> jobs,
    required int totalPages,
  }) async {
    await initialize();
    final cacheKey = _generateCacheKey(query, page, jobType, datePosted);
    
    final cacheData = {
      'jobs': jobs,
      'total_pages': totalPages,
      'cached_at': DateTime.now().toIso8601String(),
    };

    // Save to all tiers
    _memoryCache[cacheKey] = {
      'jobs': jobs,
      'total_pages': totalPages,
      'cached_at': DateTime.now(), // DateTime for memory (no serialization needed)
    };
    _memoryCacheTimestamps[cacheKey] = DateTime.now();
    await _saveLocalCache(cacheKey, cacheData);
    _saveToFirebase(cacheKey, query, page, jobType, datePosted, jobs, totalPages);

    print('💾 Cached (ALL TIERS): $query (page $page) - ${jobs.length} jobs');
  }

  Future<void> _saveToFirebase(
    String cacheKey,
    String query,
    int page,
    String jobType,
    String datePosted,
    List<dynamic> jobs,
    int totalPages,
  ) async {
    try {
      await _firestore.collection(_searchesCollection).doc(cacheKey).set({
        'query': query,
        'page': page,
        'job_type': jobType,
        'date_posted': datePosted,
        'jobs': jobs,
        'total_pages': totalPages,
        'cached_at': FieldValue.serverTimestamp(),
        'access_count': 1,
        'last_accessed': FieldValue.serverTimestamp(),
      });

      // Update trending searches
      _updateTrendingSearch(query);
      
      print('☁️ Saved to Firebase: $query (page $page)');
    } catch (e) {
      print('❌ Failed to save to Firebase: $e');
    }
  }

  // ============== JOB DETAILS CACHING ==============
  
  /// Get cached job details
  Future<Map<String, dynamic>?> getCachedJobDetails(String jobId) async {
    await initialize();
    
    // Check memory cache
    final memKey = 'job_$jobId';
    if (_memoryCache.containsKey(memKey)) {
      final timestamp = _memoryCacheTimestamps[memKey]!;
      if (DateTime.now().difference(timestamp) < _memoryCacheDuration) {
        print('⚡ MEMORY cache HIT: job $jobId');
        return _memoryCache[memKey]?['job_data'] as Map<String, dynamic>?;
      }
    }
    
    // Check local cache
    final localData = await _getLocalCache(memKey);
    if (localData != null) {
      _memoryCache[memKey] = localData;
      _memoryCacheTimestamps[memKey] = DateTime.now();
      print('✅ LOCAL cache HIT: job $jobId');
      return localData['job_data'] as Map<String, dynamic>?;
    }

    // Check Firebase
    try {
      final doc = await _firestore
          .collection(_jobsCollection)
          .doc(jobId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final cachedAt = (data['cached_at'] as Timestamp).toDate();
      
      if (DateTime.now().difference(cachedAt) > _firebaseCacheDuration) {
        _deleteJobCache(jobId);
        return null;
      }

      final jobData = data['job_data'] as Map<String, dynamic>?;
      
      // Save to local cache
      if (jobData != null) {
        final cacheData = {'job_data': jobData, 'cached_at': cachedAt};
        _memoryCache[memKey] = cacheData;
        _memoryCacheTimestamps[memKey] = DateTime.now();
        await _saveLocalCache(memKey, cacheData);
      }

      print('✅ FIREBASE cache HIT: job $jobId');
      return jobData;
    } catch (e) {
      print('❌ Failed to get job from cache: $e');
      return null;
    }
  }

  /// Cache job details
  Future<void> cacheJobDetails(String jobId, Map<String, dynamic> jobData) async {
    await initialize();
    
    // Save to local cache
    final memKey = 'job_$jobId';
    final cacheData = {
      'job_data': jobData,
      'cached_at': DateTime.now().toIso8601String(),
    };
    
    _memoryCache[memKey] = {
      'job_data': jobData,
      'cached_at': DateTime.now(), // DateTime for memory
    };
    _memoryCacheTimestamps[memKey] = DateTime.now();
    await _saveLocalCache(memKey, cacheData);
    _saveJobToFirebase(jobId, jobData);

    print('💾 Cached job (ALL TIERS): $jobId');
  }

  Future<void> _saveJobToFirebase(String jobId, Map<String, dynamic> jobData) async {
    try {
      await _firestore.collection(_jobsCollection).doc(jobId).set({
        'job_id': jobId,
        'job_data': jobData,
        'cached_at': FieldValue.serverTimestamp(),
      });
      print('☁️ Saved job to Firebase: $jobId');
    } catch (e) {
      print('❌ Failed to save job to Firebase: $e');
    }
  }

  // ============== TRENDING DATA ==============
  
  /// Get trending searches
  Future<List<Map<String, dynamic>>> getTrendingSearches({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_trendingCollection)
          .orderBy('search_count', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'query': data['query'],
          'count': data['search_count'],
          'last_searched': (data['last_searched'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('❌ Failed to get trending searches: $e');
      return [];
    }
  }

  /// Get hot jobs (recently cached)
  Future<List<Map<String, dynamic>>> getHotJobs({int limit = 15}) async {
    try {
      final yesterday = DateTime.now().subtract(Duration(hours: 24));
      
      final snapshot = await _firestore
          .collection(_jobsCollection)
          .where('cached_at', isGreaterThan: Timestamp.fromDate(yesterday))
          .orderBy('cached_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return doc.data()['job_data'] as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('❌ Failed to get hot jobs: $e');
      return [];
    }
  }

  // ============== STATISTICS ==============
  
  /// Update app statistics
  Future<void> updateStats({
    int? apiCallsSaved,
    int? cacheHits,
    int? cacheMisses,
  }) async {
    try {
      final docRef = _firestore.collection(_statsCollection).doc('global');
      
      await docRef.set({
        if (apiCallsSaved != null) 'api_calls_saved': FieldValue.increment(apiCallsSaved),
        if (cacheHits != null) 'cache_hits': FieldValue.increment(cacheHits),
        if (cacheMisses != null) 'cache_misses': FieldValue.increment(cacheMisses),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Failed to update stats: $e');
    }
  }

  /// Get app statistics
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final doc = await _firestore.collection(_statsCollection).doc('global').get();
      return doc.data();
    } catch (e) {
      print('❌ Failed to get stats: $e');
      return null;
    }
  }

  // ⭐ NEW: Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _memoryCacheTimestamps.clear();
    print('🧹 Memory cache cleared');
  }

  // ============== LOCAL CACHE (SharedPreferences) ==============
  
  Future<Map<String, dynamic>?> _getLocalCache(String key) async {
    try {
      final jsonStr = _prefs?.getString('cache_$key');
      if (jsonStr == null) return null;

      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(data['_cached_at'] as String);

      // Check if local cache is still valid (6 hours)
      if (DateTime.now().difference(cachedAt) > _localCacheDuration) {
        await _prefs?.remove('cache_$key');
        return null;
      }

      data.remove('_cached_at');

      // Convert cached_at string back to DateTime if it exists
      if (data['cached_at'] is String) {
        data['cached_at'] = DateTime.parse(data['cached_at'] as String);
      }

      return data;
    } catch (e) {
      print('❌ Local cache read error: $e');
      return null;
    }
  }

  Future<void> _saveLocalCache(String key, Map<String, dynamic> data) async {
    try {
      final dataWithTimestamp = _convertDateTimesToStrings(Map<String, dynamic>.from(data));
      dataWithTimestamp['_cached_at'] = DateTime.now().toIso8601String();
      
      final jsonStr = json.encode(dataWithTimestamp);
      await _prefs?.setString('cache_$key', jsonStr);
    } catch (e) {
      print('❌ Local cache write error: $e');
    }
  }

  // Helper to recursively convert DateTime objects to ISO strings
  Map<String, dynamic> _convertDateTimesToStrings(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    
    map.forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = _convertDateTimesToStrings(value);
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _convertDateTimesToStrings(item);
          } else if (item is DateTime) {
            return item.toIso8601String();
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    });
    
    return result;
  }

  /// Clear old local cache entries
  Future<void> cleanupLocalCache() async {
    await initialize();
    try {
      final keys = _prefs?.getKeys() ?? {};
      final cacheKeys = keys.where((k) => k.startsWith('cache_')).toList();
      
      int removed = 0;
      for (final key in cacheKeys) {
        final data = await _getLocalCache(key.substring(6)); // Remove 'cache_' prefix
        if (data == null) {
          await _prefs?.remove(key);
          removed++;
        }
      }
      
      if (removed > 0) {
        print('🧹 Cleaned up $removed expired local cache entries');
      }
    } catch (e) {
      print('❌ Failed to cleanup local cache: $e');
    }
  }

  // ============== FIREBASE CLEANUP ==============
  
  /// Cleanup expired Firebase cache (run periodically)
  Future<void> cleanupExpiredCache() async {
    try {
      final cutoffDate = DateTime.now().subtract(_firebaseCacheDuration);
      
      // Clean searches
      final searchesSnapshot = await _firestore
          .collection(_searchesCollection)
          .where('cached_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .limit(100) // Process in batches
          .get();

      if (searchesSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in searchesSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🧹 Cleaned ${searchesSnapshot.docs.length} expired searches');
      }

      // Clean jobs
      final jobsSnapshot = await _firestore
          .collection(_jobsCollection)
          .where('cached_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .limit(100)
          .get();

      if (jobsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in jobsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🧹 Cleaned ${jobsSnapshot.docs.length} expired jobs');
      }
    } catch (e) {
      print('❌ Failed to cleanup cache: $e');
    }
  }

  // ============== HELPER METHODS ==============
  
  String _generateCacheKey(String query, int page, String jobType, String datePosted) {
    final normalized = query.toLowerCase().trim();
    return '${normalized}_${page}_${jobType}_$datePosted'
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w_]'), ''); // Remove special chars
  }

  Future<void> _incrementSearchCount(String cacheKey) async {
    try {
      await _firestore.collection(_searchesCollection).doc(cacheKey).update({
        'access_count': FieldValue.increment(1),
        'last_accessed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _updateTrendingSearch(String query) async {
    try {
      final normalized = query.toLowerCase().trim();
      final docRef = _firestore.collection(_trendingCollection).doc(normalized);
      
      await docRef.set({
        'query': query,
        'search_count': FieldValue.increment(1),
        'last_searched': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _deleteExpiredCache(String cacheKey) async {
    try {
      await _firestore.collection(_searchesCollection).doc(cacheKey).delete();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _deleteJobCache(String jobId) async {
    try {
      await _firestore.collection(_jobsCollection).doc(jobId).delete();
    } catch (e) {
      // Ignore errors
    }
  }
}