import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally to support offline functionality
/// Stores course content, posts, and events for offline access
class CacheService {
  static const String _coursesCacheKey = 'cached_courses';
  static const String _postsCacheKey = 'cached_posts';
  static const String _eventsCacheKey = 'cached_events';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Caches courses data locally
  Future<void> cacheCourses(List<Map<String, dynamic>> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(courses);
      await prefs.setString(_coursesCacheKey, jsonString);
      await prefs.setString('${_cacheTimestampKey}_courses', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching courses: $e');
    }
  }

  /// Retrieves cached courses
  Future<List<Map<String, dynamic>>?> getCachedCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_coursesCacheKey);
      final timestampString = prefs.getString('${_cacheTimestampKey}_courses');
      
      if (jsonString == null || timestampString == null) return null;
      
      final timestamp = DateTime.parse(timestampString);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Cache expired
        await prefs.remove(_coursesCacheKey);
        await prefs.remove('${_cacheTimestampKey}_courses');
        return null;
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving cached courses: $e');
      return null;
    }
  }

  /// Caches posts data locally
  Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(posts);
      await prefs.setString(_postsCacheKey, jsonString);
      await prefs.setString('${_cacheTimestampKey}_posts', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching posts: $e');
    }
  }

  /// Retrieves cached posts
  Future<List<Map<String, dynamic>>?> getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_postsCacheKey);
      final timestampString = prefs.getString('${_cacheTimestampKey}_posts');
      
      if (jsonString == null || timestampString == null) return null;
      
      final timestamp = DateTime.parse(timestampString);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Cache expired
        await prefs.remove(_postsCacheKey);
        await prefs.remove('${_cacheTimestampKey}_posts');
        return null;
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving cached posts: $e');
      return null;
    }
  }

  /// Caches events data locally
  Future<void> cacheEvents(List<Map<String, dynamic>> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(events);
      await prefs.setString(_eventsCacheKey, jsonString);
      await prefs.setString('${_cacheTimestampKey}_events', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching events: $e');
    }
  }

  /// Retrieves cached events
  Future<List<Map<String, dynamic>>?> getCachedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_eventsCacheKey);
      final timestampString = prefs.getString('${_cacheTimestampKey}_events');
      
      if (jsonString == null || timestampString == null) return null;
      
      final timestamp = DateTime.parse(timestampString);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Cache expired
        await prefs.remove(_eventsCacheKey);
        await prefs.remove('${_cacheTimestampKey}_events');
        return null;
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving cached events: $e');
      return null;
    }
  }

  /// Clears all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coursesCacheKey);
      await prefs.remove(_postsCacheKey);
      await prefs.remove(_eventsCacheKey);
      await prefs.remove('${_cacheTimestampKey}_courses');
      await prefs.remove('${_cacheTimestampKey}_posts');
      await prefs.remove('${_cacheTimestampKey}_events');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

