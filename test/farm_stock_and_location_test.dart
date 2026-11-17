import 'package:flutter_test/flutter_test.dart';
import 'package:kisanmitra_app/data/models/models.dart';
import 'package:kisanmitra_app/data/services/mock_data.dart';
import 'package:kisanmitra_app/providers/agri_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Location Mandis & Crop Suggestions Tests', () {
    test('getNearbyMandisForDistrict returns correct mandis for Dhule', () {
      final mandis = MockData.getNearbyMandisForDistrict('Dhule');
      expect(mandis.isNotEmpty, isTrue);
      expect(mandis.first.mandi, contains('Dhule APMC'));
      expect(mandis.first.distanceKm, lessThanOrEqualTo(15));
      expect(mandis.any((m) => m.mandi.contains('Shirpur') || m.mandi.contains('Dondaicha')), isTrue);
    });

    test('getNearbyMandisForDistrict returns correct mandis for Pune', () {
      final mandis = MockData.getNearbyMandisForDistrict('Pune');
      expect(mandis.isNotEmpty, isTrue);
      expect(mandis.first.mandi, contains('Pune APMC'));
      expect(mandis.first.distanceKm, lessThanOrEqualTo(20));
      expect(mandis.any((m) => m.mandi.contains('Baramati') || m.mandi.contains('Shirur')), isTrue);
    });

    test('getSuggestedCropsForDistrict returns high-match crops for Dhule', () {
      final suggestions = MockData.getSuggestedCropsForDistrict('Dhule');
      expect(suggestions.isNotEmpty, isTrue);
      expect(suggestions.any((s) => s.crop.contains('Onion')), isTrue);
      expect(suggestions.any((s) => s.crop.contains('Maize')), isTrue);
      expect(suggestions.first.suitabilityScore, greaterThanOrEqualTo(90));
      expect(suggestions.first.projectedNetProfitPerAcre, greaterThan(25000));
    });

    test('getSuggestedCropsForDistrict returns high-match crops for Pune', () {
      final suggestions = MockData.getSuggestedCropsForDistrict('Pune');
      expect(suggestions.isNotEmpty, isTrue);
      expect(suggestions.any((s) => s.crop.contains('Sugarcane') || s.crop.contains('Tomato')), isTrue);
    });
  });

  group('Farm Stock Management Tests', () {
    test('AgriProvider initializes with default stock items', () async {
      final agri = AgriProvider();
      await agri.loadFarmStock();

      expect(agri.farmStock.isNotEmpty, isTrue);
      expect(agri.farmStock.any((i) => i.isHarvested), isTrue);
      expect(agri.farmStock.any((i) => i.isGrowing), isTrue);
      expect(agri.totalStoredQuintals, greaterThan(0));
      expect(agri.totalStoredProduceValue, greaterThan(0));
      expect(agri.totalGrowingAcreage, greaterThan(0));
    });

    test('AgriProvider can add, update, mark as sold, and delete stock', () async {
      final agri = AgriProvider();
      await agri.loadFarmStock();

      final initialCount = agri.farmStock.length;

      // Add a harvested item
      final newItem = FarmStockItem(
        id: 'test-onion-1',
        crop: 'Onion',
        variety: 'Garva',
        type: FarmStockType.harvested,
        quantityQuintals: 50.0,
        storageLocation: 'Test Kanda Chawl',
        storageDate: DateTime.now(),
        status: 'In Storage',
      );

      agri.addFarmStock(newItem);
      expect(agri.farmStock.length, equals(initialCount + 1));
      expect(agri.farmStock.first.id, equals('test-onion-1'));

      // Mark as sold
      agri.markStockSold('test-onion-1', 2200);
      final soldItem = agri.farmStock.firstWhere((e) => e.id == 'test-onion-1');
      expect(soldItem.status, equals('Sold'));
      expect(soldItem.soldPricePerQtl, equals(2200));

      // Delete item
      agri.deleteFarmStock('test-onion-1');
      expect(agri.farmStock.any((e) => e.id == 'test-onion-1'), isFalse);
    });

    test('AgriProvider getFarmerCropPrices returns prices for registered crops', () {
      final agri = AgriProvider();
      agri.setFarmerProfile(
        FarmerProfile(
          name: 'Yash',
          district: 'Dhule',
          savedCrops: ['Onion', 'Maize', 'Cotton'],
        ),
      );

      final cropPrices = agri.getFarmerCropPrices();
      expect(cropPrices.length, equals(3));
      expect(cropPrices[0]['crop'], equals('Onion'));
      expect((cropPrices[0]['commodity'] as Commodity).modalPrice, greaterThan(0));
      expect(cropPrices[0]['bestMandi'], isNotNull);
    });

    test('AgriProvider addSuggestedCropToGrowing converts suggestion into active field crop', () {
      final agri = AgriProvider();
      final suggestion = LocationCropSuggestion(
        crop: 'Hybrid Maize',
        localName: 'मका',
        emoji: '🌽',
        season: 'Kharif',
        suitabilityScore: 95,
        reason: 'Poultry hub demand',
        expectedYield: '28-32 qtl/acre',
        costOfCultivationPerAcre: 12000,
        expectedRatePerQtl: 2250,
        projectedNetProfitPerAcre: 55000,
        waterRequirement: 'Medium',
        durationDays: 105,
      );

      agri.addSuggestedCropToGrowing(suggestion, acreage: 3.5);
      expect(agri.farmStock.first.crop, equals('Hybrid Maize'));
      expect(agri.farmStock.first.isGrowing, isTrue);
      expect(agri.farmStock.first.acreage, equals(3.5));
      expect(agri.farmStock.first.expectedYieldQuintals, greaterThan(0));
    });
  });
}
