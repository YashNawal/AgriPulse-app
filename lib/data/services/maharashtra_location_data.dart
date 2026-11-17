/// Official Maharashtra Administrative Hierarchy (Districts, Subdivisions, Talukas)
/// Sourced directly from Wikipedia: https://en.wikipedia.org/wiki/List_of_talukas_of_Maharashtra
/// Includes all 36 Districts, Subdivisions, and 358 Talukas (+ Mumbai City).
class MaharashtraLocationData {
  static const Map<String, String> districtAliases = {
    'Ahmednagar': 'Ahilyanagar',
    'Aurangabad': 'Chhatrapati Sambhajinagar',
    'Osmanabad': 'Dharashiv',
  };

  static const List<String> districts = [
    'Ahilyanagar',
    'Akola',
    'Amravati',
    'Beed',
    'Bhandara',
    'Buldhana',
    'Chandrapur',
    'Chhatrapati Sambhajinagar',
    'Dharashiv',
    'Dhule',
    'Gadchiroli',
    'Gondia',
    'Hingoli',
    'Jalgaon',
    'Jalna',
    'Kolhapur',
    'Latur',
    'Mumbai City',
    'Mumbai Suburban',
    'Nagpur',
    'Nanded',
    'Nandurbar',
    'Nashik',
    'Palghar',
    'Parbhani',
    'Pune',
    'Raigad',
    'Ratnagiri',
    'Sangli',
    'Satara',
    'Sindhudurg',
    'Solapur',
    'Thane',
    'Wardha',
    'Washim',
    'Yavatmal',
  ];

  static const Map<String, Map<String, List<String>>> hierarchy = {
    'Ahilyanagar': {
      'Ahmednagar': ['Nagar', 'Shevgaon', 'Pathardi', 'Parner'],
      'Sangamner': ['Sangamner', 'Kopargaon', 'Akole'],
      'Shrirampur': ['Shrirampur', 'Nevasa', 'Rahata', 'Rahuri'],
      'Karjat': ['Shrigonda', 'Karjat', 'Jamkhed'],
    },
    'Akola': {
      'Akola': ['Akola'],
      'Akot': ['Akot', 'Telhara'],
      'Balapur': ['Balapur', 'Patur'],
      'Murtajapur': ['Murtajapur', 'Barshitakli'],
    },
    'Amravati': {
      'Amravati': ['Amravati', 'Bhatkuli', 'Nandgaon Khandeshwar'],
      'Dharni': ['Dharni', 'Chikhaldara'],
      'Achalpur': ['Achalpur', 'Chandurbazar'],
      'Morshi': ['Morshi', 'Warud'],
      'Daryapur': ['Daryapur', 'Anjangaon-Surji'],
      'Chandur': ['Chandur', 'Dhamangaon', 'Tiosa'],
    },
    'Beed': {
      'Beed': ['Beed', 'Georai'],
      'Patoda': ['Patoda', 'Shirur-Kasar', 'Ashti'],
      'Ambejogai': ['Majalgaon', 'Wadwani', 'Kaij', 'Dharur', 'Parli', 'Ambajogai'],
    },
    'Bhandara': {
      'Bhandara': ['Bhandara', 'Tumsar', 'Pauni', 'Mohadi'],
      'Sakoli': ['Sakoli', 'Lakhani', 'Lakhandur'],
    },
    'Buldhana': {
      'Buldhana': ['Buldhana', 'Chikhli', 'Deulgaon Raja'],
      'Jalgaon Jamod': ['Jalgaon Jamod', 'Sangrampur'],
      'Malkapur': ['Malkapur', 'Motala', 'Nandura'],
      'Khamgaon': ['Khamgaon', 'Shegaon'],
      'Mehkar': ['Mehkar', 'Sindkhed Raja', 'Lonar'],
    },
    'Chandrapur': {
      'Chandrapur': ['Chandrapur', 'Saoli', 'Mul', 'Ballarpur', 'Pombhurna', 'Gondpimpri'],
      'Warora': ['Warora', 'Chimur', 'Bhadravati'],
      'Bramhapuri': ['Bramhapuri', 'Nagbhid', 'Sindewahi'],
      'Rajura': ['Rajura', 'Korpana', 'Jiwati'],
    },
    'Chhatrapati Sambhajinagar': {
      'Aurangabad': ['Aurangabad', 'Kannad', 'Soegaon'],
      'Sillod': ['Sillod', 'Phulambri', 'Khuldabad'],
      'Vaijapur': ['Vaijapur', 'Gangapur', 'Paithan'],
    },
    'Dharashiv': {
      'Osmanabad': ['Osmanabad', 'Tuljapur'],
      'Bhum': ['Bhum', 'Paranda'],
      'Kalamb': ['Washi', 'Kalamb'],
      'Umarga': ['Lohara', 'Umarga'],
    },
    'Dhule': {
      'Dhule': ['Dhule', 'Sakri'],
      'Sindkheda': ['Sindkheda', 'Shirpur'],
    },
    'Gadchiroli': {
      'Gadchiroli': ['Gadchiroli', 'Dhanora', 'Chamorshi', 'Mulchera'],
      'Desaiganj': ['Desaiganj', 'Armori', 'Kurkheda', 'Korchi'],
      'Aheri': ['Aheri', 'Etapalli', 'Bhamragad', 'Sironcha'],
    },
    'Gondia': {
      'Gondia': ['Gondia', 'Goregaon', 'Salekasa'],
      'Tiroda': ['Tiroda'],
      'Deori': ['Amgaon', 'Deori'],
      'Arjuni Morgaon': ['Arjuni-Morgaon', 'Sadak-Arjuni'],
    },
    'Hingoli': {
      'Hingoli': ['Hingoli', 'Sengaon', 'Kalamnuri'],
      'Basmath': ['Basmath', 'Aundha Nagnath'],
    },
    'Jalgaon': {
      'Jalgaon': ['Jalgaon', 'Jamner', 'Erandol', 'Dharangaon'],
      'Bhusawal': ['Bhusawal', 'Raver', 'Muktainagar', 'Bodwad', 'Yawal'],
      'Amalner': ['Amalner', 'Parola', 'Chopda'],
      'Pachora': ['Pachora', 'Bhadgaon', 'Chalisgaon'],
    },
    'Jalna': {
      'Jalna': ['Jalna', 'Bhokardan', 'Jafrabad', 'Badnapur'],
      'Partur': ['Ambad', 'Ghansawangi', 'Partur', 'Mantha'],
    },
    'Kolhapur': {
      'Karvir': ['Karvir', 'Panhala', 'Shahuwadi', 'Kagal'],
      'Ichalkaranji': ['Hatkanangale', 'Shirol'],
      'Radhanagari': ['Radhanagari', 'Gaganbawada', 'Bhudargad'],
      'Gadhinglaj': ['Gadhinglaj', 'Chandgad', 'Ajra'],
    },
    'Latur': {
      'Latur': ['Latur'],
      'Ausa-Renapur': ['Renapur', 'Ausa'],
      'Ahmedpur': ['Ahmedpur', 'Jalkot', 'Chakur', 'Shirur Anantpal'],
      'Nilanga': ['Nilanga', 'Deoni'],
      'Udgir': ['Udgir'],
    },
    'Mumbai City': {
      'Mumbai City': ['Mumbai City'],
    },
    'Mumbai Suburban': {
      'Bandra': ['Kurla', 'Andheri', 'Borivali'],
    },
    'Nagpur': {
      'Nagpur': ['Nagpur Urban', 'Nagpur Rural', 'Kamptee', 'Hingna'],
      'Katol': ['Katol', 'Narkhed'],
      'Savner': ['Savner', 'Kalameshwar'],
      'Ramtek': ['Ramtek', 'Mouda', 'Parseoni'],
      'Umred': ['Umred', 'Kuhi', 'Bhiwapur'],
    },
    'Nanded': {
      'Nanded': ['Nanded', 'Ardhapur', 'Mudkhed', 'Bhokar', 'Umri', 'Loha', 'Kandhar'],
      'Kinwat': ['Kinwat', 'Himayatnagar', 'Hadgaon', 'Mahur'],
      'Deglur': ['Deglur', 'Mukhed', 'Dharmabad', 'Biloli', 'Naigaon'],
    },
    'Nandurbar': {
      'Nandurbar': ['Nandurbar', 'Navapur', 'Shahada'],
      'Talode': ['Talode', 'Akkalkuwa', 'Dhadgaon'],
    },
    'Nashik': {
      'Nashik': ['Nashik', 'Igatpuri', 'Dindori', 'Peth', 'Trimbakeshwar'],
      'Kalwan': ['Kalwan', 'Deola', 'Surgana', 'Baglan'],
      'Malegaon': ['Malegaon', 'Nandgaon', 'Chandwad'],
      'Niphad': ['Niphad', 'Sinnar', 'Yeola'],
    },
    'Palghar': {
      'Palghar': ['Palghar', 'Vasai', 'Dahanu', 'Talasari'],
      'Jawhar': ['Jawhar', 'Mokhada', 'Vada', 'Vikramgad'],
    },
    'Parbhani': {
      'Parbhani': ['Parbhani', 'Sonpeth', 'Gangakhed', 'Palam', 'Purna'],
      'Sailu': ['Sailu', 'Jintur', 'Manwath', 'Pathri'],
    },
    'Pune': {
      'Haveli': ['Pune City', 'Haveli'],
      'Khed': ['Khed', 'Junnar', 'Ambegaon'],
      'Maval': ['Maval', 'Mulshi', 'Shirur'],
      'Bhor': ['Purandhar (Saswad)', 'Velhe', 'Bhor'],
      'Baramati': ['Baramati', 'Indapur', 'Daund'],
    },
    'Raigad': {
      'Alibaug': ['Pen', 'Alibag', 'Murud'],
      'Panvel': ['Panvel', 'Uran'],
      'Karjat': ['Karjat', 'Khalapur'],
      'Mangaon': ['Mangaon', 'Tala', 'Roha', 'Sudhagad-Pali'],
      'Mahad': ['Mahad', 'Poladpur', 'Shrivardhan', 'Mhasala'],
    },
    'Ratnagiri': {
      'Ratnagiri': ['Ratnagiri', 'Sangameshwar', 'Lanja', 'Rajapur'],
      'Chiplun': ['Chiplun', 'Guhagar', 'Dapoli', 'Mandangad', 'Khed'],
    },
    'Sangli': {
      'Miraj': ['Miraj', 'Kavathemahankal', 'Tasgaon', 'Jat'],
      'Walwa': ['Walwa', 'Shirala'],
      'Khanapur': ['Khanapur (Vita)', 'Atpadi', 'Palus', 'Kadegaon'],
    },
    'Satara': {
      'Satara': ['Satara', 'Jaoli', 'Koregaon'],
      'Wai': ['Wai', 'Mahabaleshwar', 'Khandala'],
      'Phaltan': ['Phaltan', 'Maan', 'Khatav'],
      'Karad': ['Patan', 'Karad'],
    },
    'Sindhudurg': {
      'Kankavli': ['Kankavli', 'Vaibhavwadi', 'Devgad', 'Malwan'],
      'Sawantwadi': ['Sawantwadi', 'Kudal', 'Vengurla', 'Dodamarg'],
    },
    'Solapur': {
      'Solapur North': ['Barshi', 'Solapur North'],
      'Solapur South': ['Solapur South', 'Akkalkot'],
      'Kurduwadi': ['Madha', 'Karmala'],
      'Pandharpur': ['Pandharpur', 'Mohol'],
      'Malshiras': ['Malshiras'],
      'Mangalvedhe': ['Sangole', 'Mangalvedhe'],
    },
    'Thane': {
      'Thane': ['Thane', 'Kalyan', 'Murbad'],
      'Bhiwandi': ['Shahapur', 'Bhiwandi'],
      'Ulhasnagar': ['Ulhasnagar', 'Ambarnath'],
    },
    'Wardha': {
      'Wardha': ['Wardha', 'Deoli', 'Seloo'],
      'Arvi': ['Arvi', 'Ashti', 'Karanja'],
      'Hinganghat': ['Hinganghat', 'Samudrapur'],
    },
    'Washim': {
      'Washim': ['Washim', 'Malegaon', 'Risod'],
      'Mangrulpir': ['Mangrulpir', 'Karanja', 'Manora'],
    },
    'Yavatmal': {
      'Yavatmal': ['Yavatmal', 'Arni', 'Babhulgaon', 'Kalamb'],
      'Darwha': ['Darwha', 'Digras', 'Ner'],
      'Pusad': ['Pusad', 'Umarkhed', 'Mahagaon'],
      'Kelapur': ['Kelapur', 'Ralegaon', 'Ghatanji'],
      'Wani': ['Wani', 'Maregaon', 'Zari Jamani'],
    },
  };

  /// Canonicalize district name to handle modern vs historical names
  static String canonicalDistrict(String district) {
    return districtAliases[district] ?? district;
  }

  /// Get subdivisions for a district
  static List<String> getSubdivisions(String district) {
    final canon = canonicalDistrict(district);
    return hierarchy[canon]?.keys.toList() ?? [];
  }

  /// Get talukas for a district, optionally filtered by subdivision
  static List<String> getTalukas(String district, {String? subdivision}) {
    final canon = canonicalDistrict(district);
    final subs = hierarchy[canon];
    if (subs == null) return [];

    if (subdivision != null && subdivision.isNotEmpty && subdivision != 'All Subdivisions') {
      return subs[subdivision] ?? [];
    }

    final allTalukas = <String>[];
    for (final tList in subs.values) {
      allTalukas.addAll(tList);
    }
    return allTalukas;
  }

  /// Latitude & Longitude centroid coordinates for each Maharashtra district
  static const Map<String, ({double lat, double lon})> districtCoordinates = {
    'Ahilyanagar': (lat: 19.0948, lon: 74.7480),
    'Akola': (lat: 20.7002, lon: 77.0082),
    'Amravati': (lat: 20.9320, lon: 77.7523),
    'Beed': (lat: 18.9891, lon: 75.7601),
    'Bhandara': (lat: 21.1714, lon: 79.6548),
    'Buldhana': (lat: 20.5293, lon: 76.1843),
    'Chandrapur': (lat: 19.9615, lon: 79.2961),
    'Chhatrapati Sambhajinagar': (lat: 19.8762, lon: 75.3433),
    'Dharashiv': (lat: 18.1861, lon: 76.0419),
    'Dhule': (lat: 20.9042, lon: 74.7749),
    'Gadchiroli': (lat: 20.1849, lon: 79.9948),
    'Gondia': (lat: 21.4624, lon: 80.1961),
    'Hingoli': (lat: 19.7197, lon: 77.1485),
    'Jalgaon': (lat: 21.0077, lon: 75.5626),
    'Jalna': (lat: 19.8410, lon: 75.8864),
    'Kolhapur': (lat: 16.7050, lon: 74.2433),
    'Latur': (lat: 18.4088, lon: 76.5604),
    'Mumbai City': (lat: 18.9388, lon: 72.8354),
    'Mumbai Suburban': (lat: 19.1136, lon: 72.8697),
    'Nagpur': (lat: 21.1458, lon: 79.0882),
    'Nanded': (lat: 19.1383, lon: 77.3210),
    'Nandurbar': (lat: 21.3700, lon: 74.2400),
    'Nashik': (lat: 19.9975, lon: 73.7898),
    'Palghar': (lat: 19.6967, lon: 72.7699),
    'Parbhani': (lat: 19.2686, lon: 76.7708),
    'Pune': (lat: 18.5204, lon: 73.8567),
    'Raigad': (lat: 18.5158, lon: 73.1822),
    'Ratnagiri': (lat: 16.9902, lon: 73.3120),
    'Sangli': (lat: 16.8524, lon: 74.5815),
    'Satara': (lat: 17.6805, lon: 74.0183),
    'Sindhudurg': (lat: 16.1214, lon: 73.6894),
    'Solapur': (lat: 17.6599, lon: 75.9064),
    'Thane': (lat: 19.2183, lon: 72.9781),
    'Wardha': (lat: 20.7453, lon: 78.6022),
    'Washim': (lat: 20.1111, lon: 77.1350),
    'Yavatmal': (lat: 20.3888, lon: 78.1204),
  };

  /// Returns coordinates for given district
  static ({double lat, double lon}) getDistrictCoordinates(String district) {
    final canon = canonicalDistrict(district);
    return districtCoordinates[canon] ?? (lat: 19.9975, lon: 73.7898);
  }
}
