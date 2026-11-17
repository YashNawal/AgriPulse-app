import urllib.request
import urllib.parse
import ssl
import re

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_url = 'https://egreenwatch.nic.in/Masters/Public/TehsilView.aspx?SID=10%2f1000'
cookie_handler = urllib.request.HTTPCookieProcessor()
opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx), cookie_handler)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Origin': 'https://egreenwatch.nic.in',
    'Referer': base_url,
}

# 1. GET initial page to extract tokens and cookie
req = urllib.request.Request(base_url, headers=headers)
resp = opener.open(req, timeout=20)
html = resp.read().decode('utf-8', errors='ignore')

def get_input_val(name, text):
    m = re.search(r'name=\"' + re.escape(name) + r'\"[^>]*value=\"([^\"]*)\"', text)
    return m.group(1) if m else ''

viewstate = get_input_val('__VIEWSTATE', html)
viewstategenerator = get_input_val('__VIEWSTATEGENERATOR', html)
eventvalidation = get_input_val('__EVENTVALIDATION', html)

print(f"Initial GET successful. ViewState length: {len(viewstate)}")

# 2. POST with State = 20 (Madhya Pradesh)
post_data = {
    '__EVENTTARGET': 'ctl00$ctl00$dpPH$dpPH$ddlState',
    '__EVENTARGUMENT': '',
    '__LASTFOCUS': '',
    '__VIEWSTATE': viewstate,
    '__VIEWSTATEGENERATOR': viewstategenerator,
    '__SCROLLPOSITIONX': '0',
    '__SCROLLPOSITIONY': '0',
    '__VIEWSTATEENCRYPTED': '',
    'ctl00$ctl00$dpPH$dpPH$ddlState': '20', # Madhya Pradesh
    'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
    'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
}
if eventvalidation:
    post_data['__EVENTVALIDATION'] = eventvalidation

encoded_data = urllib.parse.urlencode(post_data).encode('utf-8')
post_req = urllib.request.Request(base_url, data=encoded_data, headers=headers)

resp2 = opener.open(post_req, timeout=25)
html2 = resp2.read().decode('utf-8', errors='ignore')

with open('data/egreenwatch_mp.html', 'w', encoding='utf-8') as f:
    f.write(html2)

print(f"POST for Madhya Pradesh succeeded. Length: {len(html2)}")

# Parse districts dropdown in MP
districts = re.findall(r'<select[^>]*name=\"ctl00\$ctl00\$dpPH\$dpPH\$ddlDistrict\"[^>]*>(.*?)</select>', html2, re.DOTALL | re.IGNORECASE)
if districts:
    d_opts = re.findall(r'<option[^>]*value=\"([^\"]*)\"[^>]*>(.*?)</option>', districts[0], re.DOTALL | re.IGNORECASE)
    print(f"\nMadhya Pradesh has {len(d_opts)-1} districts in ddlDistrict:")
    for val, name in d_opts[1:]:
        print(f"  ID {val}: {name.strip()}")

# Parse table rows in MP
table = re.search(r'<table[^>]*id=\"ctl00_ctl00_dpPH_dpPH_gvTehsil\"[^>]*>(.*?)</table>', html2, re.DOTALL | re.IGNORECASE)
if table:
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table.group(1), re.DOTALL | re.IGNORECASE)
    print(f"\nTable rows for Madhya Pradesh: {len(rows)}")
    for r in rows[:10]:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.DOTALL | re.IGNORECASE)]
        print("   ", cells)
