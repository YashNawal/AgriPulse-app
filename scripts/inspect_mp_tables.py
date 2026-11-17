import re
from html.parser import HTMLParser

filepath = r"C:\Users\yashs\.gemini\antigravity-ide\brain\bd0a1f26-8d0f-4504-bfac-9a89eb8887ea\.system_generated\steps\687\content.md"

with open(filepath, "r", encoding="utf-8") as f:
    html = f.read()

# Find wikitable
table_matches = re.findall(r'<table[^>]*wikitable[^>]*>(.*?)</table>', html, re.DOTALL | re.IGNORECASE)
print(f"Found {len(table_matches)} wikitables.")

for i, t in enumerate(table_matches):
    headers = re.findall(r'<th[^>]*>(.*?)</th>', t, re.DOTALL | re.IGNORECASE)
    clean_h = [re.sub(r'<[^>]+>', '', h).strip() for h in headers]
    print(f"Table {i+1} headers: {clean_h[:8]}")
