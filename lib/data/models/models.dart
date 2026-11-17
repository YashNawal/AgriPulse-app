class Commodity {
  final String id;
  final String name;
  final String localName;
  final String emoji;
  final String category;
  final double modalPrice;
  final String unit;
  final String trend;
  final double changePct;

  Commodity({
    required this.id,
    required this.name,
    required this.localName,
    required this.emoji,
    required this.category,
    required this.modalPrice,
    required this.unit,
    required this.trend,
    required this.changePct,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      localName: json['localName']?.toString() ?? json['local_name']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🌾',
      category: json['category']?.toString() ?? 'Grain',
      modalPrice: (json['modalPrice'] ?? json['modal_price'] ?? 0).toDouble(),
      unit: json['unit']?.toString() ?? '₹/qtl',
      trend: json['trend']?.toString() ?? 'UP',
      changePct: (json['changePct'] ?? json['change_pct'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'localName': localName,
    'emoji': emoji,
    'category': category,
    'modalPrice': modalPrice,
    'unit': unit,
    'trend': trend,
    'changePct': changePct,
  };
}

class MandiRecord {
  final String mandi;
  final String district;
  final String state;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final double arrivals;
  final double distanceKm;
  final double travelTimeHours;
  final double transportCostPerQtl;
  final double apmcFeePerQtl;
  final double transitLossPct;
  final double netRealizationPerQtl;
  final int rank;

  MandiRecord({
    required this.mandi,
    required this.district,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.arrivals,
    required this.distanceKm,
    required this.travelTimeHours,
    required this.transportCostPerQtl,
    required this.apmcFeePerQtl,
    required this.transitLossPct,
    required this.netRealizationPerQtl,
    this.rank = 1,
  });

  factory MandiRecord.fromJson(Map<String, dynamic> json) {
    return MandiRecord(
      mandi: json['mandi']?.toString() ?? json['mandi_name']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      state: json['state']?.toString() ?? 'Maharashtra',
      minPrice: (json['minPrice'] ?? json['min_price'] ?? 0).toDouble(),
      maxPrice: (json['maxPrice'] ?? json['max_price'] ?? 0).toDouble(),
      modalPrice: (json['modalPrice'] ?? json['modal_price'] ?? 0).toDouble(),
      arrivals: (json['arrivals'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? json['distance_km'] ?? 0).toDouble(),
      travelTimeHours: (json['travelTimeHours'] ?? json['travel_time_hours'] ?? 0).toDouble(),
      transportCostPerQtl: (json['transportCostPerQtl'] ?? json['transport_cost_per_qtl'] ?? 0).toDouble(),
      apmcFeePerQtl: (json['apmcFeePerQtl'] ?? json['apmc_fee_per_qtl'] ?? 0).toDouble(),
      transitLossPct: (json['transitLossPct'] ?? json['transit_loss_pct'] ?? 0).toDouble(),
      netRealizationPerQtl: (json['netRealizationPerQtl'] ?? json['net_realization_per_qtl'] ?? 0).toDouble(),
      rank: (json['rank'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'mandi': mandi,
    'district': district,
    'state': state,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'modalPrice': modalPrice,
    'arrivals': arrivals,
    'distanceKm': distanceKm,
    'travelTimeHours': travelTimeHours,
    'transportCostPerQtl': transportCostPerQtl,
    'apmcFeePerQtl': apmcFeePerQtl,
    'transitLossPct': transitLossPct,
    'netRealizationPerQtl': netRealizationPerQtl,
    'rank': rank,
  };
}

class PriceForecast {
  final String date;
  final double predictedPrice;
  final double lowerBound;
  final double upperBound;
  final String recommendation;

  PriceForecast({
    required this.date,
    required this.predictedPrice,
    required this.lowerBound,
    required this.upperBound,
    required this.recommendation,
  });

  factory PriceForecast.fromJson(Map<String, dynamic> json) {
    return PriceForecast(
      date: json['date']?.toString() ?? '',
      predictedPrice: (json['predictedPrice'] ?? json['predicted_price'] ?? 0).toDouble(),
      lowerBound: (json['lowerBound'] ?? json['lower_bound'] ?? 0).toDouble(),
      upperBound: (json['upperBound'] ?? json['upper_bound'] ?? 0).toDouble(),
      recommendation: json['recommendation']?.toString() ?? 'HOLD',
    );
  }
}

class SoilProfile {
  double n;
  double p;
  double k;
  double ph;
  double organicCarbon;
  double ec;
  double moisture;

  SoilProfile({
    this.n = 140,
    this.p = 22,
    this.k = 180,
    this.ph = 6.8,
    this.organicCarbon = 0.65,
    this.ec = 0.45,
    this.moisture = 28,
  });

  factory SoilProfile.fromJson(Map<String, dynamic> json) {
    return SoilProfile(
      n: (json['n'] ?? 140).toDouble(),
      p: (json['p'] ?? 22).toDouble(),
      k: (json['k'] ?? 180).toDouble(),
      ph: (json['ph'] ?? 6.8).toDouble(),
      organicCarbon: (json['organicCarbon'] ?? json['organic_carbon'] ?? 0.65).toDouble(),
      ec: (json['ec'] ?? 0.45).toDouble(),
      moisture: (json['moisture'] ?? 28).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'n': n,
    'p': p,
    'k': k,
    'ph': ph,
    'organic_carbon': organicCarbon,
    'ec': ec,
    'moisture': moisture,
  };
}

class CropRecommendation {
  final String crop;
  final int matchScore;
  final String expectedYield;
  final double estimatedRevenue;
  final double costOfCultivation;
  final double netProfit;
  final String reason;
  final String season;

  CropRecommendation({
    required this.crop,
    required this.matchScore,
    required this.expectedYield,
    required this.estimatedRevenue,
    required this.costOfCultivation,
    required this.netProfit,
    required this.reason,
    required this.season,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      crop: json['crop']?.toString() ?? '',
      matchScore: (json['matchScore'] ?? json['match_score'] ?? 85).toInt(),
      expectedYield: json['expectedYield']?.toString() ?? json['expected_yield']?.toString() ?? '18-22 qtl/acre',
      estimatedRevenue: (json['estimatedRevenue'] ?? json['estimated_revenue'] ?? 0).toDouble(),
      costOfCultivation: (json['costOfCultivation'] ?? json['cost_of_cultivation'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? json['net_profit'] ?? 0).toDouble(),
      reason: json['reason']?.toString() ?? '',
      season: json['season']?.toString() ?? 'Rabi',
    );
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final String unit;
  final double rating;
  final bool inStock;
  final String suitableFor;
  final List<String> tags;
  final String description;
  final String applicationDose;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.unit,
    required this.rating,
    required this.inStock,
    required this.suitableFor,
    required this.tags,
    required this.description,
    required this.applicationDose,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Fertilizer',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit']?.toString() ?? 'bag',
      rating: (json['rating'] ?? 4.5).toDouble(),
      inStock: json['inStock'] ?? json['in_stock'] ?? true,
      suitableFor: json['suitableFor']?.toString() ?? json['suitable_for']?.toString() ?? 'All Crops',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description']?.toString() ?? '',
      applicationDose: json['applicationDose']?.toString() ?? json['application_dose']?.toString() ?? 'As advised',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'category': category,
    'price': price,
    'unit': unit,
    'rating': rating,
    'in_stock': inStock,
    'suitable_for': suitableFor,
    'tags': tags,
    'description': description,
    'application_dose': applicationDose,
  };
}

class FertilizerPlan {
  final String crop;
  final String stage;
  final String recommendedProduct;
  final String dosage;
  final String timing;
  final String notes;

  FertilizerPlan({
    required this.crop,
    required this.stage,
    required this.recommendedProduct,
    required this.dosage,
    required this.timing,
    required this.notes,
  });

  factory FertilizerPlan.fromJson(Map<String, dynamic> json) {
    return FertilizerPlan(
      crop: json['crop']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      recommendedProduct: json['recommendedProduct']?.toString() ?? json['recommended_product']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      timing: json['timing']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}

class ProductRequest {
  final String farmerName;
  final String phone;
  final String village;
  final String crop;
  final String productName;
  final int quantity;
  final String deliveryOption;
  final String notes;

  ProductRequest({
    required this.farmerName,
    required this.phone,
    required this.village,
    required this.crop,
    required this.productName,
    required this.quantity,
    this.deliveryOption = 'Home Delivery',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'farmer_name': farmerName,
    'phone': phone,
    'village': village,
    'crop': crop,
    'product_name': productName,
    'quantity': quantity,
    'delivery_option': deliveryOption,
    'notes': notes,
  };
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? audioUrl;
  final String detectedLang;
  final bool isAudio;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.audioUrl,
    this.detectedLang = 'en',
    this.isAudio = false,
  });
}

class DiseaseDiagnosis {
  final String crop;
  final String disease;
  final double confidence;
  final String symptoms;
  final List<String> organicTreatments;
  final List<String> chemicalTreatments;
  final String prevention;

  DiseaseDiagnosis({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.symptoms,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.prevention,
  });

  factory DiseaseDiagnosis.fromJson(Map<String, dynamic> json) {
    return DiseaseDiagnosis(
      crop: json['crop']?.toString() ?? 'Plant',
      disease: json['disease']?.toString() ?? 'Healthy',
      confidence: (json['confidence'] ?? 90).toDouble(),
      symptoms: json['symptoms']?.toString() ?? '',
      organicTreatments: (json['organicTreatments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      chemicalTreatments: (json['chemicalTreatments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prevention: json['prevention']?.toString() ?? '',
    );
  }
}

class AlertItem {
  final String id;
  final String crop;
  final double targetPrice;
  final String condition;
  final DateTime createdAt;
  bool isActive;

  AlertItem({
    required this.id,
    required this.crop,
    required this.targetPrice,
    required this.condition,
    required this.createdAt,
    this.isActive = true,
  });
}

class FarmerProfile {
  final String id;
  final String email;
  final String name;
  final String state;
  final String district;
  final String subdistrict;
  final String village;
  final String phone;
  final List<String> savedCrops;
  final String language;
  final double latitude;
  final double longitude;
  final double farmArea;
  final String farmAreaUnit;

  FarmerProfile({
    this.id = '',
    this.email = '',
    this.name = '',
    this.state = 'Maharashtra',
    this.district = 'Nashik',
    this.subdistrict = 'Niphad',
    this.village = 'Lasalgaon',
    this.phone = '',
    this.savedCrops = const ['Onion', 'Wheat', 'Soybean'],
    this.language = 'en',
    this.latitude = 20.1477,
    this.longitude = 74.2263,
    this.farmArea = 1.0,
    this.farmAreaUnit = 'Acres',
  });

  FarmerProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? state,
    String? district,
    String? subdistrict,
    String? village,
    String? phone,
    List<String>? savedCrops,
    String? language,
    double? latitude,
    double? longitude,
    double? farmArea,
    String? farmAreaUnit,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      state: state ?? this.state,
      district: district ?? this.district,
      subdistrict: subdistrict ?? this.subdistrict,
      village: village ?? this.village,
      phone: phone ?? this.phone,
      savedCrops: savedCrops ?? this.savedCrops,
      language: language ?? this.language,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      farmArea: farmArea ?? this.farmArea,
      farmAreaUnit: farmAreaUnit ?? this.farmAreaUnit,
    );
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json, {String email = ''}) {
    return FarmerProfile(
      id: json['id']?.toString() ?? '',
      email: email.isNotEmpty ? email : (json['email']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      state: json['state']?.toString() ?? 'Maharashtra',
      district: json['district']?.toString() ?? 'Nashik',
      subdistrict: json['subdistrict']?.toString() ?? json['sub_district']?.toString() ?? 'Niphad',
      village: json['village']?.toString() ?? 'Lasalgaon',
      phone: json['phone']?.toString() ?? '',
      savedCrops: (json['saved_crops'] is List)
          ? (json['saved_crops'] as List).map((e) => e.toString()).toList()
          : const ['Onion', 'Wheat', 'Soybean'],
      language: json['language']?.toString() ?? 'en',
      latitude: (json['latitude'] ?? json['lat'] ?? 20.1477).toDouble(),
      longitude: (json['longitude'] ?? json['lon'] ?? 74.2263).toDouble(),
      farmArea: (json['farm_area'] ?? json['farmArea'] ?? 1.0).toDouble(),
      farmAreaUnit: json['farm_area_unit']?.toString() ?? json['farmAreaUnit']?.toString() ?? 'Acres',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'state': state,
    'district': district,
    'subdistrict': subdistrict,
    'village': village,
    'phone': phone,
    'saved_crops': savedCrops,
    'language': language,
    'latitude': latitude,
    'longitude': longitude,
    'farm_area': farmArea,
    'farm_area_unit': farmAreaUnit,
  };
}

enum FarmStockType {
  harvested, // In storage / warehouse / kanda chawl
  growing, // Currently in field / ground
}

class FarmStockItem {
  final String id;
  final String crop;
  final String variety;
  final FarmStockType type;
  // For harvested stock in storage
  final double quantityQuintals;
  final String storageLocation;
  final DateTime storageDate;
  // For in-ground growing crops
  final double acreage;
  final DateTime sowingDate;
  final String stage;
  final DateTime expectedHarvestDate;
  final double expectedYieldQuintals;
  final String notes;
  final String status; // 'In Storage', 'Growing', 'Sold'
  final double? soldPricePerQtl;
  final DateTime? soldDate;

  FarmStockItem({
    required this.id,
    required this.crop,
    this.variety = '',
    required this.type,
    this.quantityQuintals = 0.0,
    this.storageLocation = 'Farm Storage',
    DateTime? storageDate,
    this.acreage = 0.0,
    DateTime? sowingDate,
    this.stage = 'Vegetative',
    DateTime? expectedHarvestDate,
    this.expectedYieldQuintals = 0.0,
    this.notes = '',
    this.status = 'Active',
    this.soldPricePerQtl,
    this.soldDate,
  })  : storageDate = storageDate ?? DateTime.now(),
        sowingDate = sowingDate ?? DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate = expectedHarvestDate ?? DateTime.now().add(const Duration(days: 60));

  bool get isHarvested => type == FarmStockType.harvested;
  bool get isGrowing => type == FarmStockType.growing;

  int get daysAfterSowing => DateTime.now().difference(sowingDate).inDays;
  int get daysUntilHarvest => expectedHarvestDate.difference(DateTime.now()).inDays;

  FarmStockItem copyWith({
    String? id,
    String? crop,
    String? variety,
    FarmStockType? type,
    double? quantityQuintals,
    String? storageLocation,
    DateTime? storageDate,
    double? acreage,
    DateTime? sowingDate,
    String? stage,
    DateTime? expectedHarvestDate,
    double? expectedYieldQuintals,
    String? notes,
    String? status,
    double? soldPricePerQtl,
    DateTime? soldDate,
  }) {
    return FarmStockItem(
      id: id ?? this.id,
      crop: crop ?? this.crop,
      variety: variety ?? this.variety,
      type: type ?? this.type,
      quantityQuintals: quantityQuintals ?? this.quantityQuintals,
      storageLocation: storageLocation ?? this.storageLocation,
      storageDate: storageDate ?? this.storageDate,
      acreage: acreage ?? this.acreage,
      sowingDate: sowingDate ?? this.sowingDate,
      stage: stage ?? this.stage,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      expectedYieldQuintals: expectedYieldQuintals ?? this.expectedYieldQuintals,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      soldPricePerQtl: soldPricePerQtl ?? this.soldPricePerQtl,
      soldDate: soldDate ?? this.soldDate,
    );
  }

  factory FarmStockItem.fromJson(Map<String, dynamic> json) {
    return FarmStockItem(
      id: json['id']?.toString() ?? '',
      crop: json['crop']?.toString() ?? 'Onion',
      variety: json['variety']?.toString() ?? '',
      type: (json['type'] == 'growing') ? FarmStockType.growing : FarmStockType.harvested,
      quantityQuintals: (json['quantity_quintals'] ?? json['quantityQuintals'] ?? 0.0).toDouble(),
      storageLocation: json['storage_location']?.toString() ?? json['storageLocation']?.toString() ?? 'Farm Godown',
      storageDate: json['storage_date'] != null ? DateTime.tryParse(json['storage_date'].toString()) : null,
      acreage: (json['acreage'] ?? 0.0).toDouble(),
      sowingDate: json['sowing_date'] != null ? DateTime.tryParse(json['sowing_date'].toString()) : null,
      stage: json['stage']?.toString() ?? 'Vegetative',
      expectedHarvestDate: json['expected_harvest_date'] != null ? DateTime.tryParse(json['expected_harvest_date'].toString()) : null,
      expectedYieldQuintals: (json['expected_yield_quintals'] ?? json['expectedYieldQuintals'] ?? 0.0).toDouble(),
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      soldPricePerQtl: json['sold_price_per_qtl'] != null ? (json['sold_price_per_qtl']).toDouble() : null,
      soldDate: json['sold_date'] != null ? DateTime.tryParse(json['sold_date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'crop': crop,
    'variety': variety,
    'type': type == FarmStockType.growing ? 'growing' : 'harvested',
    'quantity_quintals': quantityQuintals,
    'storage_location': storageLocation,
    'storage_date': storageDate.toIso8601String(),
    'acreage': acreage,
    'sowing_date': sowingDate.toIso8601String(),
    'stage': stage,
    'expected_harvest_date': expectedHarvestDate.toIso8601String(),
    'expected_yield_quintals': expectedYieldQuintals,
    'notes': notes,
    'status': status,
    'sold_price_per_qtl': soldPricePerQtl,
    'sold_date': soldDate?.toIso8601String(),
  };
}

class LocationCropSuggestion {
  final String crop;
  final String localName;
  final String emoji;
  final String season;
  final int suitabilityScore;
  final String reason;
  final String expectedYield;
  final double costOfCultivationPerAcre;
  final double expectedRatePerQtl;
  final double projectedNetProfitPerAcre;
  final String waterRequirement;
  final int durationDays;

  LocationCropSuggestion({
    required this.crop,
    required this.localName,
    required this.emoji,
    required this.season,
    required this.suitabilityScore,
    required this.reason,
    required this.expectedYield,
    required this.costOfCultivationPerAcre,
    required this.expectedRatePerQtl,
    required this.projectedNetProfitPerAcre,
    required this.waterRequirement,
    required this.durationDays,
  });

  factory LocationCropSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationCropSuggestion(
      crop: json['crop']?.toString() ?? '',
      localName: json['localName']?.toString() ?? json['local_name']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🌱',
      season: json['season']?.toString() ?? 'Rabi',
      suitabilityScore: (json['suitabilityScore'] ?? json['suitability_score'] ?? 90).toInt(),
      reason: json['reason']?.toString() ?? '',
      expectedYield: json['expectedYield']?.toString() ?? json['expected_yield']?.toString() ?? '20-25 qtl/acre',
      costOfCultivationPerAcre: (json['costOfCultivationPerAcre'] ?? json['cost_of_cultivation'] ?? 15000).toDouble(),
      expectedRatePerQtl: (json['expectedRatePerQtl'] ?? json['expected_rate'] ?? 2000).toDouble(),
      projectedNetProfitPerAcre: (json['projectedNetProfitPerAcre'] ?? json['projected_net_profit'] ?? 30000).toDouble(),
      waterRequirement: json['waterRequirement']?.toString() ?? json['water_requirement']?.toString() ?? 'Medium',
      durationDays: (json['durationDays'] ?? json['duration_days'] ?? 110).toInt(),
    );
  }
}

class MarketArbitrageResult {
  final String mandi;
  final String district;
  final String state;
  final double distanceKm;
  final double travelTimeHours;
  final double modalPrice;
  final double grossRevenue;
  final double transportCost;
  final double apmcFee;
  final double transitLoss;
  final double totalExpenses;
  final double netProfit;
  final double netRealizationPerQtl;
  final bool isLocal;
  final bool isHighestGross;
  final bool isBestNetProfit;
  final double profitDiffVsLocal;
  final double profitPctVsLocal;
  final double lat;
  final double lon;
  final String contactPhone;
  final bool isDirectFarmMarket;

  MarketArbitrageResult({
    required this.mandi,
    required this.district,
    this.state = 'Maharashtra',
    required this.distanceKm,
    required this.travelTimeHours,
    required this.modalPrice,
    required this.grossRevenue,
    required this.transportCost,
    required this.apmcFee,
    required this.transitLoss,
    required this.totalExpenses,
    required this.netProfit,
    required this.netRealizationPerQtl,
    this.isLocal = false,
    this.isHighestGross = false,
    this.isBestNetProfit = false,
    this.profitDiffVsLocal = 0.0,
    this.profitPctVsLocal = 0.0,
    this.lat = 0.0,
    this.lon = 0.0,
    this.contactPhone = '',
    this.isDirectFarmMarket = false,
  });
}

class ArbitrageAnalysis {
  final String crop;
  final double quantityQuintals;
  final String originDistrict;
  final String vehicleType;
  final MarketArbitrageResult localMarket;
  final MarketArbitrageResult highestGrossMarket;
  final MarketArbitrageResult bestNetMarket;
  final List<MarketArbitrageResult> allMarketsRanked;
  final String recommendation;
  final bool shouldTravel;
  final double netGainAmount;

  ArbitrageAnalysis({
    required this.crop,
    required this.quantityQuintals,
    required this.originDistrict,
    required this.vehicleType,
    required this.localMarket,
    required this.highestGrossMarket,
    required this.bestNetMarket,
    required this.allMarketsRanked,
    required this.recommendation,
    required this.shouldTravel,
    required this.netGainAmount,
  });
}

