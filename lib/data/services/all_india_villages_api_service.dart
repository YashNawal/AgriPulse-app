import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class AllIndiaVillagesApiService {
  static final AllIndiaVillagesApiService instance = AllIndiaVillagesApiService._internal();
  AllIndiaVillagesApiService._internal();

  /// Default API base URL from JayeshJadhav28/all-india-villages-api
  String baseUrl = 'https://all-india-villages-api-production.up.railway.app';
  String apiKey = '';
  String apiSecret = '';

  // In-memory cache for fast, offline-friendly access
  final Map<String, List<Map<String, dynamic>>> _cache = {};

  void configure({required String url, String? key, String? secret}) {
    baseUrl = url.replaceAll(RegExp(r'/+$'), '');
    if (key != null) apiKey = key;
    if (secret != null) apiSecret = secret;
  }

  Map<String, String> _headers() {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (apiKey.isNotEmpty) headers['X-API-Key'] = apiKey;
    if (apiSecret.isNotEmpty) headers['X-API-Secret'] = apiSecret;
    return headers;
  }

  /// 1. Fetch all Indian States
  Future<List<Map<String, dynamic>>> getStates() async {
    const cacheKey = 'states';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final uri = Uri.parse('$baseUrl/api/v1/states');
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = (decoded['data'] is List)
            ? List<Map<String, dynamic>>.from(decoded['data'])
            : (decoded is List ? List<Map<String, dynamic>>.from(decoded) : <Map<String, dynamic>>[]);
        if (list.isNotEmpty) {
          _cache[cacheKey] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('[AllIndiaVillagesApi] Error fetching states: $e');
    }

    // High-precision fallback using KisanMitra 20 target states
    final fallback = LocationService.targetStates.map((s) => {
      'id': s.toLowerCase().replaceAll(' ', '-'),
      'name': s,
      'code': s.substring(0, 2).toUpperCase(),
    }).toList();
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// 2. Fetch Districts for a given state
  Future<List<Map<String, dynamic>>> getDistricts(String stateNameOrId) async {
    final cacheKey = 'districts_$stateNameOrId';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final uri = Uri.parse('$baseUrl/api/v1/states/$stateNameOrId/districts');
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = (decoded['data'] is List)
            ? List<Map<String, dynamic>>.from(decoded['data'])
            : (decoded is List ? List<Map<String, dynamic>>.from(decoded) : <Map<String, dynamic>>[]);
        if (list.isNotEmpty) {
          _cache[cacheKey] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('[AllIndiaVillagesApi] Error fetching districts for $stateNameOrId: $e');
    }

    // Local fallback
    final fallbackList = LocationService.instance.getDistricts(stateNameOrId);
    final fallback = fallbackList.map((d) => {
      'id': d.toLowerCase().replaceAll(' ', '-'),
      'name': d,
      'code': d.substring(0, min(3, d.length)).toUpperCase(),
    }).toList();
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// 3. Fetch Sub-Districts / Tehsils / Talukas for a district
  Future<List<Map<String, dynamic>>> getSubdistricts(String districtNameOrId) async {
    final cacheKey = 'subdistricts_$districtNameOrId';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final uri = Uri.parse('$baseUrl/api/v1/districts/$districtNameOrId/subdistricts');
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = (decoded['data'] is List)
            ? List<Map<String, dynamic>>.from(decoded['data'])
            : (decoded is List ? List<Map<String, dynamic>>.from(decoded) : <Map<String, dynamic>>[]);
        if (list.isNotEmpty) {
          _cache[cacheKey] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('[AllIndiaVillagesApi] Error fetching subdistricts for $districtNameOrId: $e');
    }

    // Local fallback
    final fallbackList = LocationService.instance.getSubdistricts(districtNameOrId);
    final fallback = fallbackList.map((s) => {
      'id': s.toLowerCase().replaceAll(' ', '-'),
      'name': s,
      'code': s.substring(0, min(3, s.length)).toUpperCase(),
    }).toList();
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// 4. Fetch Villages for a sub-district
  Future<List<Map<String, dynamic>>> getVillages(String subdistrictNameOrId, {int page = 1, int limit = 50}) async {
    final cacheKey = 'villages_${subdistrictNameOrId}_$page';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final uri = Uri.parse('$baseUrl/api/v1/subdistricts/$subdistrictNameOrId/villages?page=$page&limit=$limit');
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = (decoded['data'] is List)
            ? List<Map<String, dynamic>>.from(decoded['data'])
            : (decoded is List ? List<Map<String, dynamic>>.from(decoded) : <Map<String, dynamic>>[]);
        if (list.isNotEmpty) {
          _cache[cacheKey] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('[AllIndiaVillagesApi] Error fetching villages for $subdistrictNameOrId: $e');
    }

    // Local fallback
    final fallbackList = LocationService.instance.getVillages(subdistrictNameOrId);
    final fallback = fallbackList.map((v) => {
      'id': v.toLowerCase().replaceAll(' ', '-'),
      'name': v,
      'code': v.substring(0, min(3, v.length)).toUpperCase(),
    }).toList();
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// 5. Full-text search across states, districts, sub-districts, and villages
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$baseUrl/api/v1/search?q=${Uri.encodeComponent(query)}');
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return (decoded['data'] is List)
            ? List<Map<String, dynamic>>.from(decoded['data'])
            : <Map<String, dynamic>>[];
      }
    } catch (e) {
      debugPrint('[AllIndiaVillagesApi] Error searching location: $e');
    }
    return [];
  }

  int min(int a, int b) => a < b ? a : b;
}
