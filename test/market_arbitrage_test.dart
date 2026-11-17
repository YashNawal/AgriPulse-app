import 'package:flutter_test/flutter_test.dart';
import 'package:kisanmitra_app/data/services/location_service.dart';

void main() {
  group('Market Arbitrage & Profit Calculation Tests', () {
    final locationService = LocationService.instance;

    test('Computes arbitrage for Onion from Dhule with large volume', () {
      final analysis = locationService.calculateMarketArbitrage(
        crop: 'Onion',
        quantityQuintals: 70.0,
        originDistrict: 'Dhule',
      );

      expect(analysis.crop, 'Onion');
      expect(analysis.quantityQuintals, 70.0);
      expect(analysis.originDistrict, 'Dhule');

      // Local market should be close to Dhule (< 50 km)
      expect(analysis.localMarket.distanceKm, lessThanOrEqualTo(50.0));
      expect(analysis.localMarket.district, 'Dhule');

      // Highest gross market should have higher modal price than local
      expect(analysis.highestGrossMarket.modalPrice, greaterThan(analysis.localMarket.modalPrice));

      // With 70 quintals, traveling to a metro APMC (e.g. Pune / Vashi) yields higher net profit
      expect(analysis.shouldTravel, isTrue);
      expect(analysis.bestNetMarket.netProfit, greaterThan(analysis.localMarket.netProfit));
      expect(analysis.netGainAmount, greaterThan(0.0));
      expect(analysis.recommendation, contains('Travel to'));
    });

    test('Recommends selling locally for small volume when freight wipes out profit', () {
      final analysis = locationService.calculateMarketArbitrage(
        crop: 'Onion',
        quantityQuintals: 4.0,
        originDistrict: 'Dhule',
        vehicleId: 'eicher14', // Large vehicle with high minimum cost
      );

      expect(analysis.crop, 'Onion');
      expect(analysis.quantityQuintals, 4.0);

      // Distant transport freight wipes out price difference for small volume
      expect(analysis.shouldTravel, isFalse);
      expect(analysis.recommendation, contains('Sell locally'));
    });

    test('Correctly computes distance, transport freight, and gross revenue', () {
      const qty = 50.0;
      final analysis = locationService.calculateMarketArbitrage(
        crop: 'Wheat',
        quantityQuintals: qty,
        originDistrict: 'Nashik',
      );

      for (final market in analysis.allMarketsRanked) {
        // Gross revenue = quantity * modal price
        expect(market.grossRevenue, closeTo(qty * market.modalPrice, 0.01));

        // Net profit = gross - expenses
        expect(market.netProfit, closeTo(market.grossRevenue - market.totalExpenses, 0.01));

        // Realization per quintal = netProfit / quantity
        expect(market.netRealizationPerQtl, closeTo(market.netProfit / qty, 0.01));

        // Total expenses = transport + apmc fee + transit loss
        expect(market.totalExpenses, closeTo(market.transportCost + market.apmcFee + market.transitLoss, 0.01));
      }
    });

    test('Handles direct farm markets with 0% APMC cess', () {
      final analysis = locationService.calculateMarketArbitrage(
        crop: 'Tomato',
        quantityQuintals: 30.0,
        originDistrict: 'Pune',
      );

      final directMarkets = analysis.allMarketsRanked.where((m) => m.isDirectFarmMarket).toList();
      expect(directMarkets, isNotEmpty);

      for (final direct in directMarkets) {
        expect(direct.apmcFee, 0.0, reason: 'Direct farm markets must charge 0% APMC fee');
      }
    });

    test('Auto-suggests correct vehicle type based on volume', () {
      final v15 = LocationService.autoSuggestVehicle(15.0);
      expect(v15.id, 'bolero');

      final v50 = LocationService.autoSuggestVehicle(50.0);
      expect(v50.id, 'eicher14');

      final v100 = LocationService.autoSuggestVehicle(100.0);
      expect(v100.id, 'heavy6w');

      final v200 = LocationService.autoSuggestVehicle(200.0);
      expect(v200.id, 'trailer');
    });
  });
}
