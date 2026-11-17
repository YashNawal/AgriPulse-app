import json

data = json.load(open('data/maharashtra_hierarchy.json', encoding='utf-8'))

out = '''/// Official Maharashtra Administrative Hierarchy (Districts, Subdivisions, Talukas)
/// Sourced directly from Wikipedia: https://en.wikipedia.org/wiki/List_of_talukas_of_Maharashtra
/// Includes all 36 Districts, Subdivisions, and 358 Talukas (+ Mumbai City).

class MaharashtraLocationData {
  static const Map<String, String> districtAliases = {
    'Ahmednagar': 'Ahilyanagar',
    'Aurangabad': 'Chhatrapati Sambhajinagar',
    'Osmanabad': 'Dharashiv',
  };

  static const List<String> districts = [
'''

for d in sorted(data.keys()):
    out += f"    '{d}',\n"

out += '''  ];

  static const Map<String, Map<String, List<String>>> hierarchy = {
'''

for d, subs in sorted(data.items()):
    out += f"    '{d}': {{\n"
    for sub, talukas in subs.items():
        escaped_t = ", ".join(f"'{t}'" for t in talukas)
        out += f"      '{sub}': [{escaped_t}],\n"
    out += "    },\n"

out += '''  };

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
}
'''

with open('lib/data/services/maharashtra_location_data.dart', 'w', encoding='utf-8') as f:
    f.write(out)

print(f"Generated lib/data/services/maharashtra_location_data.dart with {len(data)} districts.")
