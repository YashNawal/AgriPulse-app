import re

with open('data/egreenwatch_mp.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Find buttons and inputs with type submit/button
buttons = re.findall(r'<input[^>]*type=[\"\'](submit|button)[\"\'][^>]*>', html, re.IGNORECASE)
print(f"Submit/button inputs: {len(buttons)}")
for b in buttons:
    print(" ", b)

all_inputs = re.findall(r'<input[^>]*>', html)
for inp in all_inputs:
    name_m = re.search(r'name=[\"\']([^\"\']*)[\"\']', inp)
    val_m = re.search(r'value=[\"\']([^\"\']*)[\"\']', inp)
    type_m = re.search(r'type=[\"\']([^\"\']*)[\"\']', inp)
    print(f"Input: type={type_m.group(1) if type_m else 'text'}, name={name_m.group(1) if name_m else ''}, value={val_m.group(1) if val_m else ''}")

# Check onchange on ddlDistrict
select_district = re.search(r'<select[^>]*name=[\"\']ctl00\$ctl00\$dpPH\$dpPH\$ddlDistrict[\"\'][^>]*>', html)
if select_district:
    print(f"\nSelect ddlDistrict tag: {select_district.group(0)}")

# Check onchange on ddlState
select_state = re.search(r'<select[^>]*name=[\"\']ctl00\$ctl00\$dpPH\$dpPH\$ddlState[\"\'][^>]*>', html)
if select_state:
    print(f"Select ddlState tag: {select_state.group(0)}")
