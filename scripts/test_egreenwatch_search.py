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

# 1. GET initial page
req = urllib.request.Request(base_url, headers=headers)
resp = opener.open(req, timeout=20)
html = resp.read().decode('utf-8', errors='ignore')

def get_input_val(name, text):
    m = re.search(r'name=\"' + re.escape(name) + r'\"[^>]*value=\"([^\"]*)\"', text)
    return m.group(1) if m else ''

# 2. Select State = 20 (Madhya Pradesh)
post_data = {
    '__EVENTTARGET': 'ctl00$ctl00$dpPH$dpPH$ddlState',
    '__EVENTARGUMENT': '',
    '__LASTFOCUS': '',
    '__VIEWSTATE': get_input_val('__VIEWSTATE', html),
    '__VIEWSTATEGENERATOR': get_input_val('__VIEWSTATEGENERATOR', html),
    '__SCROLLPOSITIONX': '0',
    '__SCROLLPOSITIONY': '0',
    '__VIEWSTATEENCRYPTED': '',
    'ctl00$ctl00$dpPH$dpPH$ddlState': '20', # MP
    'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
    'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
}
if get_input_val('__EVENTVALIDATION', html):
    post_data['__EVENTVALIDATION'] = get_input_val('__EVENTVALIDATION', html)

encoded = urllib.parse.urlencode(post_data).encode('utf-8')
resp2 = opener.open(urllib.request.Request(base_url, data=encoded, headers=headers), timeout=25)
html2 = resp2.read().decode('utf-8', errors='ignore')

print("State selected. Now clicking 'View Tehsils' with ddlDistrict='0'...")

# 3. Click btnSearch
post_data_search = {
    '__EVENTTARGET': '',
    '__EVENTARGUMENT': '',
    '__LASTFOCUS': '',
    '__VIEWSTATE': get_input_val('__VIEWSTATE', html2),
    '__VIEWSTATEGENERATOR': get_input_val('__VIEWSTATEGENERATOR', html2),
    '__SCROLLPOSITIONX': '0',
    '__SCROLLPOSITIONY': '0',
    '__VIEWSTATEENCRYPTED': '',
    'ctl00$ctl00$dpPH$dpPH$ddlState': '20',
    'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
    'ctl00$ctl00$dpPH$dpPH$btnSearch': 'View Tehsils',
    'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
}
if get_input_val('__EVENTVALIDATION', html2):
    post_data_search['__EVENTVALIDATION'] = get_input_val('__EVENTVALIDATION', html2)

encoded_search = urllib.parse.urlencode(post_data_search).encode('utf-8')
resp3 = opener.open(urllib.request.Request(base_url, data=encoded_search, headers=headers), timeout=30)
html3 = resp3.read().decode('utf-8', errors='ignore')

with open('data/egreenwatch_mp_search.html', 'w', encoding='utf-8') as f:
    f.write(html3)

table = re.search(r'<table[^>]*id=\"ctl00_ctl00_dpPH_dpPH_gvTehsil\"[^>]*>(.*?)</table>', html3, re.DOTALL | re.IGNORECASE)
if table:
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table.group(1), re.DOTALL | re.IGNORECASE)
    print(f"\nResult rows count: {len(rows)}")
    for r in rows[:15]:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.DOTALL | re.IGNORECASE)]
        print("   ", cells)
else:
    print("Table not found in html3.")
