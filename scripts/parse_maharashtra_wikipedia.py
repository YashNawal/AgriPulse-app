"""
Parses all Districts, District Subdivisions, and Talukas of Maharashtra from:
https://en.wikipedia.org/wiki/List_of_talukas_of_Maharashtra

Outputs:
  - out/maharashtra_districts_subdivisions_talukas.csv
  - data/maharashtra_hierarchy.json
"""
import csv
import json
import os
import re
import urllib.request
from html.parser import HTMLParser

class RowspanTableParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_table = False
        self.in_tr = False
        self.in_cell = False
        self.current_cell_attrs = {}
        self.current_cell_data = []
        self.row_idx = 0
        self.grid = {}

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        if tag == 'table' and 'wikitable' in attrs_dict.get('class', ''):
            self.in_table = True
        elif self.in_table and tag == 'tr':
            self.in_tr = True
            self.current_col = 0
        elif self.in_tr and tag in ('th', 'td'):
            self.in_cell = True
            self.current_cell_attrs = attrs_dict
            self.current_cell_data = []

    def handle_endtag(self, tag):
        if tag == 'table' and self.in_table:
            self.in_table = False
        elif tag == 'tr' and self.in_tr:
            self.in_tr = False
            self.row_idx += 1
        elif tag in ('th', 'td') and self.in_cell:
            self.in_cell = False
            text = ' '.join(''.join(self.current_cell_data).split())
            rowspan = int(self.current_cell_attrs.get('rowspan', 1))
            colspan = int(self.current_cell_attrs.get('colspan', 1))

            while (self.row_idx, self.current_col) in self.grid:
                self.current_col += 1

            for r in range(self.row_idx, self.row_idx + rowspan):
                for c in range(self.current_col, self.current_col + colspan):
                    self.grid[(r, c)] = text
            self.current_col += colspan

    def handle_data(self, data):
        if self.in_cell:
            self.current_cell_data.append(data)

def clean_district_name(d):
    d = re.sub(r'\s+district.*', '', d, flags=re.IGNORECASE).strip()
    # Normalize modern official names
    aliases = {
        'aurangabad': 'Chhatrapati Sambhajinagar',
        'osmanabad': 'Dharashiv',
        'ahmednagar': 'Ahilyanagar',
    }
    low = d.lower()
    for k, v in aliases.items():
        if k in low and v.lower() not in low:
            return v
    return d

def fetch_and_parse():
    os.makedirs('data', exist_ok=True)
    os.makedirs('out', exist_ok=True)

    url = 'https://en.wikipedia.org/wiki/List_of_talukas_of_Maharashtra'
    print(f'Fetching: {url}')
    req = urllib.request.Request(url, headers={'User-Agent': 'KisanMitra-Scraper/1.0'})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode('utf-8')
    except Exception as e:
        # Fallback to local cached step file if network throttles
        cached_step = r'C:\Users\yashs\.gemini\antigravity-ide\brain\bd0a1f26-8d0f-4504-bfac-9a89eb8887ea\.system_generated\steps\525\content.md'
        if os.path.exists(cached_step):
            print(f'Reading from local cache: {cached_step}')
            with open(cached_step, encoding='utf-8') as f:
                html = f.read()
        else:
            raise e

    parser = RowspanTableParser()
    parser.feed(html)

    max_r = max(r for r, c in parser.grid.keys())
    records = []

    for r in range(1, max_r + 1):
        raw_dist = parser.grid.get((r, 0), '')
        subdiv = parser.grid.get((r, 1), '').strip()
        taluka = parser.grid.get((r, 2), '').strip()
        hq = parser.grid.get((r, 3), '').strip()

        if raw_dist and taluka and raw_dist.lower() != 'district':
            dist = clean_district_name(raw_dist)
            records.append({
                'state': 'Maharashtra',
                'district': dist,
                'subdivision': subdiv,
                'taluka': taluka,
                'headquarters_type': hq,
            })

    print(f'Parsed {len(records)} talukas across Maharashtra from Wikipedia.')

    # Write CSV
    csv_path = 'out/maharashtra_districts_subdivisions_talukas.csv'
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=['state', 'district', 'subdivision', 'taluka', 'headquarters_type'])
        w.writeheader()
        w.writerows(records)
    print(f'Wrote: {csv_path}')

    # Build hierarchical tree: District -> Subdivision -> [Talukas]
    hierarchy = {}
    for r in records:
        d = r['district']
        sub = r['subdivision']
        tal = r['taluka']
        if d not in hierarchy:
            hierarchy[d] = {}
        if sub not in hierarchy[d]:
            hierarchy[d][sub] = []
        if tal not in hierarchy[d][sub]:
            hierarchy[d][sub].append(tal)

    json_path = 'data/maharashtra_hierarchy.json'
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(hierarchy, f, indent=2, ensure_ascii=False)
    print(f'Wrote: {json_path} ({len(hierarchy)} districts)')

    return records, hierarchy

if __name__ == '__main__':
    fetch_and_parse()
