import re
from html.parser import HTMLParser

with open("data/mp_wikipedia_raw.html", "r", encoding="utf-8") as f:
    html = f.read()

# Let's inspect the sections in the page
headings = re.findall(r'<span class=\"mw-headline\" id=\"([^\"]*)\">(.*?)</span>', html)
print(f"Headings in page:")
for h_id, h_text in headings:
    print(f"  {h_id}: {h_text}")

# Check mentions of tehsil or taluka or sub-division
tehsil_matches = re.findall(r'(\b\w+\b\s+(?:tehsil|subdivision|sub-division|block|taluka)s?)', html, re.IGNORECASE)
print(f"\nTehsil/taluka phrases (first 20):", tehsil_matches[:20])

# Parse all 55 districts from Wikitable 1
# Let's use our RowspanTableParser to get all districts, headquarters, and divisions!
