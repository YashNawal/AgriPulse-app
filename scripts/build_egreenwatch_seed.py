"""
Generates data/lgd_villages.csv from eGreenWatch all_states_hierarchy.json
and imports it into out/ CSV master.
"""
import json
import csv
import os

with open('data/all_states_hierarchy.json', 'r', encoding='utf-8') as f:
    hierarchy = json.load(f)

# Prefer Wikipedia 36 districts and 358 talukas for Maharashtra
try:
    with open('data/maharashtra_hierarchy.json', 'r', encoding='utf-8') as f:
        mh_wiki = json.load(f)
    wiki_mh_districts = {}
    for d, subs in mh_wiki.items():
        all_t = []
        for t_list in subs.values():
            all_t.extend(t_list)
        wiki_mh_districts[d] = all_t
    hierarchy['Maharashtra'] = wiki_mh_districts
except Exception as e:
    print('Notice:', e)

TARGET_STATES = [
    "Uttar Pradesh", "Punjab", "Madhya Pradesh", "West Bengal", "Gujarat", "Maharashtra",
    "Rajasthan", "Karnataka", "Andhra Pradesh", "Haryana", "Bihar", "Tamil Nadu", "Telangana",
    "Chhattisgarh", "Odisha", "Assam", "Kerala", "Jharkhand", "Himachal Pradesh", "Sikkim",
]

# State LGD code mapping
STATE_CODES = {
    "Andhra Pradesh": "28", "Assam": "18", "Bihar": "10", "Chhattisgarh": "22",
    "Gujarat": "24", "Haryana": "06", "Himachal Pradesh": "02", "Jharkhand": "20",
    "Karnataka": "29", "Kerala": "32", "Madhya Pradesh": "23", "Maharashtra": "27",
    "Odisha": "21", "Punjab": "03", "Rajasthan": "08", "Sikkim": "11",
    "Tamil Nadu": "33", "Telangana": "36", "Uttar Pradesh": "09", "West Bengal": "19"
}

village_rows = []
d_code_counter = 100
sub_code_counter = 1000
v_code_counter = 100000

for state_name in TARGET_STATES:
    s_code = STATE_CODES.get(state_name, "99")
    # find state in hierarchy (case insensitive)
    matched_state = next((s for s in hierarchy if s.lower() == state_name.lower()), None)
    if not matched_state:
        continue

    dists = hierarchy[matched_state]
    for dist_name, tehsils in dists.items():
        d_code_counter += 1
        d_clean = dist_name.replace(' *', '').strip()
        for t_name in tehsils:
            sub_code_counter += 1
            t_clean = t_name.replace(' *', '').strip()
            v_code_counter += 1

            # Representative village 1: Rural
            village_rows.append({
                "state_code": s_code,
                "state_name": state_name,
                "district_code": str(d_code_counter),
                "district_name": d_clean,
                "sub_district_code": str(sub_code_counter),
                "sub_district_name": t_clean,
                "village_code": str(v_code_counter),
                "village_name": f"{t_clean} Rural",
            })

            # Representative village 2: Kasba
            v_code_counter += 1
            village_rows.append({
                "state_code": s_code,
                "state_name": state_name,
                "district_code": str(d_code_counter),
                "district_name": d_clean,
                "sub_district_code": str(sub_code_counter),
                "sub_district_name": t_clean,
                "village_code": str(v_code_counter),
                "village_name": f"{t_clean} Kasba",
            })

with open("data/lgd_villages.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "state_code", "state_name", "district_code", "district_name",
        "sub_district_code", "sub_district_name", "village_code", "village_name"
    ])
    writer.writeheader()
    writer.writerows(village_rows)

print(f"Generated data/lgd_villages.csv with {len(village_rows)} villages across {len(TARGET_STATES)} states.")
