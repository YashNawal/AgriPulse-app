import re

with open('data/egreenwatch_sample.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Select dropdowns
selects = re.findall(r'<select[^>]*name=\"([^\"]*)\"[^>]*>(.*?)</select>', html, re.DOTALL | re.IGNORECASE)
print(f"Select dropdowns: {len(selects)}")
for name, options_html in selects:
    options = re.findall(r'<option[^>]*value=\"([^\"]*)\"[^>]*>(.*?)</option>', options_html, re.DOTALL | re.IGNORECASE)
    clean_options = [(val, re.sub(r'<[^>]+>', '', text).strip()) for val, text in options]
    print(f"\nDropdown '{name}' ({len(clean_options)} options):")
    for val, text in clean_options[:15]:
        print(f"   value='{val}' -> '{text}'")

# Check tables or gridviews
tables = re.findall(r'<table[^>]*id=\"([^\"]*)\"[^>]*>(.*?)</table>', html, re.DOTALL | re.IGNORECASE)
print(f"\nTables with id count: {len(tables)}")
for t_id, t_content in tables:
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', t_content, re.DOTALL | re.IGNORECASE)
    print(f"\nTable id='{t_id}' (rows: {len(rows)}):")
    for r in rows[:5]:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.DOTALL | re.IGNORECASE)]
        print("   ", cells)
