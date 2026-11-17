import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/services/api_service.dart';
import '../data/services/location_service.dart';
import '../data/services/mock_data.dart';
import '../data/services/soil_analysis_service.dart';
import '../data/services/supabase_service.dart';

class AgriProvider extends ChangeNotifier {
  static const String _prefKeyProfile = 'kisanmitra_farmer_profile';
  static const String _prefKeyProfilesCache = 'kisanmitra_profiles_cache_v1';
  static const String _prefKeyGuest = 'kisanmitra_is_guest';
  static const String _prefKeyStock = 'kisanmitra_farmer_stock';

  final ApiService apiService = ApiService();
  final SupabaseService supabaseService = SupabaseService();

  // Farm Stock & In-Ground Produce State
  List<FarmStockItem> farmStock = [];

  // State properties
  String selectedCommodity = 'onion';
  List<Commodity> commodities = MockData.commodities;
  List<MandiRecord> mandis = [];
  String mandiSort = 'net_realization';

  List<PriceForecast> forecasts = MockData.forecasts;
  
  List<Product> products = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  
  List<FertilizerPlan> fertilizerPlans = [];
  
  SoilProfile soilProfile = SoilProfile();
  List<CropRecommendation> soilRecommendations = [];
  bool isSoilAnalyzing = false;
  SoilReport? liveSoilReport;
  bool isGpsSoilAnalyzing = false;
  String? soilAnalysisError;
  bool isUpdatingGpsLocation = false;
  
  List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'init-1',
      text: 'Namaste Farmer Brother! Welcome to KisanMitra. Ask me about live mandi rates, stage-wise fertilizer doses, or pest control for your crop.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];
  bool isChatTyping = false;
  
  DiseaseDiagnosis? activeDiagnosis;
  String selectedDiseaseSample = 'tomato';
  bool isDiagnosing = false;
  
  List<AlertItem> alerts = [
    AlertItem(id: '1', crop: 'Onion', targetPrice: 2000, condition: 'Price >= 2000', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    AlertItem(id: '2', crop: 'Wheat', targetPrice: 2500, condition: 'Price >= 2500', createdAt: DateTime.now().subtract(const Duration(days: 1))),
  ];
  
  String? whatsAppCode;
  bool isWhatsAppLoading = false;
  bool isOnline = false;
  bool isSupabaseConnected = false;
  DateTime lastUpdated = DateTime.now();

  FarmerProfile? currentFarmer;
  bool isGuestMode = false;

  String get lastUpdatedFormatted {
    final fmt = DateFormat('h:mm a');
    return isOnline ? 'Live Cloud Sync (${fmt.format(lastUpdated)})' : 'Last updated: ${fmt.format(lastUpdated)} (Offline Cache)';
  }

  AgriProvider() {
    _initData();
  }

  void setFarmerProfile(FarmerProfile profile) {
    currentFarmer = profile;
    isGuestMode = false;
    _saveProfileToPrefs(profile);
    notifyListeners();
  }

  void setGuestMode(bool guest) {
    isGuestMode = guest;
    if (guest) {
      currentFarmer = FarmerProfile(
        name: 'Guest Farmer',
        state: 'Maharashtra',
        district: 'Nashik',
      );
    }
    _saveGuestModeToPrefs(guest);
    notifyListeners();
  }

  Future<void> _saveProfileToPrefs(FarmerProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyProfile, jsonEncode(profile.toJson()));
      await prefs.setBool(_prefKeyGuest, false);
      await cacheProfile(profile);
    } catch (_) {}
  }

  Future<void> cacheProfile(FarmerProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> cache = {};
      final raw = prefs.getString(_prefKeyProfilesCache);
      if (raw != null && raw.isNotEmpty) {
        try {
          cache = Map<String, dynamic>.from(jsonDecode(raw));
        } catch (_) {}
      }
      final cleanPhone = profile.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length >= 10) {
        cache['phone_$cleanPhone'] = profile.toJson();
      }
      if (profile.email.isNotEmpty && profile.email.contains('@')) {
        cache['email_${profile.email.toLowerCase().trim()}'] = profile.toJson();
      }
      await prefs.setString(_prefKeyProfilesCache, jsonEncode(cache));
    } catch (_) {}
  }

  Future<FarmerProfile?> findExistingProfile({String? phone, String? email}) async {
    if (currentFarmer != null) {
      if (phone != null && phone.trim().isNotEmpty) {
        final clean = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
        final curPhone = currentFarmer!.phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.length >= 10 && curPhone == clean) {
          return currentFarmer;
        }
      }
      if (email != null && email.trim().isNotEmpty) {
        if (currentFarmer!.email.toLowerCase().trim() == email.toLowerCase().trim()) {
          return currentFarmer;
        }
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKeyProfilesCache);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> cache = jsonDecode(raw);
        if (phone != null && phone.trim().isNotEmpty) {
          final clean = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.length >= 10 && cache.containsKey('phone_$clean')) {
            return FarmerProfile.fromJson(Map<String, dynamic>.from(cache['phone_$clean']));
          }
        }
        if (email != null && email.trim().isNotEmpty) {
          final key = 'email_${email.toLowerCase().trim()}';
          if (cache.containsKey(key)) {
            return FarmerProfile.fromJson(Map<String, dynamic>.from(cache[key]));
          }
        }
      }
      final primaryRaw = prefs.getString(_prefKeyProfile);
      if (primaryRaw != null && primaryRaw.isNotEmpty) {
        final primary = FarmerProfile.fromJson(jsonDecode(primaryRaw));
        if (phone != null && phone.trim().isNotEmpty) {
          final clean = phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.length >= 10 && primary.phone.replaceAll(RegExp(r'[^0-9]'), '') == clean) {
            return primary;
          }
        }
        if (email != null && email.trim().isNotEmpty) {
          if (primary.email.toLowerCase().trim() == email.toLowerCase().trim()) {
            return primary;
          }
        }
      }
    } catch (_) {}

    try {
      final cloudProfile = await supabaseService.findExistingProfile(phone: phone, email: email);
      if (cloudProfile != null) {
        await cacheProfile(cloudProfile);
        return cloudProfile;
      }
    } catch (_) {}

    return null;
  }

  Future<void> _saveGuestModeToPrefs(bool guest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyGuest, guest);
      if (guest && currentFarmer != null) {
        await prefs.setString(_prefKeyProfile, jsonEncode(currentFarmer!.toJson()));
      }
    } catch (_) {}
  }

  Future<void> loadProfileFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool(_prefKeyGuest) ?? false;
      isGuestMode = isGuest;
      final profileStr = prefs.getString(_prefKeyProfile);
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr);
        currentFarmer = FarmerProfile.fromJson(data, email: data['email']?.toString() ?? '');
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchFarmerProfileFromSupabase() async {
    try {
      final user = supabaseService.client.auth.currentUser;
      if (user != null) {
        final profile = await supabaseService.getFarmerProfile(user.id, email: user.email ?? '');
        if (profile != null) {
          currentFarmer = profile;
          isGuestMode = false;
          await _saveProfileToPrefs(profile);
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> logOut() async {
    try {
      await supabaseService.client.auth.signOut();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyProfile);
      await prefs.remove(_prefKeyGuest);
    } catch (_) {}
    currentFarmer = null;
    isGuestMode = false;
    notifyListeners();
  }

  Future<void> _initData() async {
    await loadProfileFromPrefs();
    await loadFarmStock();
    isOnline = await apiService.checkHealth();
    isSupabaseConnected = await supabaseService.checkConnection();
    mandis = await apiService.getMandis(selectedCommodity);
    _applyMandiSort();
    
    // Fetch products from Supabase or fallback
    products = await supabaseService.fetchProducts();
    if (products.isEmpty) {
      products = await apiService.getProducts();
    }
    
    fertilizerPlans = await apiService.getFertilizerPlans(selectedCommodity);
    activeDiagnosis = MockData.diagnoses['tomato'];
    lastUpdated = DateTime.now();
    notifyListeners();
  }

  Future<void> checkConnection() async {
    isOnline = await apiService.checkHealth();
    isSupabaseConnected = await supabaseService.checkConnection();
    lastUpdated = DateTime.now();
    notifyListeners();
  }

  void selectCommodity(String id) async {
    selectedCommodity = id;
    mandis = await apiService.getMandis(id);
    _applyMandiSort();
    fertilizerPlans = await apiService.getFertilizerPlans(id);
    notifyListeners();
  }

  void setMandiSort(String sortBy) {
    mandiSort = sortBy;
    _applyMandiSort();
    notifyListeners();
  }

  void _applyMandiSort() {
    if (mandiSort == 'net_realization') {
      mandis.sort((a, b) => b.netRealizationPerQtl.compareTo(a.netRealizationPerQtl));
    } else if (mandiSort == 'price') {
      mandis.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
    } else if (mandiSort == 'distance') {
      mandis.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
  }

  void setProductCategory(String cat) async {
    selectedCategory = cat;
    products = await supabaseService.fetchProducts(category: cat);
    if (products.isEmpty) {
      products = await apiService.getProducts(category: cat);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (searchQuery.trim().isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.brand.toLowerCase().contains(q) ||
      p.suitableFor.toLowerCase().contains(q)
    ).toList();
  }

  Future<bool> submitProductOrder(ProductRequest request) async {
    // 1. Submit to Supabase SQL storage
    await supabaseService.submitProductRequest(request);
    // 2. Submit to FastAPI backend
    final ok = await apiService.submitProductRequest(request);
    notifyListeners();
    return ok;
  }

  Future<bool> saveCropPlanToSupabase({
    required String cropName,
    required double areaAcres,
    required double costOfCultivation,
    required double expectedYieldQuintal,
  }) async {
    return await supabaseService.saveCropPlan(
      cropName: cropName,
      areaAcres: areaAcres,
      costOfCultivation: costOfCultivation,
      expectedYieldQuintal: expectedYieldQuintal,
    );
  }

  Future<void> runSoilAnalysis() async {
    isSoilAnalyzing = true;
    notifyListeners();
    soilRecommendations = await apiService.getSoilRecommendations(soilProfile);
    isSoilAnalyzing = false;
    notifyListeners();
  }

  /// Detects soil type and tailored crop recommendations using live GPS & ISRIC SoilGrids API
  Future<SoilReport?> analyzeSoilFromLiveGps({bool forceGps = true}) async {
    isGpsSoilAnalyzing = true;
    soilAnalysisError = null;
    notifyListeners();

    try {
      double lat = currentFarmer?.latitude ?? 20.1477;
      double lon = currentFarmer?.longitude ?? 74.2263;
      String? dist = currentFarmer?.district;

      if (forceGps) {
        try {
          final pos = await SoilAnalysisService.instance.getCurrentGpsPosition();
          if (pos != null) {
            lat = pos.latitude;
            lon = pos.longitude;
            dist = SoilAnalysisService.instance.identifyDistrictFromCoordinates(lat, lon);
            if (currentFarmer != null) {
              currentFarmer = currentFarmer!.copyWith(
                latitude: lat,
                longitude: lon,
                district: dist,
              );
              await _saveProfileToPrefs(currentFarmer!);
            }
          }
        } catch (gpsError) {
          debugPrint('GPS check note: $gpsError, utilizing farmer coordinates');
        }
      }

      final report = await SoilAnalysisService.instance.analyzeSoil(
        lat: lat,
        lon: lon,
        preferredDistrict: dist,
        state: currentFarmer?.state ?? 'Maharashtra',
      );

      liveSoilReport = report;

      // Sync manual sliders with detected scientific values
      soilProfile.ph = report.ph;
      soilProfile.organicCarbon = report.organicCarbon;
      soilProfile.n = report.nitrogen;
      soilProfile.p = report.phosphorus;
      soilProfile.k = report.potassium;

      // Convert suitable crops to CropRecommendation list
      soilRecommendations = report.suitableCrops.map((c) {
        const double cost = 22000.0;
        final double profit = c.suitabilityScore > 90 ? 75000.0 : 52000.0;
        return CropRecommendation(
          crop: c.cropName,
          matchScore: c.suitabilityScore,
          expectedYield: c.expectedYield,
          estimatedRevenue: cost + profit,
          costOfCultivation: cost,
          netProfit: profit,
          reason: '${c.reason} (Tip: ${c.managementTip})',
          season: c.season,
        );
      }).toList();

      isGpsSoilAnalyzing = false;
      notifyListeners();
      return report;
    } catch (e) {
      soilAnalysisError = e.toString();
      isGpsSoilAnalyzing = false;
      notifyListeners();
      return null;
    }
  }

  /// Updates farmer GPS coordinates from live device GPS sensor
  Future<bool> updateFarmerLiveGps() async {
    isUpdatingGpsLocation = true;
    notifyListeners();
    try {
      final pos = await SoilAnalysisService.instance.getCurrentGpsPosition();
      if (pos != null) {
        final dist = SoilAnalysisService.instance.identifyDistrictFromCoordinates(pos.latitude, pos.longitude);
        if (currentFarmer != null) {
          currentFarmer = currentFarmer!.copyWith(
            latitude: pos.latitude,
            longitude: pos.longitude,
            district: dist,
          );
        } else {
          currentFarmer = FarmerProfile(
            name: 'Kisan',
            latitude: pos.latitude,
            longitude: pos.longitude,
            district: dist,
            state: 'Maharashtra',
          );
        }
        await _saveProfileToPrefs(currentFarmer!);
        isUpdatingGpsLocation = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating farmer GPS: $e');
    }
    isUpdatingGpsLocation = false;
    notifyListeners();
    return false;
  }

  Future<void> sendChatMessage(String text, String lang) async {
    if (text.trim().isEmpty) return;

    chatMessages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    isChatTyping = true;
    notifyListeners();

    await supabaseService.logChatTurn(message: text, isUser: true, language: lang);

    final botReply = await apiService.sendChatMessage(text, lang);
    chatMessages.add(
      ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: botReply,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    isChatTyping = false;
    await supabaseService.logChatTurn(message: botReply, isUser: false, language: lang);
    notifyListeners();
  }

  void selectDiseaseSample(String cropKey) {
    selectedDiseaseSample = cropKey;
    isDiagnosing = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 600), () {
      activeDiagnosis = MockData.diagnoses[cropKey] ?? MockData.diagnoses['tomato'];
      isDiagnosing = false;
      notifyListeners();
    });
  }

  void addPriceAlert(String crop, double targetPrice, String condition) {
    alerts.insert(
      0,
      AlertItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        crop: crop,
        targetPrice: targetPrice,
        condition: condition,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void toggleAlert(String id) {
    final item = alerts.firstWhere((a) => a.id == id);
    item.isActive = !item.isActive;
    notifyListeners();
  }

  Future<void> generateWhatsAppCode(String phone) async {
    isWhatsAppLoading = true;
    notifyListeners();

    final res = await apiService.startWhatsAppLink(phone);
    whatsAppCode = res['code']?.toString() ?? '618924';
    isWhatsAppLoading = false;
    notifyListeners();
  }

  // ==========================================
  // FARM STOCK & GROWING PRODUCE MANAGEMENT
  // ==========================================

  Future<void> loadFarmStock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stockStr = prefs.getString(_prefKeyStock);
      if (stockStr != null && stockStr.isNotEmpty) {
        final List decoded = jsonDecode(stockStr);
        farmStock = decoded.map((e) => FarmStockItem.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        farmStock = List.from(MockData.defaultStockItems);
        await saveFarmStock();
      }
    } catch (_) {
      farmStock = List.from(MockData.defaultStockItems);
    }
    notifyListeners();
  }

  Future<void> saveFarmStock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = farmStock.map((e) => e.toJson()).toList();
      await prefs.setString(_prefKeyStock, jsonEncode(jsonList));
    } catch (_) {}
  }

  void addFarmStock(FarmStockItem item) {
    farmStock.insert(0, item);
    saveFarmStock();
    notifyListeners();
  }

  void updateFarmStock(FarmStockItem item) {
    final idx = farmStock.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      farmStock[idx] = item;
      saveFarmStock();
      notifyListeners();
    }
  }

  void deleteFarmStock(String id) {
    farmStock.removeWhere((e) => e.id == id);
    saveFarmStock();
    notifyListeners();
  }

  void markStockSold(String id, double soldPricePerQtl) {
    final idx = farmStock.indexWhere((e) => e.id == id);
    if (idx != -1) {
      farmStock[idx] = farmStock[idx].copyWith(
        status: 'Sold',
        soldPricePerQtl: soldPricePerQtl,
        soldDate: DateTime.now(),
      );
      saveFarmStock();
      notifyListeners();
    }
  }

  /// Total valuation (₹) of all harvested stock currently held in storage
  double get totalStoredProduceValue {
    double total = 0;
    for (final item in farmStock.where((e) => e.isHarvested && e.status != 'Sold')) {
      final comm = commodities.firstWhere(
        (c) => c.name.toLowerCase() == item.crop.toLowerCase() || c.id.toLowerCase() == item.crop.toLowerCase(),
        orElse: () => Commodity(id: '', name: '', localName: '', emoji: '', category: '', modalPrice: 2000, unit: '₹/qtl', trend: 'UP', changePct: 0),
      );
      total += item.quantityQuintals * comm.modalPrice;
    }
    return total;
  }

  /// Total quantity (quintals) of all stored produce
  double get totalStoredQuintals {
    return farmStock
        .where((e) => e.isHarvested && e.status != 'Sold')
        .fold(0.0, (sum, item) => sum + item.quantityQuintals);
  }

  /// Total acreage of crops actively in ground
  double get totalGrowingAcreage {
    return farmStock
        .where((e) => e.isGrowing && e.status != 'Harvested')
        .fold(0.0, (sum, item) => sum + item.acreage);
  }

  // ==========================================
  // LOCATION & CROP RECOMMENDATION HELPERS
  // ==========================================

  /// Get APMC mandis closest to farmer's location
  List<MandiRecord> getNearbyMandis({String? district}) {
    final dist = district ?? currentFarmer?.district ?? 'Nashik';
    return MockData.getNearbyMandisForDistrict(dist);
  }

  /// Get live price information specifically for the crops grown by this farmer
  List<Map<String, dynamic>> getFarmerCropPrices() {
    final crops = (currentFarmer?.savedCrops.isNotEmpty == true)
        ? currentFarmer!.savedCrops
        : ['Onion', 'Wheat', 'Maize'];

    final List<Map<String, dynamic>> results = [];
    final nearby = getNearbyMandis();
    final bestMandiName = nearby.isNotEmpty ? nearby.first.mandi : 'District APMC';

    for (final cropName in crops) {
      Commodity? matched;
      for (final c in commodities) {
        if (c.name.toLowerCase() == cropName.toLowerCase() ||
            c.id.toLowerCase() == cropName.toLowerCase() ||
            cropName.toLowerCase().contains(c.id.toLowerCase()) ||
            c.name.toLowerCase().contains(cropName.toLowerCase())) {
          matched = c;
          break;
        }
      }

      matched ??= Commodity(
        id: cropName.toLowerCase(),
        name: cropName,
        localName: cropName,
        emoji: '🌾',
        category: 'Crops',
        modalPrice: 2150,
        unit: '₹/qtl',
        trend: 'UP',
        changePct: 2.4,
      );

      results.add({
        'crop': cropName,
        'commodity': matched,
        'bestMandi': bestMandiName,
        'isGrownByFarmer': true,
      });
    }
    return results;
  }

  /// Get recommended crops suited to farmer's district
  List<LocationCropSuggestion> getLocationSuggestedCrops({String? district}) {
    final dist = district ?? currentFarmer?.district ?? 'Nashik';
    return MockData.getSuggestedCropsForDistrict(dist);
  }

  /// Update farmer district dynamically (updates nearby mandis & crop suggestions immediately)
  void updateFarmerDistrict(String newDistrict) {
    if (currentFarmer != null) {
      currentFarmer = currentFarmer!.copyWith(district: newDistrict);
      _saveProfileToPrefs(currentFarmer!);
    } else {
      currentFarmer = FarmerProfile(name: 'Farmer', district: newDistrict, state: 'Maharashtra');
      _saveProfileToPrefs(currentFarmer!);
    }
    notifyListeners();
  }

  /// 1-tap action to add a recommended crop straight into the farmer's growing fields
  void addSuggestedCropToGrowing(LocationCropSuggestion suggestion, {double acreage = 2.0}) {
    final estimatedYieldNum = double.tryParse(
      suggestion.expectedYield.split('-').first.replaceAll(RegExp(r'[^0-9.]'), ''),
    ) ?? 22.0;

    final newItem = FarmStockItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      crop: suggestion.crop.split('(').first.trim(),
      variety: suggestion.crop.contains('(') ? suggestion.crop.split('(').last.replaceAll(')', '').trim() : 'Certified Cultivar',
      type: FarmStockType.growing,
      acreage: acreage,
      sowingDate: DateTime.now(),
      stage: 'Sowing / Seedling',
      expectedHarvestDate: DateTime.now().add(Duration(days: suggestion.durationDays)),
      expectedYieldQuintals: acreage * estimatedYieldNum,
      notes: 'Recommended for ${currentFarmer?.district ?? 'Local'} (${suggestion.suitabilityScore}% agro-climate match). ${suggestion.reason}',
      status: 'Growing',
    );
    addFarmStock(newItem);
  }

  /// Calculate market price arbitrage, distance, and transportation profit
  ArbitrageAnalysis calculateMarketArbitrage({
    required String crop,
    required double quantityQuintals,
    String? originDistrict,
    String? vehicleId,
  }) {
    final district = originDistrict ?? currentFarmer?.district ?? 'Nashik';
    return LocationService.instance.calculateMarketArbitrage(
      crop: crop,
      quantityQuintals: quantityQuintals,
      originDistrict: district,
      vehicleId: vehicleId,
    );
  }
}
