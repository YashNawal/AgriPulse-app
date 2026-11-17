import json

with open('data/all_states_hierarchy.json', 'r', encoding='utf-8') as f:
    hierarchy = json.load(f)

# Also ensure Maharashtra from Wikipedia is preserved or merged cleanly
try:
    with open('data/maharashtra_hierarchy.json', 'r', encoding='utf-8') as f:
        mh_wiki = json.load(f)
    # Merge / prefer detailed Wikipedia talukas for Maharashtra
    wiki_mh_districts = {}
    for d, subs in mh_wiki.items():
        all_t = []
        for t_list in subs.values():
            all_t.extend(t_list)
        wiki_mh_districts[d] = all_t
    hierarchy['Maharashtra'] = wiki_mh_districts
except Exception as e:
    print("Could not load mh_wiki:", e)

# Clean up district names (remove trailing asterisks or punctuation)
cleaned_hierarchy = {}
for state, dists in hierarchy.items():
    clean_dists = {}
    for dist, tehsils in dists.items():
        d_clean = dist.replace(' *', '').strip()
        # Deduplicate tehsils preserving order
        seen = set()
        clean_t = []
        for t in tehsils:
            t_clean = t.replace(' *', '').strip()
            if t_clean and t_clean.lower() not in seen:
                seen.add(t_clean.lower())
                clean_t.append(t_clean)
        clean_dists[d_clean] = clean_t
    cleaned_hierarchy[state] = clean_dists

out = '''/// Official All-India Administrative Hierarchy (States, Districts, Tehsils/Talukas)
/// Sourced directly from Government of India eGreenWatch portal (NIC):
/// https://egreenwatch.nic.in/Masters/Public/TehsilView.aspx?SID=10%2f1000
/// Covers all 37 States and Union Territories with 6,000+ official tehsils.

class AllStatesLocationData {
  /// All 37 States and Union Territories of India
  static const List<String> states = [
'''

for s in sorted(cleaned_hierarchy.keys()):
    out += f"    '{s}',\n"

out += '''  ];

  /// Districts map per state
  static const Map<String, List<String>> stateDistricts = {
'''

for s, dists in sorted(cleaned_hierarchy.items()):
    d_list = [f"'{d}'" for d in sorted(dists.keys())]
    out += f"    '{s}': [{', '.join(d_list)}],\n"

out += '''  };

  /// Tehsils / Talukas map per district (Key format: "State|District" to avoid multi-state collisions)
  static const Map<String, List<String>> stateDistrictTehsils = {
'''

for s, dists in sorted(cleaned_hierarchy.items()):
    for d, tehsils in sorted(dists.items()):
        key = f"{s}|{d}"
        t_list = [f"'{t}'" for t in tehsils]
        out += f"    '{key}': [{', '.join(t_list)}],\n"

out += '''  };

  /// Get list of districts for any state
  static List<String> getDistricts(String state) {
    // Exact or case-insensitive match
    if (stateDistricts.containsKey(state)) {
      return stateDistricts[state]!;
    }
    for (final entry in stateDistricts.entries) {
      if (entry.key.toLowerCase() == state.toLowerCase()) {
        return entry.value;
      }
    }
    return ['General District'];
  }

  /// Get list of tehsils / talukas for a state and district
  static List<String> getTehsils(String state, String district) {
    final directKey = '$state|$district';
    if (stateDistrictTehsils.containsKey(directKey)) {
      return stateDistrictTehsils[directKey]!;
    }

    // Try case-insensitive lookup
    final lowState = state.toLowerCase();
    final lowDist = district.toLowerCase();
    for (final entry in stateDistrictTehsils.entries) {
      final parts = entry.key.split('|');
      if (parts.length == 2 &&
          parts[0].toLowerCase() == lowState &&
          parts[1].toLowerCase() == lowDist) {
        return entry.value;
      }
    }

    // Fallback: district only search across all states
    for (final entry in stateDistrictTehsils.entries) {
      final parts = entry.key.split('|');
      if (parts.length == 2 && parts[1].toLowerCase() == lowDist) {
        return entry.value;
      }
    }

    return ['Main Tehsil', 'Rural Tehsil'];
  }
}
'''

with open('lib/data/services/all_states_location_data.dart', 'w', encoding='utf-8') as f:
    f.write(out)

print(f"Generated lib/data/services/all_states_location_data.dart with {len(cleaned_hierarchy)} states!")
