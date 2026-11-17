import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';

class SoilScreen extends StatefulWidget {
  const SoilScreen({super.key});

  @override
  State<SoilScreen> createState() => _SoilScreenState();
}

class _SoilScreenState extends State<SoilScreen> {
  bool _showManualTuning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agri = context.read<AgriProvider>();
      if (agri.liveSoilReport == null) {
        agri.analyzeSoilFromLiveGps(forceGps: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();
    final farmer = agri.currentFarmer;
    final report = agri.liveSoilReport;

    final lat = farmer?.latitude ?? 20.1477;
    final lon = farmer?.longitude ?? 74.2263;
    final district = farmer?.district.isNotEmpty == true ? farmer!.district : 'Nashik';

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: Text(lang.t('soil_title')),
        actions: [
          IconButton(
            tooltip: 'Refresh Soil Data from GPS',
            icon: agri.isGpsSoilAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: AppTheme.primaryGreen),
            onPressed: agri.isGpsSoilAnalyzing
                ? null
                : () => agri.analyzeSoilFromLiveGps(forceGps: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live GPS Location & Soil API Action Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3E22), Color(0xFF1B6A3C)],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.satellite_alt, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIVE LOCATION & SOIL API',
                              style: TextStyle(
                                color: Color(0xFF86EFAC),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '$district District (${lat.toStringAsFixed(3)}°N, ${lon.toStringAsFixed(3)}°E)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Detects real-time soil type, physical composition (clay/sand/silt), and tailored crop suitability via ISRIC SoilGrids REST API & ICAR Agronomic Survey.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: agri.isGpsSoilAnalyzing
                          ? null
                          : () => agri.analyzeSoilFromLiveGps(forceGps: true),
                      icon: agri.isGpsSoilAnalyzing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                        agri.isGpsSoilAnalyzing
                            ? 'Detecting GPS & Satellite Soil...'
                            : '📍 Detect Live GPS Location & Soil Type',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (agri.soilAnalysisError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agri.soilAnalysisError!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 2. Detected Soil Type & Scientific Profile Card
            if (report != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Identified Soil Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.greenBadge,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VERIFIED SOIL TYPE',
                      style: TextStyle(
                        color: AppTheme.greenText,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Soil Type Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.terrain, color: AppTheme.primaryGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.soilType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${report.texture} • ${report.nearestDistrict} Region',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Attribute Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SoilPill(
                          icon: Icons.palette_outlined,
                          label: report.color,
                          color: const Color(0xFF78350F),
                          bgColor: const Color(0xFFFEF3C7),
                        ),
                        _SoilPill(
                          icon: Icons.water_drop_outlined,
                          label: report.waterRetention,
                          color: const Color(0xFF1D4ED8),
                          bgColor: const Color(0xFFDBEAFE),
                        ),
                        _SoilPill(
                          icon: Icons.science_outlined,
                          label: 'pH ${report.ph} (${report.phStatus.split(' ').first})',
                          color: const Color(0xFF047857),
                          bgColor: const Color(0xFFD1FAE5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Geological Description
                    Text(
                      report.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(height: 1, color: AppTheme.borderSubtle),
                    const SizedBox(height: 14),

                    // Key Nutrient & Physical Matrix Grid
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: 'Soil pH Level',
                            value: report.ph.toStringAsFixed(2),
                            subtitle: report.phStatus,
                            icon: Icons.speed,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            label: 'Organic Carbon (OC)',
                            value: '${report.organicCarbon}%',
                            subtitle: report.ocStatus,
                            icon: Icons.biotech,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: 'Nitrogen (N)',
                            value: '${report.nitrogen.toInt()} kg/ha',
                            subtitle: report.nitrogen < 140 ? 'Low' : 'Adequate',
                            icon: Icons.eco,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            label: 'Phosphorus (P)',
                            value: '${report.phosphorus.toInt()} kg/ha',
                            subtitle: report.phosphorus < 20 ? 'Moderate' : 'High',
                            icon: Icons.grain,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            label: 'Potassium (K)',
                            value: '${report.potassium.toInt()} kg/ha',
                            subtitle: 'Rich (>200)',
                            icon: Icons.spa,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Clay / Sand / Silt Texture Composition Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSand,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Physical Particle Composition',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                'Clay ${report.clayPct.toInt()}% • Sand ${report.sandPct.toInt()}% • Silt ${report.siltPct.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 8,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: report.clayPct.toInt().clamp(1, 100),
                                    child: Container(color: const Color(0xFF78350F)),
                                  ),
                                  Expanded(
                                    flex: report.sandPct.toInt().clamp(1, 100),
                                    child: Container(color: const Color(0xFFFBBF24)),
                                  ),
                                  Expanded(
                                    flex: report.siltPct.toInt().clamp(1, 100),
                                    child: Container(color: const Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('🟫 Clay (Retention)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text('🟨 Sand (Drainage)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text('⬜ Silt (Pores)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Data source tag
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 12, color: AppTheme.primaryGreen),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Data Source: ${report.source}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Best Suitable Crops for this Soil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌾 Best Suitable Crops for this Soil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ranked by soil chemistry & regional suitability (${report.suitableCrops.length} Crops)',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.suitableCrops.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final crop = report.suitableCrops[idx];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: crop.suitabilityScore >= 95
                            ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                            : AppTheme.borderSubtle,
                        width: crop.suitabilityScore >= 95 ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crop Name & Match Score Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: crop.suitabilityScore >= 95
                                    ? AppTheme.primaryGreen
                                    : (crop.suitabilityScore >= 90
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF2563EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#${idx + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          crop.cropName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.bgSand,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          crop.localName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${crop.category} • ${crop.season}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.greenBadge,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${crop.suitabilityScore}% Match',
                                style: const TextStyle(
                                  color: AppTheme.greenText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Reason Why Suitable
                        Text(
                          crop.reason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Agronomic Soil Management Tip
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.tips_and_updates, size: 14, color: Color(0xFFB45309)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  crop.managementTip,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF78350F),
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Expected Yield & Grade
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expected Yield', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                Text(
                                  crop.expectedYield,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSand,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                crop.grade,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen,
                                ),
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

            const SizedBox(height: 24),

            // 4. Manual Soil Health Card Calibration Accordion
            GestureDetector(
              onTap: () => setState(() => _showManualTuning = !_showManualTuning),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Manual Soil Health Card Calibration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Tweak N, P, K & pH sliders from a physical lab test report',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _showManualTuning ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            if (_showManualTuning) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    _SoilSliderRow(
                      label: 'Available Nitrogen (N)',
                      unit: 'kg/ha',
                      value: agri.soilProfile.n,
                      min: 50,
                      max: 350,
                      onChanged: (v) => setState(() => agri.soilProfile.n = v),
                    ),
                    const Divider(height: 20, color: AppTheme.borderSubtle),
                    _SoilSliderRow(
                      label: 'Available Phosphorus (P)',
                      unit: 'kg/ha',
                      value: agri.soilProfile.p,
                      min: 5,
                      max: 100,
                      onChanged: (v) => setState(() => agri.soilProfile.p = v),
                    ),
                    const Divider(height: 20, color: AppTheme.borderSubtle),
                    _SoilSliderRow(
                      label: 'Available Potassium (K)',
                      unit: 'kg/ha',
                      value: agri.soilProfile.k,
                      min: 50,
                      max: 400,
                      onChanged: (v) => setState(() => agri.soilProfile.k = v),
                    ),
                    const Divider(height: 20, color: AppTheme.borderSubtle),
                    _SoilSliderRow(
                      label: 'Soil pH (Acidity / Alkalinity)',
                      unit: 'pH',
                      value: agri.soilProfile.ph,
                      min: 4.5,
                      max: 9.5,
                      isDecimal: true,
                      onChanged: (v) => setState(() => agri.soilProfile.ph = v),
                    ),
                    const Divider(height: 20, color: AppTheme.borderSubtle),
                    _SoilSliderRow(
                      label: 'Organic Carbon (OC)',
                      unit: '%',
                      value: agri.soilProfile.organicCarbon,
                      min: 0.2,
                      max: 1.8,
                      isDecimal: true,
                      onChanged: (v) => setState(() => agri.soilProfile.organicCarbon = v),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: agri.isSoilAnalyzing ? null : () => agri.runSoilAnalysis(),
                        icon: agri.isSoilAnalyzing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.calculate_outlined),
                        label: Text(
                          agri.isSoilAnalyzing ? 'Recalculating...' : 'Recalculate Crop Economics',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SoilPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _SoilPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgSand,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SoilSliderRow extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final bool isDecimal;
  final ValueChanged<double> onChanged;

  const _SoilSliderRow({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              isDecimal ? '${value.toStringAsFixed(1)} $unit' : '${value.toInt()} $unit',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppTheme.primaryGreen,
          inactiveColor: AppTheme.borderSubtle,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
