import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../providers/agri_provider.dart';
import '../theme/app_theme.dart';
import 'market_profit_arbitrage_screen.dart';

class FarmStockScreen extends StatefulWidget {
  final int initialTab;

  const FarmStockScreen({super.key, this.initialTab = 0});

  @override
  State<FarmStockScreen> createState() => _FarmStockScreenState();
}

class _FarmStockScreenState extends State<FarmStockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddStockSheet(BuildContext context, {FarmStockType defaultType = FarmStockType.harvested}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddStockBottomSheet(initialType: defaultType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final harvestedItems = agri.farmStock.where((e) => e.isHarvested).toList();
    final growingItems = agri.farmStock.where((e) => e.isGrowing).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Farm Stock & Crops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              'Stored Produce & Active In-Field Crops',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openAddStockSheet(
              context,
              defaultType: _tabController.index == 0 ? FarmStockType.harvested : FarmStockType.growing,
            ),
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen, size: 28),
            tooltip: 'Add Stock / Crop',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warehouse_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('In Storage (${harvestedItems.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Currently Growing (${growingItems.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Overview Summary Strip
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2, color: AppTheme.primaryGreen, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Stored Worth',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${NumberFormat('#,##,###').format(agri.totalStoredProduceValue.toInt())}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${agri.totalStoredQuintals.toInt()} qtl in godown',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0369A1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.grass, color: Color(0xFF0369A1), size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Active Fields',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${agri.totalGrowingAcreage % 1 == 0 ? agri.totalGrowingAcreage.toInt() : agri.totalGrowingAcreage} Acres',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${growingItems.length} active crops planted',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HarvestedStockTab(items: harvestedItems, onAddStock: () => _openAddStockSheet(context, defaultType: FarmStockType.harvested)),
                _GrowingCropsTab(items: growingItems, onAddCrop: () => _openAddStockSheet(context, defaultType: FarmStockType.growing)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddStockSheet(
          context,
          defaultType: _tabController.index == 0 ? FarmStockType.harvested : FarmStockType.growing,
        ),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? '+ Add Stored Stock' : '+ Add Growing Crop',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _HarvestedStockTab extends StatelessWidget {
  final List<FarmStockItem> items;
  final VoidCallback onAddStock;

  const _HarvestedStockTab({required this.items, required this.onAddStock});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warehouse_outlined, size: 64, color: AppTheme.borderSubtle),
              const SizedBox(height: 16),
              const Text(
                'No Stored Produce Recorded',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Record the crops you have harvested and stored in your godown or kanda chawl to track live valuations and best selling times.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddStock,
                icon: const Icon(Icons.add),
                label: const Text('Add Harvested Stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = items[idx];
        return _HarvestedStockCard(item: item);
      },
    );
  }
}

class _HarvestedStockCard extends StatelessWidget {
  final FarmStockItem item;

  const _HarvestedStockCard({required this.item});

  String _getCropEmoji(String crop) {
    final c = crop.toLowerCase();
    if (c.contains('onion')) return '🧅';
    if (c.contains('wheat')) return '🌾';
    if (c.contains('maize') || c.contains('corn')) return '🌽';
    if (c.contains('soybean')) return '🌱';
    if (c.contains('cotton')) return '☁️';
    if (c.contains('tomato')) return '🍅';
    if (c.contains('potato')) return '🥔';
    if (c.contains('banana')) return '🍌';
    if (c.contains('sugarcane')) return '🎋';
    return '📦';
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.read<AgriProvider>();
    final comm = agri.commodities.firstWhere(
      (c) => c.name.toLowerCase() == item.crop.toLowerCase() || c.id.toLowerCase() == item.crop.toLowerCase(),
      orElse: () => Commodity(id: '', name: item.crop, localName: item.crop, emoji: _getCropEmoji(item.crop), category: '', modalPrice: 2000, unit: '₹/qtl', trend: 'UP', changePct: 0),
    );

    final estimatedWorth = item.quantityQuintals * comm.modalPrice;
    final isSold = item.status == 'Sold';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSold ? Colors.grey.shade300 : AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getCropEmoji(item.crop), style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.crop,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isSold ? Colors.grey : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSold ? Colors.grey.shade100 : AppTheme.greenBadge,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isSold ? 'SOLD OUT' : 'IN GODOWN',
                                  style: TextStyle(
                                    color: isSold ? Colors.grey : AppTheme.greenText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.variety.isNotEmpty)
                            Text(
                              'Variety: ${item.variety}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                      onSelected: (val) {
                        if (val == 'sold') {
                          _showMarkSoldDialog(context, agri, item, comm.modalPrice);
                        } else if (val == 'delete') {
                          agri.deleteFarmStock(item.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (!isSold)
                          const PopupMenuItem(
                            value: 'sold',
                            child: Row(
                              children: [
                                Icon(Icons.sell_outlined, size: 18, color: AppTheme.primaryGreen),
                                SizedBox(width: 8),
                                Text('Mark as Sold'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Entry', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Key metrics row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSand.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Stock Quantity', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '${item.quantityQuintals % 1 == 0 ? item.quantityQuintals.toInt() : item.quantityQuintals} Quintals',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.borderSubtle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Valuation', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${NumberFormat('#,##,###').format(estimatedWorth.toInt())}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      item.storageLocation,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Stored ${DateFormat('dd MMM yyyy').format(item.storageDate)}',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),

                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      '💡 ${item.notes}',
                      style: TextStyle(fontSize: 11.5, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (!isSold)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                border: Border(top: BorderSide(color: Color(0xFFDCFCE7))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Rate: ₹${comm.modalPrice.toInt()}/qtl (${comm.trend == 'UP' ? '+' : ''}${comm.changePct}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MarketProfitArbitrageScreen(
                            initialCrop: item.crop,
                            initialQuantity: item.quantityQuintals,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calculate_outlined, size: 14),
                    label: const Text('Check Profit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentEmerald,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMarkSoldDialog(context, agri, item, comm.modalPrice),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Mark Sold'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showMarkSoldDialog(BuildContext context, AgriProvider agri, FarmStockItem item, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sell ${item.crop} Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selling ${item.quantityQuintals} Quintals of ${item.crop} (${item.variety}).'),
            const SizedBox(height: 12),
            const Text('Realized Price (₹/Quintal):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text) ?? currentPrice;
              agri.markStockSold(item.id, price);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marked ${item.crop} as Sold at ₹${price.toInt()}/qtl!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Confirm Sale'),
          ),
        ],
      ),
    );
  }
}

class _GrowingCropsTab extends StatelessWidget {
  final List<FarmStockItem> items;
  final VoidCallback onAddCrop;

  const _GrowingCropsTab({required this.items, required this.onAddCrop});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_outlined, size: 64, color: AppTheme.borderSubtle),
              const SizedBox(height: 16),
              const Text(
                'No In-Ground Crops Added',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track what you are currently cultivating in your fields — monitor growth stages, days elapsed, and projected harvest yields.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddCrop,
                icon: const Icon(Icons.add),
                label: const Text('Add Currently Growing Crop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = items[idx];
        return _GrowingCropCard(item: item);
      },
    );
  }
}

class _GrowingCropCard extends StatelessWidget {
  final FarmStockItem item;

  const _GrowingCropCard({required this.item});

  String _getCropEmoji(String crop) {
    final c = crop.toLowerCase();
    if (c.contains('onion')) return '🧅';
    if (c.contains('wheat')) return '🌾';
    if (c.contains('maize') || c.contains('corn')) return '🌽';
    if (c.contains('soybean')) return '🌱';
    if (c.contains('cotton')) return '☁️';
    if (c.contains('tomato')) return '🍅';
    if (c.contains('banana')) return '🍌';
    if (c.contains('sugarcane')) return '🎋';
    return '🌱';
  }

  double _calculateProgress(DateTime sowing, DateTime harvest) {
    final totalDays = harvest.difference(sowing).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsed = DateTime.now().difference(sowing).inDays;
    return (elapsed / totalDays).clamp(0.05, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.read<AgriProvider>();
    final progress = _calculateProgress(item.sowingDate, item.expectedHarvestDate);
    final daysElapsed = DateTime.now().difference(item.sowingDate).inDays;
    final daysRemaining = item.expectedHarvestDate.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getCropEmoji(item.crop), style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.crop,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.acreage % 1 == 0 ? item.acreage.toInt() : item.acreage} ACRES',
                                  style: const TextStyle(
                                    color: Color(0xFF0369A1),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.variety.isNotEmpty)
                            Text(
                              'Cultivar: ${item.variety}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                      onSelected: (val) {
                        if (val == 'harvest') {
                          _harvestToStorage(context, agri, item);
                        } else if (val == 'stage') {
                          _showUpdateStageDialog(context, agri, item);
                        } else if (val == 'delete') {
                          agri.deleteFarmStock(item.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'stage',
                          child: Row(
                            children: [
                              Icon(Icons.upgrade, size: 18, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text('Update Growth Stage'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'harvest',
                          child: Row(
                            children: [
                              Icon(Icons.inventory, size: 18, color: Color(0xFF0369A1)),
                              SizedBox(width: 8),
                              Text('Harvest to Storage'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Entry', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Growth progress & stage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stage: ${item.stage}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                    ),
                    Text(
                      'Day $daysElapsed (${(progress * 100).toInt()}% Done)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),

                const SizedBox(height: 14),

                // Metrics row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSand.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sowing Date', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMM yyyy').format(item.sowingDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 26, color: AppTheme.borderSubtle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expected Harvest', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('dd MMM').format(item.expectedHarvestDate)} (${daysRemaining > 0 ? '$daysRemaining days' : 'Ready!'})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (item.expectedYieldQuintals > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, size: 14, color: AppTheme.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Projected Total Yield: ${item.expectedYieldQuintals % 1 == 0 ? item.expectedYieldQuintals.toInt() : item.expectedYieldQuintals} Quintals',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                ],

                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '📝 ${item.notes}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          // Action row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              border: Border(top: BorderSide(color: Color(0xFFDCFCE7))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showUpdateStageDialog(context, agri, item),
                  icon: const Icon(Icons.arrow_circle_up, size: 16, color: AppTheme.primaryGreen),
                  label: const Text('Update Stage', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
                ),
                ElevatedButton.icon(
                  onPressed: () => _harvestToStorage(context, agri, item),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Harvest to Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _harvestToStorage(BuildContext context, AgriProvider agri, FarmStockItem item) {
    final yieldController = TextEditingController(
      text: (item.expectedYieldQuintals > 0 ? item.expectedYieldQuintals : item.acreage * 25).toInt().toString(),
    );
    final locationController = TextEditingController(text: 'Kanda Chawl / Farm Godown');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Harvest ${item.crop}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Congratulations on harvesting ${item.acreage} acres of ${item.crop}!'),
            const SizedBox(height: 14),
            const Text('Harvested Quantity (Quintals):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: yieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, suffixText: 'qtl'),
            ),
            const SizedBox(height: 12),
            const Text('Storage Location:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(yieldController.text) ?? 50.0;
              // 1. Add harvested item
              agri.addFarmStock(
                FarmStockItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  crop: item.crop,
                  variety: item.variety,
                  type: FarmStockType.harvested,
                  quantityQuintals: qty,
                  storageLocation: locationController.text.trim().isNotEmpty ? locationController.text.trim() : 'Farm Godown',
                  storageDate: DateTime.now(),
                  notes: 'Harvested from ${item.acreage} acres sown on ${DateFormat('dd MMM').format(item.sowingDate)}.',
                  status: 'In Storage',
                ),
              );
              // 2. Delete or complete growing item
              agri.deleteFarmStock(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully harvested ${qty.toInt()} qtl into storage!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Move to Storage'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStageDialog(BuildContext context, AgriProvider agri, FarmStockItem item) {
    final stages = [
      'Sowing / Germination',
      'Vegetative (Knee-high)',
      'Flowering & Pollination',
      'Bulb / Pod Formation',
      'Maturity / Ready to Harvest',
    ];
    String selectedStage = stages.contains(item.stage) ? item.stage : stages[1];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update ${item.crop} Stage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select current crop development stage:', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 12),
              ...stages.map(
                (s) => InkWell(
                  onTap: () => setDialogState(() => selectedStage = s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          selectedStage == s ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selectedStage == s ? AppTheme.primaryGreen : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: selectedStage == s ? FontWeight.w700 : FontWeight.w500,
                            color: selectedStage == s ? AppTheme.primaryGreen : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                agri.updateFarmStock(item.copyWith(stage: selectedStage));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Save Stage'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddStockBottomSheet extends StatefulWidget {
  final FarmStockType initialType;

  const _AddStockBottomSheet({required this.initialType});

  @override
  State<_AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<_AddStockBottomSheet> {
  late FarmStockType _selectedType;
  String _selectedCrop = 'Onion';
  final _varietyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _storageLocationController = TextEditingController(text: 'Kanda Chawl (Aerated)');
  final _acreageController = TextEditingController(text: '2.0');
  final _expectedYieldController = TextEditingController(text: '50.0');
  final _notesController = TextEditingController();
  String _selectedStage = 'Vegetative';

  final List<String> _crops = [
    'Onion',
    'Wheat',
    'Maize',
    'Soybean',
    'Cotton',
    'Tomato',
    'Potato',
    'Banana',
    'Sugarcane',
    'Tur / Arhar',
    'Chana / Gram',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _varietyController.dispose();
    _quantityController.dispose();
    _storageLocationController.dispose();
    _acreageController.dispose();
    _expectedYieldController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.read<AgriProvider>();

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Crop or Farm Stock',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = FarmStockType.harvested),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == FarmStockType.harvested ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '📦 In Storage (Harvested)',
                          style: TextStyle(
                            color: _selectedType == FarmStockType.harvested ? Colors.white : AppTheme.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = FarmStockType.growing),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == FarmStockType.growing ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🌱 In Field (Growing)',
                          style: TextStyle(
                            color: _selectedType == FarmStockType.growing ? Colors.white : AppTheme.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Crop Dropdown
            const Text('Crop', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCrop = val);
              },
            ),

            const SizedBox(height: 14),

            // Variety Field
            const Text('Variety / Seed Name', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _varietyController,
              decoration: InputDecoration(
                hintText: 'e.g. Garva, Lokwan, Pioneer 3396',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            if (_selectedType == FarmStockType.harvested) ...[
              // Stored fields
              const Text('Quantity in Godown (Quintals)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 100',
                  suffixText: 'Quintals',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Storage Location', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _storageLocationController,
                decoration: InputDecoration(
                  hintText: 'e.g. Kanda Chawl, Farm Godown, Cold Store',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ] else ...[
              // Growing fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Area (Acres)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _acreageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2.5',
                            suffixText: 'Acres',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exp. Yield (Qtl)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _expectedYieldController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 60',
                            suffixText: 'Qtl',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Current Growth Stage', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedStage,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Sowing / Germination', child: Text('Sowing / Germination')),
                  DropdownMenuItem(value: 'Vegetative', child: Text('Vegetative Stage')),
                  DropdownMenuItem(value: 'Flowering', child: Text('Flowering / Bloom')),
                  DropdownMenuItem(value: 'Bulb / Pod Formation', child: Text('Bulb / Pod Formation')),
                  DropdownMenuItem(value: 'Maturity', child: Text('Maturity / Ready to Harvest')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStage = val);
                },
              ),
            ],

            const SizedBox(height: 14),
            const Text('Notes (Optional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'e.g. Graded quality, sprayed micronutrients',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final variety = _varietyController.text.trim();
                  final notes = _notesController.text.trim();

                  if (_selectedType == FarmStockType.harvested) {
                    final qty = double.tryParse(_quantityController.text) ?? 50.0;
                    final loc = _storageLocationController.text.trim();

                    agri.addFarmStock(
                      FarmStockItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        crop: _selectedCrop,
                        variety: variety,
                        type: FarmStockType.harvested,
                        quantityQuintals: qty,
                        storageLocation: loc.isNotEmpty ? loc : 'Farm Godown',
                        storageDate: DateTime.now(),
                        notes: notes,
                        status: 'In Storage',
                      ),
                    );
                  } else {
                    final acreage = double.tryParse(_acreageController.text) ?? 1.5;
                    final yieldQtl = double.tryParse(_expectedYieldController.text) ?? 30.0;

                    agri.addFarmStock(
                      FarmStockItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        crop: _selectedCrop,
                        variety: variety,
                        type: FarmStockType.growing,
                        acreage: acreage,
                        sowingDate: DateTime.now().subtract(const Duration(days: 15)),
                        stage: _selectedStage,
                        expectedHarvestDate: DateTime.now().add(const Duration(days: 75)),
                        expectedYieldQuintals: yieldQtl,
                        notes: notes,
                        status: 'Growing',
                      ),
                    );
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $_selectedCrop to your farm stock!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedType == FarmStockType.harvested ? 'Save Harvested Stock' : 'Save Growing Crop',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
