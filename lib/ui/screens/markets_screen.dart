import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/location_service.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'market_profit_arbitrage_screen.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  int _selectedTabIndex = 0; // 0: Net Realization, 1: Live Map Radar
  double _filterRadiusKm = 100.0;
  String _marketSourceFilter = 'All'; // 'All', 'Farmlovers', 'APMC'
  ApmcMandi? _selectedMandiForSheet;

  @override
  void initState() {
    super.initState();
    _selectedMandiForSheet = LocationService.masterMandis.first;
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();
    final farmer = agri.currentFarmer;

    final farmerLat = farmer?.latitude ?? 20.1477;
    final farmerLon = farmer?.longitude ?? 74.2263;
    final farmerVillage = farmer?.village.isNotEmpty == true ? farmer!.village : 'Lasalgaon';
    final farmerDistrict = farmer?.district.isNotEmpty == true ? farmer!.district : 'Nashik';

    // Get real sorted mandis by distance from farmer's GPS location
    final nearbyMandisWithDist = LocationService.instance.getNearbyMandisWithDistance(
      farmerLat: farmerLat,
      farmerLon: farmerLon,
    );

    final filteredMandis = nearbyMandisWithDist.where((entry) {
      if (_filterRadiusKm < 500 && entry.value > _filterRadiusKm) return false;
      if (_marketSourceFilter == 'Farmlovers') {
        return entry.key.isDirectFarmMarket;
      } else if (_marketSourceFilter == 'APMC') {
        return !entry.key.isDirectFarmMarket;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: Text(lang.t('nav_markets')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Crop Profit & Highest Price Finder',
            icon: const Icon(Icons.calculate_outlined, color: AppTheme.primaryGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketProfitArbitrageScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Google Maps Directions',
            icon: const Icon(Icons.directions, color: AppTheme.primaryGreen),
            onPressed: () {
              if (filteredMandis.isNotEmpty) {
                final topMandi = filteredMandis.first.key;
                LocationService.instance.launchGoogleMapsNavigation(
                  destinationLat: topMandi.lat,
                  destinationLon: topMandi.lon,
                  destinationTitle: topMandi.name,
                  originLat: farmerLat,
                  originLon: farmerLon,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Location Bar with GPS Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR FARM LOCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '$farmerVillage, $farmerDistrict (${farmerLat.toStringAsFixed(2)}°N, ${farmerLon.toStringAsFixed(2)}°E)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: agri.isUpdatingGpsLocation
                        ? null
                        : () async {
                            final success = await agri.updateFarmerLiveGps();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? '📍 Live GPS synced: Updated location & nearby markets'
                                        : 'Could not access GPS. Please check location permissions.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.greenBadge,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (agri.isUpdatingGpsLocation)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.greenText,
                              ),
                            )
                          else
                            const Icon(Icons.refresh, size: 12, color: AppTheme.greenText),
                          const SizedBox(width: 4),
                          Text(
                            agri.isUpdatingGpsLocation ? 'LOCATING...' : 'UPDATE GPS',
                            style: const TextStyle(
                              color: AppTheme.greenText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // AI Decision Recommendation Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3E22), Color(0xFF165B33)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AI DECISION: SELL THIS WEEK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Text(
                        '14-Day Model',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Predicted Peak: ₹2,090/qtl on Day 10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mandi arrivals expected to surge by +35% in week 2 due to fresh harvests, likely dropping wholesale prices back to ₹1,980/qtl. Best selling window is Days 5 to 8.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Toggle Tabs: Comparison List vs Live Map & Radar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0 ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assessment_outlined,
                              size: 16,
                              color: _selectedTabIndex == 0 ? Colors.white : AppTheme.textDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Price Calculator',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedTabIndex == 0 ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1 ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: _selectedTabIndex == 1 ? Colors.white : AppTheme.textDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Nearby Mandi Map',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedTabIndex == 1 ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Market Source Filter Chips (All, Farmlovers, APMC)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SourceFilterChip(
                    title: 'All Markets (${nearbyMandisWithDist.length})',
                    isSelected: _marketSourceFilter == 'All',
                    onTap: () => setState(() => _marketSourceFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _SourceFilterChip(
                    title: '🌱 Farmlovers Direct Markets (12)',
                    isSelected: _marketSourceFilter == 'Farmlovers',
                    onTap: () => setState(() => _marketSourceFilter = 'Farmlovers'),
                  ),
                  const SizedBox(width: 8),
                  _SourceFilterChip(
                    title: '🏛️ Govt APMC Mandis (20)',
                    isSelected: _marketSourceFilter == 'APMC',
                    onTap: () => setState(() => _marketSourceFilter = 'APMC'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Farmlovers Portal Integration Banner
            if (_marketSourceFilter == 'Farmlovers') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF059669), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🌱 Farmlovers Maharashtra Direct Market Network',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Extracted live from https://farmlovers.org/en/market/maharashtra. Direct farmer stalls, 0% APMC market cess, no commission agents, and +10-15% higher realization directly in your pocket.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => LocationService.instance.launchWebsiteUrl('https://farmlovers.org/en/market/maharashtra'),
                            child: const Text(
                              '🔗 Visit farmlovers.org/en/market/maharashtra →',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF047857),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tab 0: Net Realization Formula List
            if (_selectedTabIndex == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('market_calc_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ranked by Net In-Hand Cash (₹/qtl) • ${filteredMandis.length} Markets',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (filteredMandis.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No markets found matching the selected radius & source filters.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMandis.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, idx) {
                    final item = filteredMandis[idx].key;
                    final distanceKm = filteredMandis[idx].value;
                    final isWinner = idx == 0;

                    final grossPrice = item.modalPrice;
                    final transportCost = distanceKm * item.transportPerQtlKm;
                    final apmcFee = item.isDirectFarmMarket ? 0.0 : (grossPrice * (item.apmcCessPct / 100.0));
                    final transitLoss = item.isDirectFarmMarket ? (grossPrice * 0.008) : (grossPrice * 0.015);
                    final netReal = item.calculateNetRealization(distanceKm);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isWinner ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                          width: isWinner ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isWinner ? AppTheme.greenBadge : AppTheme.bgSand,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Rank #${idx + 1}',
                                        style: TextStyle(
                                          color: isWinner ? AppTheme.greenText : AppTheme.textDark,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${distanceKm.toInt()} km away',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Direct Farm Market Badge
                          if (item.isDirectFarmMarket) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '🌱 Farmlovers Direct Farm Hub',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '0% APMC Cess (Zero Middlemen)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (item.directBenefit != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSand,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 12, color: AppTheme.primaryGreen),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.directBenefit!,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          const SizedBox(height: 12),

                          // Formula Deductions Row
                          Row(
                            children: [
                              Expanded(
                                child: _FormulaItem(
                                  title: 'Gross Price',
                                  value: '₹${grossPrice.toInt()}',
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const Text(' - ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: _FormulaItem(
                                  title: 'Transport',
                                  value: '₹${transportCost.toInt()}',
                                  color: AppTheme.roseText,
                                ),
                              ),
                              const Text(' - ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: _FormulaItem(
                                  title: item.isDirectFarmMarket ? 'APMC Cess' : 'APMC (${item.apmcCessPct}%)',
                                  value: item.isDirectFarmMarket ? '₹0' : '₹${apmcFee.toInt()}',
                                  color: item.isDirectFarmMarket ? AppTheme.greenText : AppTheme.amberText,
                                ),
                              ),
                              const Text(' - ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: _FormulaItem(
                                  title: 'Loss',
                                  value: '₹${transitLoss.toInt()}',
                                  color: AppTheme.roseText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isWinner ? AppTheme.greenBadge : AppTheme.bgSand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isWinner ? '🏆 Highest Net In-Hand' : 'Net Cash in Pocket',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isWinner ? AppTheme.greenText : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  '₹${netReal.toStringAsFixed(1)} / qtl',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isWinner ? AppTheme.greenText : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Direct Action Buttons: Navigate with Google Maps, Portal & Call
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    LocationService.instance.launchGoogleMapsNavigation(
                                      destinationLat: item.lat,
                                      destinationLon: item.lon,
                                      destinationTitle: item.name,
                                      originLat: farmerLat,
                                      originLon: farmerLon,
                                    );
                                  },
                                  icon: const Icon(Icons.navigation_outlined, size: 16),
                                  label: const Text('Directions'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              if (item.isDirectFarmMarket) ...[
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    LocationService.instance.launchWebsiteUrl(
                                      item.websiteUrl ?? 'https://farmlovers.org/en/market/maharashtra',
                                    );
                                  },
                                  icon: const Icon(Icons.language, size: 16, color: Color(0xFF047857)),
                                  label: const Text('Farmlovers'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF047857),
                                    side: const BorderSide(color: Color(0xFF059669)),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  LocationService.instance.launchCallPhone(item.contactPhone);
                                },
                                icon: const Icon(Icons.phone_in_talk, size: 16, color: AppTheme.primaryGreen),
                                label: const Text('Call'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryGreen,
                                  side: const BorderSide(color: AppTheme.primaryGreen),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],

            // Tab 1: Live Map & Nearby Mandis Radar
            if (_selectedTabIndex == 1) ...[
              // Distance Radius Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search Radius:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [25.0, 50.0, 100.0, 500.0].map((radius) {
                      final isSel = _filterRadiusKm == radius;
                      final label = radius >= 500 ? 'All 20 States' : '${radius.toInt()} km';
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSel,
                        selectedColor: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.cardWhite,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppTheme.textDark,
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _filterRadiusKm = radius);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Visual Interactive Radar / Map Card
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Concentric Radar Rings representing distance zones
                    Center(
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),

                    // Farmer Central Pin
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_work, color: Colors.white, size: 24),
                          SizedBox(height: 2),
                          Text(
                            'My Farm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Mandi Pins plotted in radial directions
                    ..._buildRadarPins(filteredMandis),

                    // Top Left Badge
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filteredMandis.length} Mandis Detected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Right Google Maps Launcher
                    Positioned(
                      bottom: 12,
                      right: 14,
                      child: GestureDetector(
                        onTap: () {
                          if (filteredMandis.isNotEmpty) {
                            final sel = _selectedMandiForSheet ?? filteredMandis.first.key;
                            LocationService.instance.launchGoogleMapsNavigation(
                              destinationLat: sel.lat,
                              destinationLon: sel.lon,
                              destinationTitle: sel.name,
                              originLat: farmerLat,
                              originLon: farmerLon,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new, size: 14, color: AppTheme.primaryGreen),
                              SizedBox(width: 4),
                              Text(
                                'Open in Google Maps',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Nearby Mandis & Realization (${filteredMandis.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // Nearby Mandi Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMandis.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final item = filteredMandis[idx].key;
                  final distanceKm = filteredMandis[idx].value;
                  final netReal = item.calculateNetRealization(distanceKm);
                  final isSelected = _selectedMandiForSheet?.id == item.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedMandiForSheet = item);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.district}, ${item.state}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenBadge,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${distanceKm.toInt()} km',
                                  style: const TextStyle(
                                    color: AppTheme.greenText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Rates and Net Realization Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Today\'s Modal Price',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                  Text(
                                    '₹${item.modalPrice.toInt()} / qtl',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Estimated In-Hand Cash',
                                    style: TextStyle(fontSize: 11, color: AppTheme.greenText, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '₹${netReal.toStringAsFixed(1)} / qtl',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.majorCrops.split(',').map((crop) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgSand,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  crop.trim(),
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    LocationService.instance.launchGoogleMapsNavigation(
                                      destinationLat: item.lat,
                                      destinationLon: item.lon,
                                      destinationTitle: item.name,
                                      originLat: farmerLat,
                                      originLon: farmerLon,
                                    );
                                  },
                                  icon: const Icon(Icons.navigation_outlined, size: 16),
                                  label: const Text('Start Navigation'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              if (item.isDirectFarmMarket) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Open Farmlovers Portal',
                                  icon: const Icon(Icons.language, color: Color(0xFF047857), size: 20),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFD1FAE5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    LocationService.instance.launchWebsiteUrl(
                                      item.websiteUrl ?? 'https://farmlovers.org/en/market/maharashtra',
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Call Desk',
                                icon: const Icon(Icons.phone, color: AppTheme.primaryGreen, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppTheme.greenBadge,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  LocationService.instance.launchCallPhone(item.contactPhone);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRadarPins(List<MapEntry<ApmcMandi, double>> mandis) {
    if (mandis.isEmpty) return [];

    final pins = <Widget>[];
    // Radial offsets to disperse top mandis realistically around the radar center
    final offsets = [
      const Alignment(0.4, -0.6),
      const Alignment(-0.55, -0.4),
      const Alignment(0.7, 0.4),
      const Alignment(-0.6, 0.5),
      const Alignment(0.1, -0.8),
    ];

    for (int i = 0; i < mandis.length && i < offsets.length; i++) {
      final mandi = mandis[i].key;
      final dist = mandis[i].value;

      pins.add(
        Align(
          alignment: offsets[i],
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMandiForSheet = mandi);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront, color: Colors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${dist.toInt()}km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  mandi.name.split(' ').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return pins;
  }
}

class _FormulaItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _FormulaItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SourceFilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceFilterChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
