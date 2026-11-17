import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agri_provider.dart';
import '../theme/app_theme.dart';

class CropMspProfile {
  final String id;
  final String name;
  final String localName;
  final String category;
  final double defaultCost;
  final double defaultYield;
  final double modalPrice;
  final double? msp;

  const CropMspProfile({
    required this.id,
    required this.name,
    required this.localName,
    required this.category,
    required this.defaultCost,
    required this.defaultYield,
    required this.modalPrice,
    this.msp,
  });
}

const List<CropMspProfile> kCropsWithMsp = [
  CropMspProfile(id: 'wheat', name: 'Wheat', localName: 'गहू', category: 'Grain', defaultCost: 19000, defaultYield: 22, modalPrice: 2450, msp: 2275),
  CropMspProfile(id: 'soybean', name: 'Soybean', localName: 'सोयाबीन', category: 'Oilseed', defaultCost: 16000, defaultYield: 12, modalPrice: 4620, msp: 4600),
  CropMspProfile(id: 'cotton', name: 'Cotton', localName: 'कापूस', category: 'Fiber', defaultCost: 28000, defaultYield: 10, modalPrice: 7150, msp: 7020),
  CropMspProfile(id: 'mustard', name: 'Mustard', localName: 'मोहरी', category: 'Oilseed', defaultCost: 12000, defaultYield: 9, modalPrice: 5800, msp: 5650),
  CropMspProfile(id: 'gram', name: 'Chickpea / Gram', localName: 'हरभरा', category: 'Pulse', defaultCost: 14000, defaultYield: 11, modalPrice: 5600, msp: 5440),
  CropMspProfile(id: 'onion', name: 'Onion', localName: 'कांदा', category: 'Vegetable', defaultCost: 24000, defaultYield: 25, modalPrice: 1850),
  CropMspProfile(id: 'tomato', name: 'Tomato', localName: 'टोमॅटो', category: 'Vegetable', defaultCost: 52000, defaultYield: 160, modalPrice: 1400),
  CropMspProfile(id: 'potato', name: 'Potato', localName: 'बटाटा', category: 'Vegetable', defaultCost: 35000, defaultYield: 90, modalPrice: 1650),
  CropMspProfile(id: 'garlic', name: 'Garlic', localName: 'लसूण', category: 'Spice', defaultCost: 42000, defaultYield: 40, modalPrice: 13800),
  CropMspProfile(id: 'ginger', name: 'Ginger', localName: 'आले', category: 'Spice', defaultCost: 68000, defaultYield: 90, modalPrice: 8600),
];

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  late CropMspProfile _selectedCrop;
  double _areaAcres = 2.0;
  late double _costPerAcre;
  late double _yieldPerAcre;
  late double _sellingPrice;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _selectedCrop = kCropsWithMsp[0];
    _costPerAcre = _selectedCrop.defaultCost;
    _yieldPerAcre = _selectedCrop.defaultYield;
    _sellingPrice = _selectedCrop.modalPrice;
  }

  void _onCropChanged(CropMspProfile crop) {
    setState(() {
      _selectedCrop = crop;
      _costPerAcre = crop.defaultCost;
      _yieldPerAcre = crop.defaultYield;
      _sellingPrice = crop.modalPrice;
      _isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();

    // Math calculations
    final totalYieldQtl = _areaAcres * _yieldPerAcre;
    final totalCost = _areaAcres * _costPerAcre;
    final grossRevenue = totalYieldQtl * _sellingPrice;
    final netProfit = grossRevenue - totalCost;
    final profitPerAcre = netProfit / (_areaAcres > 0 ? _areaAcres : 1);
    final breakEvenPrice = totalCost / (totalYieldQtl > 0 ? totalYieldQtl : 1);
    final hasMsp = _selectedCrop.msp != null;
    final mspDiff = hasMsp ? _sellingPrice - _selectedCrop.msp! : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: const Text('Profit & MSP Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PHASE A6: FARM ECONOMICS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${_areaAcres.toStringAsFixed(1)} Acres Selected',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Net In-Hand Revenue & Price Floor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Calculate break-even cost recovery and benchmark against Central Govt Minimum Support Price (MSP).',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Inputs Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Target Crop',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CropMspProfile>(
                    initialValue: _selectedCrop,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    items: kCropsWithMsp.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} (${c.localName}) ${c.msp != null ? "• MSP ₹${c.msp!.toInt()}" : "• No MSP"}', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _onCropChanged(val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Area Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cultivated Land Area', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${_areaAcres.toStringAsFixed(1)} Acres', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                    ],
                  ),
                  Slider(
                    value: _areaAcres,
                    min: 0.5,
                    max: 20.0,
                    divisions: 39,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (v) => setState(() => _areaAcres = v),
                  ),

                  const SizedBox(height: 10),

                  // Cost per acre input
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cost / Acre (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: _costPerAcre.toInt().toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                              onChanged: (v) => setState(() => _costPerAcre = double.tryParse(v) ?? _costPerAcre),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Yield / Acre (qtl)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: _yieldPerAcre.toInt().toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                              onChanged: (v) => setState(() => _yieldPerAcre = double.tryParse(v) ?? _yieldPerAcre),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Expected Selling Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expected Selling Price (₹ / quintal)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                      const SizedBox(height: 4),
                      TextFormField(
                        initialValue: _sellingPrice.toInt().toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        onChanged: (v) => setState(() => _sellingPrice = double.tryParse(v) ?? _sellingPrice),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financial Outcome Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: netProfit >= 0 ? AppTheme.borderSubtle : const Color(0xFFFECDD3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Financial Outcome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: netProfit >= 0 ? AppTheme.greenBadge : AppTheme.roseBadge,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          netProfit >= 0 ? 'PROFITABLE HARVEST' : 'LOSS WARNING',
                          style: TextStyle(
                            color: netProfit >= 0 ? AppTheme.greenText : AppTheme.roseText,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Net Profit', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(
                            '₹${netProfit.toInt()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: netProfit >= 0 ? AppTheme.primaryGreen : AppTheme.roseText,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Net Profit / Acre', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(
                            '₹${profitPerAcre.toInt()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: netProfit >= 0 ? AppTheme.accentEmerald : AppTheme.roseText,
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
                      _MiniMetric(label: 'Total Harvest', value: '${totalYieldQtl.toStringAsFixed(1)} qtl'),
                      _MiniMetric(label: 'Total Outflow', value: '₹${totalCost.toInt()}'),
                      _MiniMetric(label: 'Gross Revenue', value: '₹${grossRevenue.toInt()}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Break-Even Price Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.blueBadge,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.blueText, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cost Recovery Break-Even Rate',
                          style: TextStyle(color: AppTheme.blueText, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '₹${breakEvenPrice.toStringAsFixed(1)} / quintal',
                          style: const TextStyle(color: AppTheme.blueText, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Minimum mandi price needed to recover seed, fertilizer and labor expenditures.',
                          style: TextStyle(color: AppTheme.textDark, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // MSP Comparison Card (Only when crop has an MSP!)
            if (hasMsp)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Govt MSP Floor Comparison', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.greenBadge,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('MSP: ₹${_selectedCrop.msp!.toInt()}/qtl', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.greenText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mspDiff >= 0
                          ? 'Expected rate (₹${_sellingPrice.toInt()}) is +₹${mspDiff.toInt()}/qtl (+${((mspDiff / _selectedCrop.msp!) * 100).toStringAsFixed(1)}%) ABOVE the Government MSP floor. Private APMC mandi auction is favorable.'
                          : 'Market price is ₹${mspDiff.abs().toInt()}/qtl below MSP. We advise selling at a government FCI / NAFED procurement center.',
                      style: TextStyle(
                        fontSize: 12,
                        color: mspDiff >= 0 ? AppTheme.greenText : AppTheme.roseText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  '${_selectedCrop.name} has no Government MSP floor. Pricing is determined by free wholesale APMC auction supply and demand.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),

            const SizedBox(height: 18),

            // Save to Supabase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await agri.saveCropPlanToSupabase(
                    cropName: _selectedCrop.name,
                    areaAcres: _areaAcres,
                    costOfCultivation: _costPerAcre,
                    expectedYieldQuintal: _yieldPerAcre,
                  );
                  setState(() => _isSaved = true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.primaryGreen,
                        content: Text('Plan saved to your Supabase profile successfully!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bookmark_added_outlined, size: 18),
                label: Text(_isSaved ? 'Saved to Supabase!' : 'Save Plan to My Supabase Profile'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
      ],
    );
  }
}
