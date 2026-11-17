import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/services/location_service.dart';
import '../../data/services/maharashtra_location_data.dart';
import '../../providers/agri_provider.dart';
import '../theme/app_theme.dart';

class MarketProfitArbitrageScreen extends StatefulWidget {
  final String? initialCrop;
  final double? initialQuantity;

  const MarketProfitArbitrageScreen({
    super.key,
    this.initialCrop,
    this.initialQuantity,
  });

  @override
  State<MarketProfitArbitrageScreen> createState() => _MarketProfitArbitrageScreenState();
}

class _MarketProfitArbitrageScreenState extends State<MarketProfitArbitrageScreen> {
  late String _selectedCrop;
  late double _quantityQuintals;
  late TextEditingController _qtyController;
  late String _selectedDistrict;
  String? _selectedVehicleId;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final List<({String name, String localName, String emoji})> _popularCrops = [
    (name: 'Onion', localName: 'कांदा (Onion)', emoji: '🧅'),
    (name: 'Wheat', localName: 'गहू (Wheat)', emoji: '🌾'),
    (name: 'Maize', localName: 'मका (Maize)', emoji: '🌽'),
    (name: 'Soybean', localName: 'सोयाबीन (Soybean)', emoji: '🌱'),
    (name: 'Cotton', localName: 'कापूस (Cotton)', emoji: '☁️'),
    (name: 'Tomato', localName: 'टोमॅटो (Tomato)', emoji: '🍅'),
    (name: 'Potato', localName: 'बटाटा (Potato)', emoji: '🥔'),
    (name: 'Gram', localName: 'हरभरा (Gram/Chana)', emoji: '🟤'),
    (name: 'Tur', localName: 'तूर डाळ (Tur Dal)', emoji: '🍲'),
    (name: 'Garlic', localName: 'लसूण (Garlic)', emoji: '🧄'),
    (name: 'Banana', localName: 'केळी (Banana)', emoji: '🍌'),
    (name: 'Pomegranate', localName: 'डाळिंब (Pomegranate)', emoji: '🍎'),
    (name: 'Grapes', localName: 'द्राक्षे (Grapes)', emoji: '🍇'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCrop = widget.initialCrop ?? 'Onion';
    _quantityQuintals = widget.initialQuantity ?? 45.0;
    _qtyController = TextEditingController(text: _quantityQuintals.toStringAsFixed(0));
    _selectedDistrict = 'Nashik'; // Will update from provider in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final agri = Provider.of<AgriProvider>(context, listen: false);
    final farmer = agri.currentFarmer;
    if (farmer != null && farmer.district.isNotEmpty) {
      // If user hasn't modified, default to profile district
      if (_selectedDistrict == 'Nashik' && farmer.district != 'Nashik') {
        _selectedDistrict = farmer.district;
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(double newQty) {
    setState(() {
      _quantityQuintals = newQty.clamp(1.0, 1000.0);
      _qtyController.text = _quantityQuintals.toStringAsFixed(0);
    });
  }

  void _openDistrictPicker(BuildContext context) {
    final districts = MaharashtraLocationData.districts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = districts
                .where((d) => d.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Select Your Origin District',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search district (e.g. Dhule, Pune, Latur)...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgSand,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        setModalState(() => searchQuery = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        final isSelected = d.toLowerCase() == _selectedDistrict.toLowerCase();
                        return ListTile(
                          title: Text(
                            d,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                              : null,
                          onTap: () {
                            setState(() => _selectedDistrict = d);
                            Navigator.pop(ctx);
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

  void _openVehiclePicker(BuildContext context, TransportVehicleOption currentVehicle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Transportation Vehicle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Freight rates include driver, fuel & road toll estimates.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              ...LocationService.transportVehicles.map((v) {
                final isSelected = v.id == currentVehicle.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.bgSand,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Text(v.icon, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      v.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    subtitle: Text('${v.capacityLabel} • ₹${v.ratePerKm.toInt()}/km (Min ₹${v.minCost.toInt()})'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                        : null,
                    onTap: () {
                      setState(() => _selectedVehicleId = v.id);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();

    // Compute arbitrage dynamically
    final analysis = agri.calculateMarketArbitrage(
      crop: _selectedCrop,
      quantityQuintals: _quantityQuintals,
      originDistrict: _selectedDistrict,
      vehicleId: _selectedVehicleId,
    );

    final vehicle = _selectedVehicleId != null
        ? LocationService.transportVehicles.firstWhere(
            (v) => v.id == _selectedVehicleId,
            orElse: () => LocationService.autoSuggestVehicle(_quantityQuintals),
          )
        : LocationService.autoSuggestVehicle(_quantityQuintals);

    // Harvested stock items from farmer's godown
    final matchingStockItems = agri.farmStock.where((s) => s.isHarvested).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: const Text(
          'Crop Arbitrage & Profit Finder',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'How Arbitrage Works',
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
            onPressed: () => _showArbitrageExplanationDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 🌾 SECTION 1: CROP & VOLUME SEARCH CONTROLS
            // ==========================================
            _buildSearchControlsCard(context, agri, matchingStockItems, vehicle),
            const SizedBox(height: 16),

            // ==========================================
            // 🚀 SECTION 2: "WHERE YOU HAVE PROFIT" HERO CARD
            // ==========================================
            _buildDecisionHeroBanner(analysis),
            const SizedBox(height: 16),

            // ==========================================
            // ⚖️ SECTION 3: SIDE-BY-SIDE MANDI COMPARISON
            // ==========================================
            _buildSideBySideComparison(analysis),
            const SizedBox(height: 20),

            // ==========================================
            // 📊 SECTION 4: ALL RANKED MANDIS BREAKDOWN
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Mandis Ranked by Net Profit',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.greenBadge,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${analysis.allMarketsRanked.length} Mandis',
                    style: const TextStyle(
                      color: AppTheme.greenText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Net Profit in your hand after deducting truck freight, mandi cess & transit loss.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),

            ...analysis.allMarketsRanked.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final result = entry.value;
              return _buildMandiRankCard(context, rank, result, analysis);
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildSearchControlsCard(
    BuildContext context,
    AgriProvider agri,
    List<FarmStockItem> stockItems,
    TransportVehicleOption vehicle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location & Crop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR CROP & LOCATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppTheme.textMuted,
                ),
              ),
              InkWell(
                onTap: () => _openDistrictPicker(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        '$_selectedDistrict APMC',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Crop Selector Horizontal Carousel
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _popularCrops.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final c = _popularCrops[index];
                final isSelected = c.name.toLowerCase() == _selectedCrop.toLowerCase();
                return ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.bgSand,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _selectedCrop = c.name);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Quantity Input & Presets
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crop Quantity You Have',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter total yield ready to sell',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 140,
                decoration: BoxDecoration(
                  color: AppTheme.bgSand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 10.0;
                          setState(() => _quantityQuintals = parsed.clamp(1.0, 1000.0));
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 12),
                      child: const Text(
                        'Qtl',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quantity Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryGreen,
              inactiveTrackColor: AppTheme.borderSubtle,
              thumbColor: AppTheme.primaryGreen,
              overlayColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: _quantityQuintals.clamp(5.0, 250.0),
              min: 5.0,
              max: 250.0,
              divisions: 49,
              label: '${_quantityQuintals.toInt()} Qtl',
              onChanged: _onQuantityChanged,
            ),
          ),

          // Quick Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [10, 25, 50, 100].map((q) {
              return InkWell(
                onTap: () => _onQuantityChanged(q.toDouble()),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _quantityQuintals == q ? AppTheme.primaryGreen : AppTheme.bgSand,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _quantityQuintals == q ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Text(
                    '+$q Qtl',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _quantityQuintals == q ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Autofill from Farmer's Godown Stock
          if (stockItems.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primaryGreen),
                      SizedBox(width: 6),
                      Text(
                        'Autofill from Your Farm Storage (Godown):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: stockItems.map((stock) {
                      return ActionChip(
                        avatar: const Text('📦', style: TextStyle(fontSize: 14)),
                        label: Text(
                          '${stock.quantityQuintals.toInt()} Qtl ${stock.crop}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF86EFAC)),
                        onPressed: () {
                          setState(() {
                            _selectedCrop = stock.crop;
                            _quantityQuintals = stock.quantityQuintals;
                            _qtyController.text = stock.quantityQuintals.toStringAsFixed(0);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Loaded ${stock.quantityQuintals.toInt()} Qtl ${stock.crop} from ${stock.storageLocation}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 24, color: AppTheme.borderSubtle),

          // Selected Vehicle Row
          InkWell(
            onTap: () => _openVehiclePicker(context, vehicle),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgSand,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Text(vehicle.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transport Vehicle: ${vehicle.name}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          '${vehicle.capacityLabel} • ₹${vehicle.ratePerKm.toInt()}/km',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Icon(Icons.unfold_more, size: 14, color: AppTheme.primaryGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionHeroBanner(ArbitrageAnalysis analysis) {
    final shouldTravel = analysis.shouldTravel;
    final gainAmount = analysis.netGainAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: shouldTravel
              ? [const Color(0xFF065F46), const Color(0xFF047857), const Color(0xFF059669)]
              : [const Color(0xFF9A3412), const Color(0xFFC2410C), const Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (shouldTravel ? const Color(0xFF059669) : const Color(0xFFEA580C)).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  shouldTravel ? Icons.trending_up : Icons.store_mall_directory,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shouldTravel
                          ? 'TRAVEL RECOMMENDED: HIGHER NET PROFIT'
                          : 'SELL LOCALLY: HIGHEST IN-HAND PROFIT',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      shouldTravel
                          ? '+${currencyFormat.format(gainAmount)} Extra In-Hand Cash'
                          : 'Keep Full Margin at Local APMC',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              analysis.recommendation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('Local Mandi', analysis.localMarket.mandi.split('(').first.trim()),
              _buildHeroStat('Top Realization', analysis.bestNetMarket.mandi.split('(').first.trim()),
              _buildHeroStat('Net Realization', '₹${analysis.bestNetMarket.netRealizationPerQtl.toInt()}/qtl'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildSideBySideComparison(ArbitrageAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Side-by-Side Market Comparison',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Local Market Card
            Expanded(
              child: _buildComparisonMarketCard(
                tag: '📍 MARKET NEAR YOU',
                tagBg: AppTheme.blueBadge,
                tagColor: AppTheme.blueText,
                mandi: analysis.localMarket,
                isHighlighted: !analysis.shouldTravel,
              ),
            ),
            const SizedBox(width: 10),
            // Best Net Profit Market Card
            Expanded(
              child: _buildComparisonMarketCard(
                tag: analysis.shouldTravel ? '🏆 BEST PROFIT MANDI' : 'HIGHEST GROSS PRICE',
                tagBg: analysis.shouldTravel ? AppTheme.greenBadge : AppTheme.amberBadge,
                tagColor: analysis.shouldTravel ? AppTheme.greenText : AppTheme.amberText,
                mandi: analysis.shouldTravel ? analysis.bestNetMarket : analysis.highestGrossMarket,
                isHighlighted: analysis.shouldTravel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonMarketCard({
    required String tag,
    required Color tagBg,
    required Color tagColor,
    required MarketArbitrageResult mandi,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted ? AppTheme.primaryGreen : AppTheme.borderSubtle,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: tagColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mandi.mandi,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          Text(
            '${mandi.distanceKm.toInt()} km • ${mandi.travelTimeHours} hrs',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const Divider(height: 16, color: AppTheme.borderSubtle),
          _buildCompactRow('Modal Price', '₹${mandi.modalPrice.toInt()}/qtl'),
          _buildCompactRow('Gross Cash', currencyFormat.format(mandi.grossRevenue)),
          _buildCompactRow('Truck Freight', '-${currencyFormat.format(mandi.transportCost)}'),
          _buildCompactRow('Mandi Fee/Cess', '-${currencyFormat.format(mandi.apmcFee)}'),
          const Divider(height: 12, color: AppTheme.borderSubtle),
          _buildCompactRow(
            'Net In-Hand',
            currencyFormat.format(mandi.netProfit),
            isBold: true,
            valColor: isHighlighted ? AppTheme.primaryGreen : AppTheme.textDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRow(String label, String value, {bool isBold = false, Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isBold ? AppTheme.textDark : AppTheme.textMuted,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiRankCard(
    BuildContext context,
    int rank,
    MarketArbitrageResult mandi,
    ArbitrageAnalysis analysis,
  ) {
    final diffVsLocal = mandi.profitDiffVsLocal;
    final isLocal = mandi.isLocal;
    final isBestNet = mandi.isBestNetProfit;
    final isHighestGross = mandi.isHighestGross;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBestNet
              ? AppTheme.accentEmerald
              : (isLocal ? const Color(0xFF93C5FD) : AppTheme.borderSubtle),
          width: (isBestNet || isLocal) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Rank & Tags
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isBestNet
                      ? AppTheme.accentEmerald
                      : (isLocal ? AppTheme.blueText : AppTheme.bgSand),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: (isBestNet || isLocal) ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mandi.mandi,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${mandi.district}, ${mandi.state} • ${mandi.distanceKm.toInt()} km from $_selectedDistrict',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${mandi.modalPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const Text('₹/qtl modal', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chips Badges
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (isBestNet)
                _buildBadge('⭐ BEST IN-HAND PROFIT', AppTheme.greenBadge, AppTheme.greenText),
              if (isLocal)
                _buildBadge('📍 LOCAL MANDI NEAR YOU', AppTheme.blueBadge, AppTheme.blueText),
              if (isHighestGross && !isBestNet)
                _buildBadge('🏆 HIGHEST GROSS PRICE', AppTheme.amberBadge, AppTheme.amberText),
              if (mandi.isDirectFarmMarket)
                _buildBadge('🌱 0% APMC CESS DIRECT', const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
            ],
          ),
          const SizedBox(height: 12),

          // Financial Breakdown Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgSand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Gross Revenue (${_quantityQuintals.toInt()} Qtl @ ₹${mandi.modalPrice.toInt()})',
                  currencyFormat.format(mandi.grossRevenue),
                ),
                _buildDetailRow(
                  'Truck Freight (${mandi.distanceKm.toInt()} km, ${analysis.vehicleType.split('(').first})',
                  '- ${currencyFormat.format(mandi.transportCost)}',
                  textColor: Colors.red.shade700,
                ),
                _buildDetailRow(
                  'APMC Cess & Transit Shrinkage',
                  '- ${currencyFormat.format(mandi.apmcFee + mandi.transitLoss)}',
                  textColor: Colors.red.shade700,
                ),
                const Divider(height: 10, color: AppTheme.borderSubtle),
                _buildDetailRow(
                  'Total Net Profit In-Hand Cash',
                  currencyFormat.format(mandi.netProfit),
                  isBold: true,
                  textColor: AppTheme.primaryGreen,
                  fontSize: 13,
                ),
                _buildDetailRow(
                  'Net Realization per Quintal',
                  '₹${mandi.netRealizationPerQtl.toInt()}/qtl',
                  textColor: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Relative Gain vs Local
          if (!isLocal) ...[
            Row(
              children: [
                Icon(
                  diffVsLocal >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: diffVsLocal >= 0 ? AppTheme.accentEmerald : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  diffVsLocal >= 0
                      ? '+${currencyFormat.format(diffVsLocal)} (+${mandi.profitPctVsLocal.toStringAsFixed(1)}%) more net profit than selling locally'
                      : '-${currencyFormat.format(diffVsLocal.abs())} less profit than local due to high transport freight',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: diffVsLocal >= 0 ? AppTheme.greenText : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Action Buttons: Directions on Google Maps + Phone Call
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions, size: 16, color: AppTheme.primaryGreen),
                  label: const Text('Directions (Maps)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final originCoord = MaharashtraLocationData.getDistrictCoordinates(_selectedDistrict);
                    LocationService.instance.launchGoogleMapsNavigation(
                      destinationLat: mandi.lat,
                      destinationLon: mandi.lon,
                      destinationTitle: mandi.mandi,
                      originLat: originCoord.lat,
                      originLon: originCoord.lon,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (mandi.contactPhone.isNotEmpty)
                IconButton(
                  tooltip: 'Call Mandi Office',
                  icon: const Icon(Icons.phone, color: AppTheme.primaryGreen, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    LocationService.instance.launchCallPhone(mandi.contactPhone);
                  },
                ),
              IconButton(
                tooltip: 'Share Profit Calculation',
                icon: const Icon(Icons.share, color: AppTheme.textDark, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.bgSand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _shareArbitrageDetails(mandi, analysis);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String val, {
    bool isBold = false,
    Color? textColor,
    double fontSize = 11,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: isBold ? AppTheme.textDark : AppTheme.textMuted,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _shareArbitrageDetails(MarketArbitrageResult mandi, ArbitrageAnalysis analysis) {
    final text = '''
🌾 *KisanMitra Crop Profit & Arbitrage Report*
Crop: $_selectedCrop (${_quantityQuintals.toInt()} Qtl)
Origin: $_selectedDistrict

📍 *${mandi.mandi}* (${mandi.distanceKm.toInt()} km)
• Modal Price: ₹${mandi.modalPrice.toInt()}/qtl
• Gross Cash: ${currencyFormat.format(mandi.grossRevenue)}
• Transport Freight: -${currencyFormat.format(mandi.transportCost)}
• Mandi Fee: -${currencyFormat.format(mandi.apmcFee)}
• *Net In-Hand Profit: ${currencyFormat.format(mandi.netProfit)}* (₹${mandi.netRealizationPerQtl.toInt()}/qtl)
${!mandi.isLocal ? '• Extra Gain vs Local: +${currencyFormat.format(mandi.profitDiffVsLocal)}' : '• (Local Mandi)'}

Calculated with KisanMitra AI 🚀
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Market breakdown copied to clipboard! Ready to share on WhatsApp.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showArbitrageExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('How Arbitrage Works', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What is Price Arbitrage?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Different APMC mandis offer different prices for the exact same crop. For example, Mumbai (Vashi) and Pune APMCs often pay ₹300-₹500 more per quintal than local district markets due to urban demand.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  'Why Quantity Matters:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '• Small Volume (e.g. 10 Qtl): Hiring a truck for 200 km costs ₹5,000+. The extra price you get is only ₹3,000. So traveling causes a net loss! Sell locally.\n• Large Volume (e.g. 60 Qtl): A truck costs ₹8,000, but you get ₹20,000 extra gross revenue! Net extra profit: ₹12,000 in your pocket.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  'Formula Used:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Net In-Hand Profit = (Quantity × Modal Price) - (Truck Distance × Rate/km) - Mandi Cess - Transit Handling Loss.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got It', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }
}
