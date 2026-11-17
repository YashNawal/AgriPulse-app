import re

with open('data/egreenwatch_mp_search.html', 'r', encoding='utf-8') as f:
    html = f.read()

table = re.search(r'<table[^>]*id="ctl00_ctl00_dpPH_dpPH_gvTehsil"[^>]*>(.*?)</table>', html, re.DOTALL | re.IGNORECASE)
if table:
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table.group(1), re.DOTALL | re.IGNORECASE)
    print("Total rows:", len(rows))
    print("Last row:", rows[-1][:300])
    # Find all pager links
    links = re.findall(r'<a[^>]*href=\"([^\"]*)\"[^>]*>(.*?)</a>', rows[-1])
    print(f"Pager links ({len(links)}):")
    for href, text in links:
        print(f"  Text: '{text}' -> Href: '{href}'")
