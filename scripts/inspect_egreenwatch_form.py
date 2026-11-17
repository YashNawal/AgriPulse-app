import re

with open('data/egreenwatch_sample.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Form details
form = re.search(r'<form[^>]*action=\"([^\"]*)\"[^>]*method=\"([^\"]*)\"', html, re.IGNORECASE)
if form:
    print(f"Form action: '{form.group(1)}', method: '{form.group(2)}'")

# Hidden inputs
hidden_inputs = re.findall(r'<input[^>]*type=\"hidden\"[^>]*name=\"([^\"]*)\"[^>]*value=\"([^\"]*)\"', html, re.IGNORECASE)
print(f"Hidden inputs count: {len(hidden_inputs)}")
for name, val in hidden_inputs:
    print(f"  {name}: {len(val)} chars (preview: {val[:30]}...)")

# Look at all state options in ddlState
states = re.findall(r'<option[^>]*value=\"([^\"]*)\"[^>]*>(.*?)</option>', html, re.DOTALL | re.IGNORECASE)
print(f"\nAll States in ddlState:")
for val, sname in states[:40]:
    sname = re.sub(r'<[^>]+>', '', sname).strip()
    if val != '0':
        print(f"  State ID {val}: {sname}")
