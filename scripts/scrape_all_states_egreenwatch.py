"""
Scrapes official District, Taluka/Tehsil master for all states of India from:
https://egreenwatch.nic.in/Masters/Public/TehsilView.aspx?SID=10%2f1000

Outputs:
  - out/egreenwatch_all_india_tehsils.csv
  - data/all_states_hierarchy.json
"""
import urllib.request
import urllib.parse
import ssl
import re
import csv
import json
import time
import os

os.makedirs('data', exist_ok=True)
os.makedirs('out', exist_ok=True)

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_url = 'https://egreenwatch.nic.in/Masters/Public/TehsilView.aspx?SID=10%2f1000'

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
    data_rows = rows[1:]
    pager_targets = []

    if data_rows and ('<table' in data_rows[-1] or 'Page$' in data_rows[-1]):
        pager_row = data_rows.pop()
        p_matches = re.findall(r"__doPostBack\(&#39;ctl00\$ctl00\$dpPH\$dpPH\$gvTehsil&#39;,&#39;(Page\$[^&#]+)&#39;\)", pager_row)
        pager_targets = p_matches

    for r in data_rows:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.DOTALL | re.IGNORECASE)]
        if len(cells) >= 6:
            records.append({
                'sn': cells[0],
                'state': cells[1],
                'district': cells[2].strip().title().replace(' *', ''),
                'tehsil': cells[3].strip().title(),
                'tehsil_ll': cells[4].strip(),
                'nic_code': cells[5].strip(),
            })
    return records, pager_targets

def scrape_state(opener, state_id, state_name):
    print(f"\n--- Scraping [{state_id}] {state_name} ---")
    try:
        # GET initial page
        req = urllib.request.Request(base_url, headers=headers)
        resp = opener.open(req, timeout=20)
        html = resp.read().decode('utf-8', errors='ignore')

        # POST select state
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

        # Click View Tehsils
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
        print(f"  Page 1: {len(records)} tehsils (pager: {len(pager_targets)} pages)")

        pending_pages = [p for p in pager_targets if p not in visited_pages]
        while pending_pages:
            target_page = pending_pages.pop(0)
            visited_pages.add(target_page)

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

            for nt in new_targets:
                if nt not in visited_pages and nt not in pending_pages:
                    pending_pages.append(nt)

            time.sleep(0.3)

        print(f"  Finished {state_name}: Total {len(all_records)} tehsils.")
        return all_records
    except Exception as e:
        print(f"  Error scraping {state_name}: {e}")
        return []

def main():
    cookie_handler = urllib.request.HTTPCookieProcessor()
    opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx), cookie_handler)

    # 1. First get all states list from initial page
    req = urllib.request.Request(base_url, headers=headers)
    resp = opener.open(req, timeout=20)
    init_html = resp.read().decode('utf-8', errors='ignore')

    state_select = re.search(r'<select[^>]*name=\"ctl00\$ctl00\$dpPH\$dpPH\$ddlState\"[^>]*>(.*?)</select>', init_html, re.DOTALL | re.IGNORECASE)
    state_options = re.findall(r'<option[^>]*value=\"([^\"]*)\"[^>]*>(.*?)</option>', state_select.group(1), re.DOTALL | re.IGNORECASE) if state_select else []

    states_to_scrape = [(val, re.sub(r'<[^>]+>', '', name).strip()) for val, name in state_options if val != '0']
    print(f"Found {len(states_to_scrape)} States & UTs on eGreenWatch:")
    for s_id, s_name in states_to_scrape:
        print(f"  [{s_id}] {s_name}")

    all_india_records = []
    hierarchy = {}

    for s_id, s_name in states_to_scrape:
        state_opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx), urllib.request.HTTPCookieProcessor())
        records = scrape_state(state_opener, s_id, s_name)
        all_india_records.extend(records)

        # Build hierarchy: state -> district -> [tehsils]
        if s_name not in hierarchy:
            hierarchy[s_name] = {}
        for r in records:
            d = r['district']
            t = r['tehsil']
            if d not in hierarchy[s_name]:
                hierarchy[s_name][d] = []
            if t not in hierarchy[s_name][d]:
                hierarchy[s_name][d].append(t)

        time.sleep(0.5)

    # Write all india tehsils CSV
    csv_file = 'out/egreenwatch_all_india_tehsils.csv'
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['sn', 'state', 'district', 'tehsil', 'tehsil_ll', 'nic_code'])
        writer.writeheader()
        writer.writerows(all_india_records)

    # Write all states hierarchy JSON
    json_file = 'data/all_states_hierarchy.json'
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(hierarchy, f, indent=2, ensure_ascii=False)

    print(f"\n==========================================")
    print(f"SUCCESS: Scraped {len(all_india_records)} tehsils across {len(hierarchy)} states & UTs!")
    print(f"Saved to {csv_file} and {json_file}")
    print(f"==========================================")

if __name__ == '__main__':
    main()
