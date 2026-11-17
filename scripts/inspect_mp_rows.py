import re

with open("data/mp_wikipedia_raw.html", "r", encoding="utf-8") as f:
    html = f.read()

wikitables = re.findall(r'<table[^>]*wikitable[^>]*>(.*?)</table>', html, re.DOTALL | re.IGNORECASE)
print(f"Found {len(wikitables)} wikitables.")

for i, table_html in enumerate(wikitables):
    print(f"\n--- WIKITABLE {i+1} ---")
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table_html, re.DOTALL | re.IGNORECASE)
    print(f"Row count: {len(rows)}")
    for r_idx, row in enumerate(rows[:5]):
        cells = re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', row, re.DOTALL | re.IGNORECASE)
        clean_cells = [re.sub(r'<[^>]+>', '', c).strip() for c in cells]
        print(f"  Row {r_idx}: {clean_cells}")
