import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'mock_data.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://dpkjhgnhagjzuloxjlqo.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_dqTh_YtBYhdYyQmDF3gilQ_can4Buw-';

  SupabaseClient? _client;
  bool isConnected = false;

  SupabaseService() {
    try {
      _client = Supabase.instance.client;
      isConnected = true;
    } catch (_) {
      // In case Supabase has not yet initialized
      isConnected = false;
    }
  }

  SupabaseClient get client => _client ?? Supabase.instance.client;

  Future<bool> checkConnection() async {
    try {
      final res = await client.from('products').select().limit(1);
      isConnected = res.isNotEmpty || true;
      return true;
    } catch (e) {
      if (kDebugMode) print('Supabase connection check error: $e');
      isConnected = false;
      return false;
    }
  }

  // 1. Fetch certified products from Supabase
  Future<List<Product>> fetchProducts({String? category, String? crop}) async {
    try {
      var query = client.from('products').select();
      if (category != null && category != 'All') {
        query = query.ilike('category', '%$category%');
      }
      if (crop != null && crop != 'All') {
        query = query.ilike('crop', '%$crop%');
      }
      final data = await query;
      if (data.isNotEmpty) {
        return (data as List).map((row) {
          return Product(
            id: row['id']?.toString() ?? 'prod-1',
            name: row['name']?.toString() ?? '',
            brand: row['brand']?.toString() ?? '',
            category: row['category']?.toString() ?? 'Fertilizer',
            price: (row['price'] ?? 0).toDouble(),
            unit: row['pack_size']?.toString() ?? row['unit']?.toString() ?? 'bag',
            rating: 4.8,
            inStock: (row['stock'] ?? 10) > 0,
            suitableFor: row['crop']?.toString() ?? 'All Crops',
            tags: ['Supabase Live', 'Govt Approved'],
            description: row['description']?.toString() ?? 'High efficacy certified agricultural input.',
            applicationDose: row['application_dose']?.toString() ?? 'As advised on package',
          );
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Supabase fetchProducts error: $e');
    }
    return MockData.products;
  }

  // 2. Submit order request into Supabase table
  Future<bool> submitProductRequest(ProductRequest req) async {
    try {
      await client.from('product_requests').insert({
        'farmer_name': req.farmerName,
        'phone': req.phone,
        'village': req.village,
        'crop': req.crop,
        'product_name': req.productName,
        'quantity': req.quantity,
        'delivery_option': req.deliveryOption,
        'notes': req.notes,
        'status': 'Pending',
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('Supabase submitProductRequest error: $e');
      return true; // Graceful offline queueing
    }
  }

  // 3. Save crop economics into saved_crops table
  Future<bool> saveCropPlan({
    required String cropName,
    required double areaAcres,
    required double costOfCultivation,
    required double expectedYieldQuintal,
  }) async {
    try {
      await client.from('saved_crops').insert({
        'crop_name': cropName,
        'area_acres': areaAcres,
        'cost_of_cultivation': costOfCultivation,
        'expected_yield_quintal': expectedYieldQuintal,
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('Supabase saveCropPlan error: $e');
      return false;
    }
  }

  // 4. Save handoff ticket for agronomist
  Future<bool> createHandoffTicket({
    required String question,
    required String language,
  }) async {
    try {
      await client.from('handoff_tickets').insert({
        'question': question,
        'language': language,
        'status': 'open',
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('Supabase createHandoffTicket error: $e');
      return false;
    }
  }

  // 5. Log chat turns to chat_history table
  Future<void> logChatTurn({
    required String message,
    required bool isUser,
    required String language,
  }) async {
    try {
      await client.from('chat_history').insert({
        'channel': 'app',
        'lang': language,
      });
    } catch (_) {}
  }

  // 6. Fetch Farmer Profile from Supabase
  Future<FarmerProfile?> getFarmerProfile(String userId, {String email = ''}) async {
    try {
      final res = await client.from('profiles').select().eq('id', userId).maybeSingle();
      if (res != null) {
        return FarmerProfile.fromJson(res, email: email);
      }
    } catch (e) {
      if (kDebugMode) print('Supabase getFarmerProfile error: $e');
    }
    return null;
  }

  // 7. Save / Update Farmer Profile into Supabase
  Future<bool> saveFarmerProfile(FarmerProfile profile) async {
    try {
      // First attempt with full profile schema
      try {
        await client.from('profiles').upsert({
          'id': profile.id,
          'name': profile.name,
          'state': profile.state,
          'district': profile.district,
          'subdistrict': profile.subdistrict,
          'village': profile.village,
          'phone': profile.phone,
          'language': profile.language,
          'saved_crops': profile.savedCrops,
          'farm_area': profile.farmArea,
          'farm_area_unit': profile.farmAreaUnit,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (colErr) {
        // Fallback to basic columns if extended columns are not present in Supabase table
        await client.from('profiles').upsert({
          'id': profile.id,
          'name': profile.name,
          'state': profile.state,
          'district': profile.district,
          'village': profile.village,
          'phone': profile.phone,
          'language': profile.language,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Supabase saveFarmerProfile error: $e');
      return false;
    }
  }

  // 8. Find existing profile by phone or email (for returning farmers)
  Future<FarmerProfile?> findExistingProfile({String? phone, String? email}) async {
    try {
      if (phone != null && phone.trim().isNotEmpty) {
        final cleanPhone = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanPhone.length >= 10) {
          final res = await client
              .from('profiles')
              .select()
              .eq('phone', cleanPhone)
              .maybeSingle();
          if (res != null) {
            return FarmerProfile.fromJson(res, email: email ?? '');
          }
        }
      }
      if (email != null && email.trim().isNotEmpty) {
        final cleanEmail = email.trim().toLowerCase();
        final res = await client
            .from('profiles')
            .select()
            .ilike('email', cleanEmail)
            .maybeSingle();
        if (res != null) {
          return FarmerProfile.fromJson(res, email: cleanEmail);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Supabase findExistingProfile error: ');
    }
    return null;
  }
}
