"""
KisanMitra: build the location master (states, districts, sub-districts, villages, markets)
for the 20 target states from official Local Government Directory (LGD) CSV files.

Run (writes clean CSV files, nothing is uploaded):
  python import_locations.py --lgd-villages lgd_villages.csv --markets markets.csv --out out/

Optional:
  --subdistrict-geojson subdistricts.geojson   map markets to sub-districts by latitude/longitude
                                               (needs: pip install geopandas shapely)
  --upload                                     also upsert into Supabase (needs SUPABASE_URL and
                                               SUPABASE_SERVICE_ROLE_KEY in the environment)

Inputs
  lgd_villages.csv : the LGD "All villages of India" (or per state) download. It must contain
                     state, district, sub-district and village names and codes. Column names
                     are detected automatically (see CANDIDATES). Check the printed mapping.
  markets.csv      : columns state, district, market (and optional lat, lon). Build it from
                     the data.gov.in Agmarknet API or your markets table.
Not tested against the full real files. Run on one state first and read the report.
"""
import argparse, os, re, sys
import pandas as pd

TARGET_STATES = [
    "Uttar Pradesh", "Punjab", "Madhya Pradesh", "West Bengal", "Gujarat", "Maharashtra",
    "Rajasthan", "Karnataka", "Andhra Pradesh", "Haryana", "Bihar", "Tamil Nadu", "Telangana",
    "Chhattisgarh", "Odisha", "Assam", "Kerala", "Jharkhand", "Himachal Pradesh", "Sikkim",
]
ALIASES = {"orissa": "odisha"}

CANDIDATES = {
    "state_code": ["state_code", "state code", "statecode", "state_lgd_code"],
    "state_name": ["state_name", "state name", "state"],
    "district_code": ["district_code", "district code", "districtcode", "district_lgd_code"],
    "district_name": ["district_name", "district name", "district"],
    "sub_district_code": ["sub_district_code", "subdistrict_code", "sub district code", "subdistrictcode", "tehsil_code"],
    "sub_district_name": ["sub_district_name", "subdistrict_name", "sub district name", "subdistrictname", "tehsil_name"],
    "village_code": ["village_code", "village code", "villagecode", "village_lgd_code"],
    "village_name": ["village_name", "village name", "villagename", "village"],
}

states_global = None

def norm(s):
    s = str(s).lower().strip()
    s = re.sub(r"[^a-z0-9 ]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return ALIASES.get(s, s)

def pick_columns(df):
    low = {c.lower().strip(): c for c in df.columns}
    mapping, missing = {}, []
    for key, options in CANDIDATES.items():
        found = next((low[o] for o in options if o in low), None)
        if found: mapping[key] = found
        else: missing.append(key)
    print("Column mapping:", mapping)
    if missing:
        sys.exit(f"Could not find columns for {missing}. Columns in file: {list(df.columns)}\n"
                 "Edit CANDIDATES in this script to match.")
    return mapping

def build_hierarchy(path):
    global states_global
    df = pd.read_csv(path, dtype=str, low_memory=False).fillna("")
    m = pick_columns(df)
    df = df.rename(columns={v: k for k, v in m.items()})[list(m.keys())]
    targets = {norm(s) for s in TARGET_STATES}
    df["state_key"] = df["state_name"].map(norm)
    df = df[df["state_key"].isin(targets)].copy()
    states = df[["state_code", "state_name"]].drop_duplicates().sort_values("state_name")
    districts = df[["state_code", "district_code", "district_name"]].drop_duplicates().sort_values(["state_code", "district_name"])
    subs = df[["state_code", "district_code", "sub_district_code", "sub_district_name"]].drop_duplicates()
    villages = df[["state_code", "district_code", "sub_district_code", "village_code", "village_name"]].drop_duplicates()
    found = {norm(x) for x in states["state_name"]}
    for s in TARGET_STATES:
        if norm(s) not in found: print(f"WARNING: no rows found for {s}")
    states_global = states
    return states, districts, subs, villages

def map_markets(path, districts, subs, villages=None, geojson=None):
    mk = pd.read_csv(path, dtype=str).fillna("")
    mk.columns = [c.lower().strip() for c in mk.columns]
    for need in ("state", "district", "market"):
        if need not in mk.columns: sys.exit(f"markets file needs a '{need}' column")
    d = districts.copy()
    d["dkey"] = d["state_code"] + "|" + d["district_name"].map(norm)
    # state name -> code through the hierarchy file is not kept here, so match by district name inside state
    st = states_global.set_index(states_global["state_name"].map(norm))["state_code"].to_dict()
    mk["state_code"] = mk["state"].map(lambda x: st.get(norm(x), ""))
    mk["dkey"] = mk["state_code"] + "|" + mk["district"].map(norm)
    mk = mk.merge(d[["dkey", "district_code"]], on="dkey", how="left").drop(columns="dkey")
    mk["sub_district_code"] = ""
    mk["mapping_method"] = ""
    mk.loc[mk["district_code"].notna(), "mapping_method"] = "district_name_match"
    mk["market_key"] = mk["market"].map(norm)
    # sub-district from market name or village name inside the same district
    s = subs.copy(); s["skey"] = s["sub_district_name"].map(norm)
    lookup = {(r.district_code, r.skey): r.sub_district_code for r in s.itertuples()}
    v_lookup = {}
    if villages is not None:
        v = villages.copy(); v["vkey"] = v["village_name"].map(norm)
        for r in v.itertuples():
            v_lookup[(r.district_code, r.vkey)] = r.sub_district_code

    for i, r in mk.iterrows():
        dcode = r["district_code"]
        mkey = r["market_key"]
        code = lookup.get((dcode, mkey))
        if code:
            mk.at[i, "sub_district_code"], mk.at[i, "mapping_method"] = code, "name_match_taluka"
        elif v_lookup:
            # Check direct village name match or partial match
            vcode = v_lookup.get((dcode, mkey))
            if not vcode:
                # check if market name contains village name
                for (d_c, v_k), s_c in v_lookup.items():
                    if d_c == dcode and (v_k in mkey or mkey in v_k):
                        vcode = s_c
                        break
            if vcode:
                mk.at[i, "sub_district_code"], mk.at[i, "mapping_method"] = vcode, "name_match_village"
    if geojson and {"lat", "lon"} <= set(mk.columns):
        import geopandas as gpd
        from shapely.geometry import Point
        gdf = gpd.read_file(geojson)
        print("GeoJSON columns:", list(gdf.columns), "<- set SUBDIST_CODE_FIELD below if needed")
        field = os.environ.get("SUBDIST_CODE_FIELD", "sub_district_code")
        pts = gpd.GeoDataFrame(mk[mk["lat"] != ""].copy(), geometry=[Point(float(a), float(b)) for a, b in zip(mk.loc[mk["lat"] != "", "lon"], mk.loc[mk["lat"] != "", "lat"])], crs="EPSG:4326")
        joined = gpd.sjoin(pts, gdf.to_crs("EPSG:4326"), how="left", predicate="within")
        for idx, row in joined.iterrows():
            if field in joined.columns and pd.notna(row.get(field)):
                mk.at[idx, "sub_district_code"], mk.at[idx, "mapping_method"] = str(row[field]), "boundary_polygon"
    mk["needs_review"] = (mk["district_code"].isna() | (mk["sub_district_code"] == "")).map({True: "yes", False: "no"})
    return mk.drop(columns=["market_key"])

def upload(tables):
    from supabase import create_client
    sb = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_ROLE_KEY"])
    for name, df in tables.items():
        rows = df.where(df.notna(), None).to_dict("records")
        for i in range(0, len(rows), 1000):
            sb.table(name).upsert(rows[i:i + 1000]).execute()
        print("uploaded", name, len(rows))

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--lgd-villages", required=True)
    ap.add_argument("--markets")
    ap.add_argument("--subdistrict-geojson")
    ap.add_argument("--out", default="out")
    ap.add_argument("--upload", action="store_true")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    states, districts, subs, villages = build_hierarchy(a.lgd_villages)
    tables = {"states": states, "districts": districts, "sub_districts": subs, "villages": villages}
    if a.markets:
        tables["markets_mapped"] = map_markets(a.markets, districts, subs, villages, a.subdistrict_geojson)
    for n, df in tables.items():
        df.to_csv(os.path.join(a.out, f"{n}.csv"), index=False, encoding="utf-8")
    print("\nREPORT")
    cnt = villages.groupby("state_code").size().rename("villages")
    rep = states.set_index("state_code").join(districts.groupby("state_code").size().rename("districts")).join(subs.groupby("state_code").size().rename("sub_districts")).join(cnt)
    print(rep.to_string())
    if "markets_mapped" in tables:
        mm = tables["markets_mapped"]
        print(f"\nMarkets: {len(mm)}; need review: {(mm['needs_review']=='yes').sum()}")
    if a.upload:
        upload({k: v for k, v in tables.items() if k != "markets_mapped"})
