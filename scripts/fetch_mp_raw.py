import urllib.request
import re
from html.parser import HTMLParser

url = "https://en.wikipedia.org/wiki/List_of_districts_of_Madhya_Pradesh"
req = urllib.request.Request(
    url,
    headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
)

with urllib.request.urlopen(req) as resp:
    html = resp.read().decode("utf-8")

with open("data/mp_wikipedia_raw.html", "w", encoding="utf-8") as f:
    f.write(html)

print(f"Downloaded {len(html)} bytes to data/mp_wikipedia_raw.html")

# Find table classes and headings
tables = re.findall(r'<table[^>]*class=\"([^\"]*)\"[^>]*>', html)
print(f"Found {len(tables)} tables with classes:")
for c in tables:
    print(" -", c)
