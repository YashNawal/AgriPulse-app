import urllib.request
import urllib.parse
import ssl
import re
import csv
import json
import time

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

def get_input_val(name, text):
    m = re.search(r'name=\"' + re.escape(name) + r'\"[^>]*value=\"([^\"]*)\"', text)
    return m.group(1) if m else ''

def parse_tehsil_rows(html):
    records = []
    table = re.search(r'<table[^>]*id="ctl00_ctl00_dpPH_dpPH_gvTehsil"[^>]*>(.*?)</table>', html, re.DOTALL | re.IGNORECASE)
    if not table:
        return records, []

    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table.group(1), re.DOTALL | re.IGNORECASE)
    # Header is row 0. Last row might be pager row if it contains <td><span class="ui-widget"> or <table
    data_rows = rows[1:]
    pager_targets = []

    if data_rows and ('<table' in data_rows[-1] or 'Page$' in data_rows[-1]):
        pager_row = data_rows.pop()
        # Find all page arguments: e.g. Page$2, Page$3, etc.
        p_matches = re.findall(r"__doPostBack\(&#39;ctl00\$ctl00\$dpPH\$dpPH\$gvTehsil&#39;,&#39;(Page\$[^&#]+)&#39;\)", pager_row)
        pager_targets = p_matches

    for r in data_rows:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.DOTALL | re.IGNORECASE)]
        # ['S.n.', 'State', 'District', 'Tehsil', 'Tehsil Name( LL)', 'NIC Tehsil Code']
        if len(cells) >= 6:
            records.append({
                'sn': cells[0],
                'state': cells[1],
                'district': cells[2],
                'tehsil': cells[3].title(),
                'tehsil_ll': cells[4],
                'nic_code': cells[5],
            })
    return records, pager_targets

def fetch_state_tehsils(state_id='20'):
    # 1. GET initial page
    req = urllib.request.Request(base_url, headers=headers)
    resp = opener.open(req, timeout=20)
    html = resp.read().decode('utf-8', errors='ignore')

    # 2. POST to select state
    post_data = {
        '__EVENTTARGET': 'ctl00$ctl00$dpPH$dpPH$ddlState',
        '__EVENTARGUMENT': '',
        '__LASTFOCUS': '',
        '__VIEWSTATE': get_input_val('__VIEWSTATE', html),
        '__VIEWSTATEGENERATOR': get_input_val('__VIEWSTATEGENERATOR', html),
        '__SCROLLPOSITIONX': '0',
        '__SCROLLPOSITIONY': '0',
        '__VIEWSTATEENCRYPTED': '',
        'ctl00$ctl00$dpPH$dpPH$ddlState': str(state_id),
        'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
        'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
    }
    if get_input_val('__EVENTVALIDATION', html):
        post_data['__EVENTVALIDATION'] = get_input_val('__EVENTVALIDATION', html)

    encoded = urllib.parse.urlencode(post_data).encode('utf-8')
    resp2 = opener.open(urllib.request.Request(base_url, data=encoded, headers=headers), timeout=25)
    html2 = resp2.read().decode('utf-8', errors='ignore')

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
        'ctl00$ctl00$dpPH$dpPH$ddlState': str(state_id),
        'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
        'ctl00$ctl00$dpPH$dpPH$btnSearch': 'View Tehsils',
        'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
    }
    if get_input_val('__EVENTVALIDATION', html2):
        post_data_search['__EVENTVALIDATION'] = get_input_val('__EVENTVALIDATION', html2)

    encoded_search = urllib.parse.urlencode(post_data_search).encode('utf-8')
    resp3 = opener.open(urllib.request.Request(base_url, data=encoded_search, headers=headers), timeout=30)
    current_html = resp3.read().decode('utf-8', errors='ignore')

    all_records = []
    visited_pages = set(['Page$1'])

    records, pager_targets = parse_tehsil_rows(current_html)
    all_records.extend(records)
    print(f"Page 1: parsed {len(records)} tehsils. Pager targets: {pager_targets}")

    # Process all remaining pages
    pending_pages = [p for p in pager_targets if p not in visited_pages]
    while pending_pages:
        target_page = pending_pages.pop(0)
        visited_pages.add(target_page)
        print(f"Fetching {target_page}...")

        post_data_page = {
            '__EVENTTARGET': 'ctl00$ctl00$dpPH$dpPH$gvTehsil',
            '__EVENTARGUMENT': target_page,
            '__LASTFOCUS': '',
            '__VIEWSTATE': get_input_val('__VIEWSTATE', current_html),
            '__VIEWSTATEGENERATOR': get_input_val('__VIEWSTATEGENERATOR', current_html),
            '__SCROLLPOSITIONX': '0',
            '__SCROLLPOSITIONY': '0',
            '__VIEWSTATEENCRYPTED': '',
            'ctl00$ctl00$dpPH$dpPH$ddlState': str(state_id),
            'ctl00$ctl00$dpPH$dpPH$ddlDistrict': '0',
            'ctl00$ctl00$dpPH$dpPH$hdnTehsilID': '0',
        }
        if get_input_val('__EVENTVALIDATION', current_html):
            post_data_page['__EVENTVALIDATION'] = get_input_val('__EVENTVALIDATION', current_html)

        encoded_page = urllib.parse.urlencode(post_data_page).encode('utf-8')
        resp_p = opener.open(urllib.request.Request(base_url, data=encoded_page, headers=headers), timeout=30)
        current_html = resp_p.read().decode('utf-8', errors='ignore')

        page_records, new_targets = parse_tehsil_rows(current_html)
        all_records.extend(page_records)
        print(f"  {target_page}: +{len(page_records)} tehsils (Total: {len(all_records)})")

        for nt in new_targets:
            if nt not in visited_pages and nt not in pending_pages:
                pending_pages.append(nt)

        time.sleep(0.5)

    return all_records

if __name__ == '__main__':
    print("Fetching Madhya Pradesh (State ID 20)...")
    mp_records = fetch_state_tehsils('20')
    print(f"\nCompleted! Total tehsils fetched: {len(mp_records)}")

    # Group by district
    hierarchy = {}
    for r in mp_records:
        dist = r['district'].strip().title()
        teh = r['tehsil'].strip().title()
        if dist not in hierarchy:
            hierarchy[dist] = []
        if teh not in hierarchy[dist]:
            hierarchy[dist].append(teh)

    print(f"Total Districts: {len(hierarchy)}")
    for d, t_list in sorted(hierarchy.items()):
        print(f"  {d}: {len(t_list)} tehsils: {t_list[:6]}")

    # Save to CSV and JSON
    with open('out/egreenwatch_mp_tehsils.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['sn', 'state', 'district', 'tehsil', 'tehsil_ll', 'nic_code'])
        writer.writeheader()
        writer.writerows(mp_records)

    with open('data/madhya_pradesh_hierarchy.json', 'w', encoding='utf-8') as f:
        json.dump(hierarchy, f, indent=2, ensure_ascii=False)

    print("Saved out/egreenwatch_mp_tehsils.csv and data/madhya_pradesh_hierarchy.json")
