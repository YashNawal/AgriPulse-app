import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';

class DiseaseScreen extends StatelessWidget {
  const DiseaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: Text(lang.t('disease_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t('disease_subtitle'),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Camera / Leaf Upload Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryGreen, size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select or Upload Affected Leaf Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Clear close-up photograph of spots, yellowing, or leaf curl',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Quick Sample Selectors
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _SampleButton(cropKey: 'tomato', label: '🍅 Tomato Late Blight'),
                      _SampleButton(cropKey: 'wheat', label: '🌾 Wheat Stripe Rust'),
                      _SampleButton(cropKey: 'soybean', label: '🌱 Soybean Cercospora'),
                      _SampleButton(cropKey: 'cotton', label: '☁️ Cotton Leaf Curl'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Diagnosis Result Card
            if (agri.isDiagnosing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
              )
            else if (agri.activeDiagnosis != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.borderSubtle),
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
                                agri.activeDiagnosis!.crop,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                agri.activeDiagnosis!.disease,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.greenBadge,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${agri.activeDiagnosis!.confidence.toInt()}% Confidence',
                            style: const TextStyle(
                              color: AppTheme.greenText,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppTheme.borderSubtle),
                    const SizedBox(height: 14),

                    Text(
                      lang.t('symptoms'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agri.activeDiagnosis!.symptoms,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      lang.t('organic_remedies'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.greenText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...agri.activeDiagnosis!.organicTreatments.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greenText)),
                            Expanded(child: Text(item, style: const TextStyle(fontSize: 12, height: 1.35))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      lang.t('chemical_control'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.amberText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...agri.activeDiagnosis!.chemicalTreatments.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.amberText)),
                            Expanded(child: Text(item, style: const TextStyle(fontSize: 12, height: 1.35))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SampleButton extends StatelessWidget {
  final String cropKey;
  final String label;

  const _SampleButton({required this.cropKey, required this.label});

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final isSel = agri.selectedDiseaseSample == cropKey;

    return ActionChip(
      label: Text(label),
      backgroundColor: isSel ? AppTheme.primaryGreen : AppTheme.bgSand,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : AppTheme.textDark,
        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        fontSize: 11,
      ),
      onPressed: () => agri.selectDiseaseSample(cropKey),
    );
  }
}
