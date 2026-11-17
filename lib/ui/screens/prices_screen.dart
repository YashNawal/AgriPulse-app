import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';

class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: Text(lang.t('mandi_prices_title')),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Crop Selector Chips
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: agri.commodities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final item = agri.commodities[idx];
                final isSelected = item.id == agri.selectedCommodity;

                return ChoiceChip(
                  label: Text('${item.emoji} ${item.name}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) agri.selectCommodity(item.id);
                  },
                  selectedColor: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.cardWhite,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                    ),
                  ),
                );
              },
            ),
          ),

          // Sorting & Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${agri.mandis.length} Mandis reporting today',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: agri.mandiSort,
                  onSelected: (val) => agri.setMandiSort(val),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        agri.mandiSort == 'net_realization'
                            ? 'Net Realization'
                            : (agri.mandiSort == 'price' ? 'Modal Price' : 'Distance'),
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'net_realization',
                      child: Text('Sort by Net In-Hand Realization'),
                    ),
                    const PopupMenuItem(
                      value: 'price',
                      child: Text('Sort by Highest Gross Price'),
                    ),
                    const PopupMenuItem(
                      value: 'distance',
                      child: Text('Sort by Nearest Distance'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mandis List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: agri.mandis.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = agri.mandis[idx];
                final isTop = idx == 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isTop ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                      width: isTop ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isTop ? AppTheme.greenBadge : AppTheme.bgSand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#${idx + 1}',
                              style: TextStyle(
                                color: isTop ? AppTheme.greenText : AppTheme.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.mandi,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.district}, ${item.state} • ${item.distanceKm.toInt()} km (${item.travelTimeHours}h)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${item.modalPrice.toInt()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              const Text(
                                'per quintal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppTheme.borderSubtle),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatPill(
                            label: lang.t('min_max'),
                            value: '₹${item.minPrice.toInt()} - ₹${item.maxPrice.toInt()}',
                          ),
                          _StatPill(
                            label: lang.t('arrivals'),
                            value: '${item.arrivals.toInt()} qtl',
                          ),
                          _StatPill(
                            label: 'Net In-Hand',
                            value: '₹${item.netRealizationPerQtl.toInt()}',
                            isGreen: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen;

  const _StatPill({
    required this.label,
    required this.value,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isGreen ? AppTheme.greenText : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
