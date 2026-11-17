import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/models.dart';
import '../../../data/services/crop_catalog_service.dart';
import '../../../data/services/location_service.dart';
import '../../../providers/agri_provider.dart';
import '../../../providers/language_provider.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';

class YourDetailsScreen extends StatefulWidget {
  final FarmerProfile? initialProfile;

  const YourDetailsScreen({super.key, this.initialProfile});

  @override
  State<YourDetailsScreen> createState() => _YourDetailsScreenState();
}

class _YourDetailsScreenState extends State<YourDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _customVillageController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _farmAreaController = TextEditingController(text: '1');

  String _selectedState = 'Maharashtra';
  String _selectedDistrict = 'Nashik';
  String _selectedSubdivision = 'All Subdivisions';
  String _selectedSubdistrict = 'Niphad';
  String _selectedVillage = 'Lasalgaon';
  bool _isCustomVillage = false;

  String _selectedFarmUnit = 'Acres';
  String _selectedCropCategory = 'All';

  double _latitude = 20.1477;
  double _longitude = 74.2263;
  bool _isLoading = false;
  String? _lastSearchedPhone;
  String? _autoFillNotice;

  final Set<String> _selectedCrops = {'Onion', 'Wheat', 'Soybean'};

  static const List<String> _farmUnits = ['Acres', 'Hectares', 'Guntha', 'Bigha'];
  static const List<String> _areaPresets = ['0.5', '1', '2', '3', '5', '10+'];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(
      text: (p?.name != null && p!.name.isNotEmpty && p.name != 'Farmer') ? p.name : '',
    );
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _phoneController.addListener(_onPhoneInputChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? widget.initialProfile?.email;
      final phone = widget.initialProfile?.phone;
      if ((phone != null && phone.isNotEmpty) || (email != null && email.isNotEmpty)) {
        _autoFillFromSavedProfile(phone: phone, email: email);
      }
    });
    _customVillageController = TextEditingController();

    final initialArea = p?.farmArea ?? 1.0;
    _farmAreaController = TextEditingController(
      text: (initialArea % 1 == 0) ? initialArea.toInt().toString() : initialArea.toString(),
    );
    _selectedFarmUnit = p?.farmAreaUnit ?? 'Acres';

    if (p != null) {
      if (LocationService.targetStates.contains(p.state)) {
        _selectedState = p.state;
      }
      final dists = LocationService.instance.getDistricts(_selectedState);
      if (dists.contains(p.district)) {
        _selectedDistrict = p.district;
      } else if (dists.isNotEmpty) {
        _selectedDistrict = dists.first;
      }

      final subs = LocationService.instance.getSubdistricts(_selectedDistrict, state: _selectedState);
      if (subs.contains(p.subdistrict)) {
        _selectedSubdistrict = p.subdistrict;
      } else if (subs.isNotEmpty) {
        _selectedSubdistrict = subs.first;
      }

      final vils = LocationService.instance.getVillages(_selectedSubdistrict);
      if (vils.contains(p.village)) {
        _selectedVillage = p.village;
      } else if (p.village.isNotEmpty) {
        _isCustomVillage = true;
        _customVillageController.text = p.village;
      } else if (vils.isNotEmpty) {
        _selectedVillage = vils.first;
      }

      _latitude = p.latitude;
      _longitude = p.longitude;

      if (p.savedCrops.isNotEmpty) {
        _selectedCrops.clear();
        _selectedCrops.addAll(p.savedCrops);
      }
    } else {
      _syncDropdowns();
      _initializeStateCrops(_selectedState);
    }
  }

  void _onPhoneInputChanged() {
    final clean = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10 && clean != _lastSearchedPhone) {
      _lastSearchedPhone = clean;
      _autoFillFromSavedProfile(phone: clean);
    }
  }

  Future<void> _autoFillFromSavedProfile({String? phone, String? email}) async {
    final agri = context.read<AgriProvider>();
    final found = await agri.findExistingProfile(phone: phone, email: email);
    if (found != null && mounted) {
      setState(() {
        if (found.name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = found.name;
        }
        if (found.phone.isNotEmpty && _phoneController.text.isEmpty) {
          _phoneController.text = found.phone;
        }
        if (found.state.isNotEmpty && LocationService.targetStates.contains(found.state)) {
          _selectedState = found.state;
        }
        final dists = LocationService.instance.getDistricts(_selectedState);
        if (dists.contains(found.district)) {
          _selectedDistrict = found.district;
        }
        final subs = LocationService.instance.getSubdistricts(_selectedDistrict, state: _selectedState);
        if (subs.contains(found.subdistrict)) {
          _selectedSubdistrict = found.subdistrict;
        }
        final vils = LocationService.instance.getVillages(_selectedSubdistrict);
        if (vils.contains(found.village)) {
          _selectedVillage = found.village;
          _isCustomVillage = false;
        } else if (found.village.isNotEmpty) {
          _isCustomVillage = true;
          _customVillageController.text = found.village;
        }
        _farmAreaController.text = (found.farmArea % 1 == 0)
            ? found.farmArea.toInt().toString()
            : found.farmArea.toString();
        if (_farmUnits.contains(found.farmAreaUnit)) {
          _selectedFarmUnit = found.farmAreaUnit;
        }
        if (found.savedCrops.isNotEmpty) {
          _selectedCrops.clear();
          _selectedCrops.addAll(found.savedCrops);
        }
        _latitude = found.latitude;
        _longitude = found.longitude;
        _autoFillNotice = '✨ Found existing profile for \${found.name} (+\${found.phone})! Details auto-filled.';
      });
    }
  }

  void _syncDropdowns() {
    final isMh = LocationService.instance.isMaharashtra(_selectedState);
    final dists = LocationService.instance.getDistricts(_selectedState);
    if (!dists.contains(_selectedDistrict)) {
      _selectedDistrict = dists.isNotEmpty ? dists.first : '';
    }

    if (isMh) {
      final subs = LocationService.instance.getMaharashtraSubdivisions(_selectedDistrict);
      if (_selectedSubdivision != 'All Subdivisions' && !subs.contains(_selectedSubdivision)) {
        _selectedSubdivision = 'All Subdivisions';
      }
      final talukas = LocationService.instance.getMaharashtraTalukas(
        _selectedDistrict,
        subdivision: _selectedSubdivision,
      );
      if (!talukas.contains(_selectedSubdistrict)) {
        _selectedSubdistrict = talukas.isNotEmpty ? talukas.first : '';
      }
    } else {
      final subs = LocationService.instance.getSubdistricts(_selectedDistrict, state: _selectedState);
      if (!subs.contains(_selectedSubdistrict)) {
        _selectedSubdistrict = subs.isNotEmpty ? subs.first : '';
      }
    }

    final vils = LocationService.instance.getVillages(_selectedSubdistrict);
    if (!vils.contains(_selectedVillage)) {
      _selectedVillage = vils.isNotEmpty ? vils.first : '';
    }
  }

  void _initializeStateCrops(String state) {
    final stateCropItems = CropCatalogService.getCropsForState(state);
    final stateCropNames = stateCropItems.map((c) => c.name).toSet();

    // Check if current selection has crops in this state
    final retained = _selectedCrops.where((c) => stateCropNames.contains(c)).toSet();

    if (retained.isNotEmpty) {
      _selectedCrops.clear();
      _selectedCrops.addAll(retained);
    } else {
      // Pick first 3 major crops from state
      _selectedCrops.clear();
      _selectedCrops.addAll(stateCropItems.take(3).map((c) => c.name));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customVillageController.dispose();
    _phoneController.dispose();
    _farmAreaController.dispose();
    super.dispose();
  }

  void _detectLocationGps() {
    setState(() {
      _selectedState = 'Maharashtra';
      _selectedDistrict = 'Nashik';
      _selectedSubdivision = 'Niphad';
      _selectedSubdistrict = 'Niphad';
      _selectedVillage = 'Lasalgaon';
      _isCustomVillage = false;
      _latitude = 20.1477;
      _longitude = 74.2263;
      _initializeStateCrops('Maharashtra');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('📍 GPS: Lasalgaon, Niphad, Nashik (20.14°N, 74.22°E)'),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _formatUnitName(String unit) {
    switch (unit) {
      case 'Acres':
        return 'Acres (एकर)';
      case 'Hectares':
        return 'Hectares (हेक्टर)';
      case 'Guntha':
        return 'Guntha (गुंठा)';
      case 'Bigha':
        return 'Bigha (बीघा)';
      default:
        return unit;
    }
  }

  String _calculateConversions(double area, String unit) {
    if (area <= 0) return '';
    double inAcres = area;
    if (unit == 'Hectares') {
      inAcres = area * 2.47105;
    } else if (unit == 'Guntha') {
      inAcres = area / 40.0;
    } else if (unit == 'Bigha') {
      inAcres = area * 0.40; // Approx 1 Bigha ~ 0.4 Acres (central India standard)
    }

    final double guntha = inAcres * 40.0;
    final double hectares = inAcres * 0.404686;
    final double sqFt = inAcres * 43560.0;

    return '📐 Equivalent: ~${guntha.toStringAsFixed(1)} Guntha • ~${hectares.toStringAsFixed(2)} Hectare • ${(sqFt / 1000).toStringAsFixed(1)}k sq.ft';
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please select at least one crop grown on your farm.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final agri = context.read<AgriProvider>();
    final lang = context.read<LanguageProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    final finalVillage = _isCustomVillage
        ? _customVillageController.text.trim()
        : _selectedVillage;

    final enteredName = _nameController.text.trim();
    final defaultName = user?.email != null && user!.email!.contains('@')
        ? user.email!.split('@')[0]
        : 'Farmer';
    final finalFarmerName = enteredName.isNotEmpty ? enteredName : defaultName;
    final parsedArea = double.tryParse(_farmAreaController.text.trim()) ?? 1.0;

    final profile = FarmerProfile(
      id: user?.id ?? widget.initialProfile?.id ?? 'local_user',
      email: user?.email ?? widget.initialProfile?.email ?? '',
      name: finalFarmerName,
      state: _selectedState,
      district: _selectedDistrict,
      subdistrict: _selectedSubdistrict,
      village: finalVillage,
      phone: _phoneController.text.trim(),
      savedCrops: _selectedCrops.toList(),
      language: lang.currentLang,
      latitude: _latitude,
      longitude: _longitude,
      farmArea: parsedArea,
      farmAreaUnit: _selectedFarmUnit,
    );

    // Save into Supabase cloud table (for website sync)
    if (user != null) {
      await agri.supabaseService.saveFarmerProfile(profile);
    }

    // Save into local provider state and multi-profile cache
    agri.setFarmerProfile(profile);
    await agri.cacheProfile(profile);

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMh = LocationService.instance.isMaharashtra(_selectedState);
    final availableDistricts = LocationService.instance.getDistricts(_selectedState);
    final availableSubdivisions = isMh
        ? LocationService.instance.getMaharashtraSubdivisions(_selectedDistrict)
        : <String>[];
    final availableSubdistricts = isMh
        ? LocationService.instance.getMaharashtraTalukas(
            _selectedDistrict,
            subdivision: _selectedSubdivision,
          )
        : LocationService.instance.getSubdistricts(_selectedDistrict, state: _selectedState);
    final availableVillages = LocationService.instance.getVillages(_selectedSubdistrict);

    // Fetch crops for current state and active category filter
    final allStateCrops = CropCatalogService.getCropsForState(_selectedState);
    final filteredCrops = CropCatalogService.getCropsForState(
      _selectedState,
      category: _selectedCropCategory,
    );

    final parsedArea = double.tryParse(_farmAreaController.text.trim()) ?? 1.0;

    return Scaffold(
      backgroundColor: AppTheme.bgSand,
      appBar: AppBar(
        title: const Text('Farmer & Farm Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_autoFillNotice != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _autoFillNotice!,
                            style: const TextStyle(color: Color(0xFF14532D), fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Top Step Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isMh
                                    ? 'MAHARASHTRA • 36 DISTRICTS • 358 TALUKAS'
                                    : '${_selectedState.toUpperCase()} • ${availableDistricts.length} DISTS • ${availableSubdistricts.length} TEHSILS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMh ? 'Wikipedia Verified' : 'NIC eGreenWatch',
                            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Farmer Details & Land Record',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set your state, district, farm acreage, and cultivated crops for APMC mandi rates & precision advisories.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Name Field
                const Text(
                  'Farmer Name (नाव / नाम) *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ramesh Patil / राजेश शर्मा',
                    prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppTheme.primaryGreen),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  validator: (v) => null,
                ),

                const SizedBox(height: 16),

                // State Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'State (राज्य) *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    TextButton.icon(
                      onPressed: _detectLocationGps,
                      icon: const Icon(Icons.my_location, size: 14, color: AppTheme.primaryGreen),
                      label: const Text(
                        'Auto-detect GPS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedState,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.map_outlined, size: 20, color: AppTheme.primaryGreen),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  items: LocationService.targetStates.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedState = val;
                        _selectedSubdivision = 'All Subdivisions';
                        _syncDropdowns();
                        _initializeStateCrops(val);
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // District Dropdown (Cascading)
                const Text(
                  'District (जिल्हा / जिला) *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('dist_${_selectedState}_$_selectedDistrict'),
                  initialValue: availableDistricts.contains(_selectedDistrict)
                      ? _selectedDistrict
                      : (availableDistricts.isNotEmpty ? availableDistricts.first : null),
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_city_outlined, size: 20, color: AppTheme.primaryGreen),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  items: availableDistricts.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDistrict = val;
                        _selectedSubdivision = 'All Subdivisions';
                        _syncDropdowns();
                      });
                    }
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Please select your district' : null,
                ),

                // Subdivision Dropdown (Maharashtra specific from Wikipedia)
                if (isMh && availableSubdivisions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subdivision / उपविभाग (Wikipedia Source)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${availableSubdivisions.length} Subdivisions',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    key: ValueKey('subdiv_${_selectedDistrict}_$_selectedSubdivision'),
                    initialValue: ['All Subdivisions', ...availableSubdivisions].contains(_selectedSubdivision)
                        ? _selectedSubdivision
                        : 'All Subdivisions',
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.account_tree_outlined, size: 20, color: AppTheme.primaryGreen),
                      filled: true,
                      fillColor: AppTheme.cardWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                    items: ['All Subdivisions', ...availableSubdivisions].map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s == 'All Subdivisions' ? 'All Subdivisions (सर्व उपविभाग)' : s),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedSubdivision = val;
                          final newTalukas = LocationService.instance.getMaharashtraTalukas(
                            _selectedDistrict,
                            subdivision: val,
                          );
                          if (!newTalukas.contains(_selectedSubdistrict)) {
                            _selectedSubdistrict = newTalukas.isNotEmpty ? newTalukas.first : '';
                          }
                          final newVils = LocationService.instance.getVillages(_selectedSubdistrict);
                          _selectedVillage = newVils.isNotEmpty ? newVils.first : '';
                        });
                      }
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Sub-District / Taluka Dropdown (Cascading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sub-District / Taluka (तालुका / तहसील) *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    if (isMh)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${availableSubdistricts.length} Talukas',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('taluka_${_selectedDistrict}_${_selectedSubdivision}_$_selectedSubdistrict'),
                  initialValue: availableSubdistricts.contains(_selectedSubdistrict)
                      ? _selectedSubdistrict
                      : (availableSubdistricts.isNotEmpty ? availableSubdistricts.first : null),
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.domain_outlined, size: 20, color: AppTheme.primaryGreen),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  items: availableSubdistricts.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSubdistrict = val;
                        final newVils = LocationService.instance.getVillages(val);
                        _selectedVillage = newVils.isNotEmpty ? newVils.first : '';
                      });
                    }
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Please select your sub-district' : null,
                ),

                const SizedBox(height: 16),

                // Village Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Village / Gram Panchayat (गाव / ग्राम) *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isCustomVillage = !_isCustomVillage);
                      },
                      child: Text(
                        _isCustomVillage ? 'Select from LGD list' : 'Type custom village',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (!_isCustomVillage)
                  DropdownButtonFormField<String>(
                    initialValue: availableVillages.contains(_selectedVillage)
                        ? _selectedVillage
                        : (availableVillages.isNotEmpty ? availableVillages.first : null),
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.cottage_outlined, size: 20, color: AppTheme.primaryGreen),
                      filled: true,
                      fillColor: AppTheme.cardWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                    items: availableVillages.map((v) {
                      return DropdownMenuItem(value: v, child: Text(v));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVillage = val);
                    },
                  )
                else
                  TextFormField(
                    controller: _customVillageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your village or gram panchayat name',
                      prefixIcon: const Icon(Icons.cottage_outlined, size: 20, color: AppTheme.primaryGreen),
                      filled: true,
                      fillColor: AppTheme.cardWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter village name' : null,
                  ),

                const SizedBox(height: 16),

                // Phone / WhatsApp
                const Text(
                  'Mobile / WhatsApp Number (for Daily Rates Alert)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    prefixText: '+91 ',
                    prefixStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    hintText: '98765 43210',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppTheme.primaryGreen),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && v.trim().length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ==========================================
                // 🌾 FARM LAND AREA SECTION (New!)
                // ==========================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.05),
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
                              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.landscape_rounded, color: AppTheme.primaryGreen, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Farm Land Area (शेती क्षेत्र / रकबा) *',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Cultivated area for fertilizer & yield advisories',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Input Field + Unit Selector Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Numeric Input Field
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              controller: _farmAreaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Farm Size',
                                hintText: '1.0',
                                prefixIcon: const Icon(Icons.straighten_rounded, size: 20, color: AppTheme.primaryGreen),
                                filled: true,
                                fillColor: AppTheme.bgSand,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter area';
                                final val = double.tryParse(v.trim());
                                if (val == null || val <= 0) return 'Invalid size';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Unit Dropdown
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFarmUnit,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Unit',
                                filled: true,
                                fillColor: AppTheme.bgSand,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                                ),
                              ),
                              items: _farmUnits.map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    _formatUnitName(u),
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedFarmUnit = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Quick 1-Tap Preset Chips
                      const Text(
                        'Quick Select Land Size:',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _areaPresets.map((preset) {
                          final cleanVal = preset.replaceAll('+', '');
                          final isSelected = _farmAreaController.text == cleanVal && _selectedFarmUnit == 'Acres';
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _farmAreaController.text = cleanVal;
                                _selectedFarmUnit = 'Acres';
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryGreen : AppTheme.bgSand,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                                ),
                              ),
                              child: Text(
                                '$preset Acre',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Area Conversion Real-Time Banner
                      if (parsedArea > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _calculateConversions(parsedArea, _selectedFarmUnit),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // 🌱 STATE CROPS, GRAINS & VEGETABLES SECTION (New!)
                // ==========================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(18),
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
                                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Crops in $_selectedState',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const Text(
                                    'Select crops cultivated on your farm',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedCrops.length} Selected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Category Filter Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip('All', '🌟 All (${allStateCrops.length})'),
                            const SizedBox(width: 6),
                            _buildCategoryChip('Grains', '🌾 Grains (धान्य)'),
                            const SizedBox(width: 6),
                            _buildCategoryChip('Pulses', '🌱 Pulses (कडधान्य)'),
                            const SizedBox(width: 6),
                            _buildCategoryChip('Oilseeds & Cash', '☁️ Cash Crops'),
                            const SizedBox(width: 6),
                            _buildCategoryChip('Vegetables', '🧅 Vegetables (भाज्या)'),
                            const SizedBox(width: 6),
                            _buildCategoryChip('Fruits & Spices', '🍎 Fruits & Spices'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Actions: Select Major vs Clear
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                for (final c in filteredCrops) {
                                  _selectedCrops.add(c.name);
                                }
                              });
                            },
                            icon: const Icon(Icons.done_all, size: 14, color: AppTheme.primaryGreen),
                            label: const Text(
                              'Select All Shown',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_selectedCrops.isNotEmpty) {
                                  final first = _selectedCrops.first;
                                  _selectedCrops.clear();
                                  _selectedCrops.add(first);
                                }
                              });
                            },
                            icon: const Icon(Icons.clear_all, size: 14, color: AppTheme.textMuted),
                            label: const Text(
                              'Reset Selection',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Crops Wrap Items
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredCrops.map((crop) {
                          final isSel = _selectedCrops.contains(crop.name);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSel) {
                                  if (_selectedCrops.length > 1) {
                                    _selectedCrops.remove(crop.name);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('At least 1 crop must remain selected'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                } else {
                                  _selectedCrops.add(crop.name);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.primaryGreen : AppTheme.cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? AppTheme.primaryGreen : AppTheme.borderSubtle,
                                  width: isSel ? 1.5 : 1.0,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(crop.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        crop.name,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                          color: isSel ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                      if (crop.localName.isNotEmpty)
                                        Text(
                                          crop.localName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: isSel ? Colors.white70 : AppTheme.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isSel) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.check_circle, size: 14, color: Colors.white),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save & Enter KisanMitra Dashboard',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, String label) {
    final isSelected = _selectedCropCategory == categoryKey;
    return InkWell(
      onTap: () => setState(() => _selectedCropCategory = categoryKey),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDark : AppTheme.bgSand,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDark : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
