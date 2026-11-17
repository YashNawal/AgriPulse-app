import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/services/maharashtra_location_data.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'farm_stock_screen.dart';
import 'market_profit_arbitrage_screen.dart';
import 'onboarding/your_details_screen.dart';
import 'profit_calculator_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  void _showDistrictSelectorDialog(BuildContext context, AgriProvider agri) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = MaharashtraLocationData.districts
                .where((d) => d.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Your District',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nearby APMC markets & crop suggestions will update automatically for this location.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                      hintText: 'Search district (e.g. Dhule, Nashik, Pune)...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final dist = filtered[index];
                        final isSelected = agri.currentFarmer?.district.toLowerCase() == dist.toLowerCase();

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.location_on_outlined,
                            color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted,
                          ),
                          title: Text(
                            dist,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenBadge,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(color: AppTheme.greenText, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                )
                              : null,
                          onTap: () {
                            agri.updateFarmerDistrict(dist);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location updated to $dist! Markets & suggestions reloaded.'),
                                backgroundColor: AppTheme.primaryGreen,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();

    final farmerCrops = agri.getFarmerCropPrices();
    final nearbyMandis = agri.getNearbyMandis();
    final suggestedCrops = agri.getLocationSuggestedCrops();
    final currentDistrict = agri.currentFarmer?.district.isNotEmpty == true ? agri.currentFarmer!.district : 'Nashik';

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      body: RefreshIndicator(
        onRefresh: () async {
          await agri.checkConnection();
        },
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. WELCOME HERO CARD WITH DISTRICT CHIP
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33165B33),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
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
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                agri.isOnline ? Icons.wifi : Icons.wifi_off,
                                size: 14,
                                color: agri.isOnline ? AppTheme.accentEmerald : Colors.amber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                agri.isSupabaseConnected ? 'SUPABASE CLOUD LIVE' : (agri.isOnline ? 'API CONNECTED' : 'OFFLINE CACHE'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // District selector badge (Clickable to switch location)
                        InkWell(
                          onTap: () => _showDistrictSelectorDialog(context, agri),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  currentDistrict,
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      agri.currentFarmer?.name.isNotEmpty == true
                          ? 'Namaste, ${agri.currentFarmer!.name}!'
                          : lang.t('app_name'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live farm advisory, nearby APMC rates & customized crop planning.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick profile info strip
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.landscape_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                '${agri.currentFarmer?.farmArea != null ? (agri.currentFarmer!.farmArea % 1 == 0 ? agri.currentFarmer!.farmArea.toInt() : agri.currentFarmer!.farmArea) : 2.5} ${agri.currentFarmer?.farmAreaUnit ?? 'Acres'}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                '${agri.currentFarmer?.savedCrops.length ?? 0} Registered Crops',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 2. 🌾 PRICES FOR CROPS YOU HAVE GROWN
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🌾 Prices for Crops You Have Grown',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Live APMC rates for your active crops',
                        style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YourDetailsScreen(initialProfile: agri.currentFarmer),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Edit Crops', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 136,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: farmerCrops.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final item = farmerCrops[idx];
                    final cropName = item['crop'] as String;
                    final Commodity comm = item['commodity'] as Commodity;
                    final bestMandi = item['bestMandi'] as String;

                    return GestureDetector(
                      onTap: () {
                        agri.selectCommodity(comm.id);
                        onNavigateTab(1); // Jump to Prices
                      },
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(comm.emoji, style: const TextStyle(fontSize: 22)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: comm.trend == 'UP' ? AppTheme.greenBadge : AppTheme.roseBadge,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${comm.changePct >= 0 ? '+' : ''}${comm.changePct}%',
                                    style: TextStyle(
                                      color: comm.trend == 'UP' ? AppTheme.greenText : AppTheme.roseText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              cropName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${comm.modalPrice.toInt()} /qtl',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Best: $bestMandi',
                              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 🚀 CROP ARBITRAGE & TRANSPORT PROFIT FINDER BANNER
              // ==========================================
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarketProfitArbitrageScreen(
                        initialCrop: farmerCrops.isNotEmpty ? farmerCrops.first['crop'] as String : 'Onion',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'HIGHEST PRICE & PROFIT CALCULATOR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Calculate Distance, Truck Freight & Net Profit',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Compare $currentDistrict vs state highest APMC (Vashi, Pune, Lasalgaon)',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_forward, color: Color(0xFF065F46), size: 18),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. 📍 MARKETS NEAR YOUR LOCATION
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 18, color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Markets Near $currentDistrict',
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Closest APMC auction yards sorted by distance',
                        style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab(2), // Jump to Markets
                    child: Text(
                      lang.t('view_all'),
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Mandi List Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nearbyMandis.take(3).length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final mandi = nearbyMandis[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.storefront, color: AppTheme.primaryGreen, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mandi.mandi,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.near_me_outlined, size: 12, color: AppTheme.textMuted),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${mandi.distanceKm.toInt()} km • ${mandi.travelTimeHours} hrs',
                                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: AppTheme.borderSubtle)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${mandi.arrivals.toInt()} qtl',
                                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${mandi.modalPrice.toInt()}',
                              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                            ),
                            Text(
                              'Net: ₹${mandi.netRealizationPerQtl.toInt()}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 4. 📦 MY FARM STOCK & ACTIVE CROPS
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Farm Stock & Crops',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                ),
                                Text(
                                  'Manage stored godown produce & growing fields',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmStockScreen()));
                          },
                          child: const Text('View All', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Metrics Strip
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('In Storage (Godown)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  '${agri.totalStoredQuintals.toInt()} Quintals',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                                ),
                                Text(
                                  'Worth ₹${NumberFormat('#,##,###').format(agri.totalStoredProduceValue.toInt())}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Currently Growing', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  '${agri.totalGrowingAcreage % 1 == 0 ? agri.totalGrowingAcreage.toInt() : agri.totalGrowingAcreage} Acres',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                                ),
                                Text(
                                  '${agri.farmStock.where((e) => e.isGrowing).length} Active Crops',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FarmStockScreen(initialTab: 0)),
                              );
                            },
                            icon: const Icon(Icons.warehouse_outlined, size: 16),
                            label: const Text('Manage Stock'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(color: AppTheme.primaryGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FarmStockScreen()),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('+ Add Stock / Crop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 5. 🌱 RECOMMENDED CROPS FOR LOCATION
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_outlined, size: 18, color: AppTheme.accentEmerald),
                          const SizedBox(width: 6),
                          Text(
                            '🌱 Suggested Crops for $currentDistrict',
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'High-profit & climate-suited crops for your soil',
                        style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestedCrops.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final suggestion = suggestedCrops[idx];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(suggestion.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.crop,
                                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                                  ),
                                  Text(
                                    '${suggestion.localName} • Season: ${suggestion.season}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.greenBadge,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${suggestion.suitabilityScore}% Match',
                                style: const TextStyle(color: AppTheme.greenText, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          suggestion.reason,
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSand.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Expected Yield', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(suggestion.expectedYield, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Container(width: 1, height: 24, color: AppTheme.borderSubtle),
                              Column(
                                children: [
                                  const Text('Net Profit / Acre', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${NumberFormat('#,##,###').format(suggestion.projectedNetProfitPerAcre.toInt())}',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 24, color: AppTheme.borderSubtle),
                              Column(
                                children: [
                                  const Text('Duration', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                                  const SizedBox(height: 2),
                                  Text('${suggestion.durationDays} Days', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              agri.addSuggestedCropToGrowing(suggestion);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${suggestion.crop} to your Growing Fields!'),
                                  backgroundColor: AppTheme.primaryGreen,
                                  action: SnackBarAction(
                                    label: 'View Stock',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const FarmStockScreen(initialTab: 1)),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('+ Add to Currently Growing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0FDF4),
                              foregroundColor: AppTheme.primaryGreen,
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF86EFAC)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions Grid
              Text(
                lang.t('quick_actions'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _QuickToolCard(
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primaryGreen,
                    title: 'Farm Stock & Crops',
                    subtitle: 'Stored & in-field crops',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmStockScreen())),
                  ),
                  _QuickToolCard(
                    icon: Icons.calculate_outlined,
                    color: const Color(0xFF165B33),
                    title: 'Profit & MSP Calculator',
                    subtitle: 'Break-even & Govt MSP',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitCalculatorScreen())),
                  ),
                  _QuickToolCard(
                    icon: Icons.storefront,
                    color: const Color(0xFF165B33),
                    title: lang.t('nav_store'),
                    subtitle: 'Certified inputs & seeds',
                    onTap: () => onNavigateTab(3),
                  ),
                  _QuickToolCard(
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFF0369A1),
                    title: lang.t('nav_chat'),
                    subtitle: 'AI agronomist 24/7',
                    onTap: () => onNavigateTab(4),
                  ),
                  _QuickToolCard(
                    icon: Icons.landscape_outlined,
                    color: const Color(0xFF92400E),
                    title: lang.t('nav_soil'),
                    subtitle: 'Soil card analyzer',
                    onTap: () => onNavigateTab(5),
                  ),
                  _QuickToolCard(
                    icon: Icons.biotech_outlined,
                    color: const Color(0xFFBE123C),
                    title: lang.t('nav_disease'),
                    subtitle: 'Leaf pathology scan',
                    onTap: () => onNavigateTab(6),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickToolCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
