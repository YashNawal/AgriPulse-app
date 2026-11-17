import re

with open("data/mp_wikipedia_raw.html", "r", encoding="utf-8") as f:
    html = f.read()

# Strip HTML tags from introductory paragraphs
paragraphs = re.findall(r'<p>(.*?)</p>', html, re.DOTALL)
for p in paragraphs[:5]:
    clean = re.sub(r'<[^>]+>', '', p).strip()
    if clean:
        print("P:", clean)
        print("-" * 50)
