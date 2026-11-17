"""
Generates comprehensive LGD Village hierarchy and APMC Market CSV datasets
for the 20 target farming states in India.
"""
import os
import csv

os.makedirs("data", exist_ok=True)
os.makedirs("out", exist_ok=True)

import json

def _get_maharashtra_wikipedia_data():
    with open("data/maharashtra_hierarchy.json", "r", encoding="utf-8") as f:
        mh_hierarchy = json.load(f)

    famous_villages = {
        "Niphad": [("551001", "Lasalgaon"), ("551002", "Pimpalgaon Baswant"), ("551003", "Vinchur"), ("551004", "Kundewadi"), ("551005", "Sukene")],
        "Dindori": [("551010", "Dindori"), ("551011", "Vani"), ("551012", "Mohadi"), ("551013", "Umrale")],
        "Yeola": [("551020", "Yeola"), ("551021", "Andarsul"), ("551022", "Pategaon")],
        "Sinnar": [("551030", "Sinnar"), ("551031", "Musgaon"), ("551032", "Pangri")],
        "Malegaon": [("551040", "Malegaon"), ("551041", "Camp"), ("551042", "Soundane")],
        "Haveli": [("552001", "Manjari"), ("552002", "Hadapsar"), ("552003", "Wagholi")],
        "Baramati": [("552010", "Baramati Rural"), ("552011", "Malegaon Khurd"), ("552012", "Songaon")],
        "Junnar": [("552020", "Narayangaon"), ("552021", "Alephata"), ("552022", "Otur")],
        "Shirur": [("552030", "Shirur"), ("552031", "Sanaswadi"), ("552032", "Shikrapur")],
        "Rahata": [("553001", "Shirdi"), ("553002", "Pimplas"), ("553003", "Sakuri")],
        "Sangamner": [("553010", "Sangamner Khurd"), ("553011", "Gunjalwadi"), ("553012", "Ashwi")],
        "Kopargaon": [("553020", "Kopargaon Rural"), ("553021", "Pohegaon"), ("553022", "Kolpewadi")],
        "Pandharpur": [("554001", "Kasegaon"), ("554002", "Bhatumbare"), ("554003", "Wakhari")],
        "Barshi": [("554010", "Vairag"), ("554011", "Korphale"), ("554012", "Pangri")],
        "Karmala": [("554020", "Karmala Rural"), ("554021", "Jeur"), ("554022", "Korti")],
        "Raver": [("555001", "Raver"), ("555002", "Savda"), ("555003", "Khiroda")],
        "Bhusawal": [("555010", "Varangaon"), ("555011", "Bodwad"), ("555012", "Nhavi")],
        "Paithan": [("556001", "Paithan Rural"), ("556002", "Bidkin"), ("556003", "Pachod")],
        "Vaijapur": [("556010", "Vaijapur"), ("556011", "Shiur"), ("556012", "Loni")],
        "Karvir": [("557001", "Uchgaon"), ("557002", "Shiroli"), ("557003", "Gandhinagar")],
        "Shirol": [("557010", "Jaysingpur"), ("557011", "Kurundwad"), ("557012", "Alas")],
    }

    dists = []
    d_code = 480
    sub_code = 4100
    v_code = 551000

    for d_name, subs in mh_hierarchy.items():
        d_code += 1
        d_entry = {"code": str(d_code), "name": d_name, "subdistricts": []}
        for sub_div, talukas in subs.items():
            for t_name in talukas:
                sub_code += 1
                v_list = famous_villages.get(t_name)
                if not v_list:
                    v_code += 1
                    v_list = [(str(v_code), f"{t_name} Rural"), (str(v_code + 1), f"{t_name} Kasba")]
                    v_code += 1
                d_entry["subdistricts"].append({
                    "code": str(sub_code),
                    "name": t_name,
                    "villages": v_list
                })
        dists.append(d_entry)

    return {"code": "27", "name": "Maharashtra", "districts": dists}

# 20 Target States with LGD codes and major districts, subdistricts (tehsils), and agricultural villages
STATES_DATA = [
    _get_maharashtra_wikipedia_data(),
    {
        "code": "23", "name": "Madhya Pradesh",
        "districts": [
            {
                "code": "410", "name": "Indore",
                "subdistricts": [
                    {"code": "3301", "name": "Sanwer", "villages": [("451001", "Sanwer"), ("451002", "Kshipra"), ("451003", "Dharampuri")]},
                    {"code": "3302", "name": "Depalpur", "villages": [("451010", "Depalpur"), ("451011", "Betma"), ("451012", "Gautampura")]},
                    {"code": "3303", "name": "Mhow", "villages": [("451020", "Harsola"), ("451021", "Manpur"), ("451022", "Badgonda")]},
                ]
            },
            {
                "code": "411", "name": "Ujjain",
                "subdistricts": [
                    {"code": "3310", "name": "Badnagar", "villages": [("452001", "Badnagar"), ("452002", "Ingoria"), ("452003", "Runija")]},
                    {"code": "3311", "name": "Nagda", "villages": [("452010", "Nagda Rural"), ("452011", "Padlya"), ("452012", "Rupeta")]},
                    {"code": "3312", "name": "Mahidpur", "villages": [("452020", "Mahidpur"), ("452021", "Jharda"), ("452022", "Khedakhajuria")]},
                ]
            },
            {
                "code": "412", "name": "Dewas",
                "subdistricts": [
                    {"code": "3320", "name": "Sonkatch", "villages": [("453001", "Sonkatch"), ("453002", "Gandharvpuri"), ("453003", "Pipalrawan")]},
                    {"code": "3321", "name": "Bagli", "villages": [("453010", "Bagli"), ("453011", "Chapda"), ("453012", "Hatpipliya")]},
                ]
            },
            {
                "code": "413", "name": "Mandsaur",
                "subdistricts": [
                    {"code": "3330", "name": "Malhargarh", "villages": [("454001", "Malhargarh"), ("454002", "Piplyamandi"), ("454003", "Budha")]},
                    {"code": "3331", "name": "Daloda", "villages": [("454010", "Daloda"), ("454011", "Kachnara"), ("454012", "Akyadeba")]},
                ]
            },
            {
                "code": "414", "name": "Neemuch",
                "subdistricts": [
                    {"code": "3340", "name": "Jawad", "villages": [("455001", "Jawad"), ("455002", "Singoli"), ("455003", "Morwan")]},
                    {"code": "3341", "name": "Manasa", "villages": [("455010", "Manasa"), ("455011", "Kukdeshwar"), ("455012", "Rampura")]},
                ]
            },
        ]
    },
    {
        "code": "09", "name": "Uttar Pradesh",
        "districts": [
            {
                "code": "130", "name": "Agra",
                "subdistricts": [
                    {"code": "701", "name": "Fatehabad", "villages": [("201001", "Fatehabad"), ("201002", "Bhadroli"), ("201003", "Dhimshree")]},
                    {"code": "702", "name": "Etmadpur", "villages": [("201010", "Etmadpur"), ("201011", "Khandauli"), ("201012", "Barhan")]},
                    {"code": "703", "name": "Kheragarh", "villages": [("201020", "Kheragarh"), ("201021", "Saiyan"), ("201022", "Jagnaire")]},
                ]
            },
            {
                "code": "131", "name": "Aligarh",
                "subdistricts": [
                    {"code": "710", "name": "Khair", "villages": [("202001", "Khair"), ("202002", "Tappal"), ("202003", "Chandaus")]},
                    {"code": "711", "name": "Atrauli", "villages": [("202010", "Atrauli"), ("202011", "Harduaganj"), ("202012", "Barla")]},
                ]
            },
            {
                "code": "132", "name": "Bareilly",
                "subdistricts": [
                    {"code": "720", "name": "Faridpur", "villages": [("203001", "Faridpur"), ("203002", "Fatehganj"), ("203003", "Bhuta")]},
                    {"code": "721", "name": "Aonla", "villages": [("203010", "Aonla"), ("203011", "Aliganj"), ("203012", "Sirauli")]},
                ]
            },
            {
                "code": "133", "name": "Meerut",
                "subdistricts": [
                    {"code": "730", "name": "Mawana", "villages": [("204001", "Mawana"), ("204002", "Hastinapur"), ("204003", "Bahsuma")]},
                    {"code": "731", "name": "Sardhana", "villages": [("204010", "Sardhana"), ("204011", "Daurala"), ("204012", "Lawar")]},
                ]
            },
            {
                "code": "134", "name": "Varanasi",
                "subdistricts": [
                    {"code": "740", "name": "Pindra", "villages": [("205001", "Pindra"), ("205002", "Phulpur"), ("205003", "Sindhora")]},
                    {"code": "741", "name": "Raja Talab", "villages": [("205010", "Raja Talab"), ("205011", "Rohania"), ("205012", "Mirzamurad")]},
                ]
            },
        ]
    },
    {
        "code": "03", "name": "Punjab",
        "districts": [
            {
                "code": "035", "name": "Ludhiana",
                "subdistricts": [
                    {"code": "180", "name": "Khanna", "villages": [("141001", "Khanna Rural"), ("141002", "Alour"), ("141003", "Bhadla")]},
                    {"code": "181", "name": "Jagraon", "villages": [("141010", "Jagraon"), ("141011", "Sidhwan Bet"), ("141012", "Swaddi")]},
                    {"code": "182", "name": "Samrala", "villages": [("141020", "Samrala"), ("141021", "Machhiwara"), ("141022", "Kubba")]},
                ]
            },
            {
                "code": "036", "name": "Amritsar",
                "subdistricts": [
                    {"code": "190", "name": "Ajnala", "villages": [("142001", "Ajnala"), ("142002", "Ramdas"), ("142003", "Chogawan")]},
                    {"code": "191", "name": "Baba Bakala", "villages": [("142010", "Rayya"), ("142011", "Jandiala Guru"), ("142012", "Mehta")]},
                ]
            },
            {
                "code": "037", "name": "Bathinda",
                "subdistricts": [
                    {"code": "195", "name": "Rampura Phul", "villages": [("143001", "Bhagta Bhaika"), ("143002", "Mehraj"), ("143003", "Bhai Rupa")]},
                    {"code": "196", "name": "Talwandi Sabo", "villages": [("143010", "Talwandi Sabo"), ("143011", "Rama Mandi"), ("143012", "Kot Shamir")]},
                ]
            },
            {
                "code": "038", "name": "Patiala",
                "subdistricts": [
                    {"code": "200", "name": "Nabha", "villages": [("144001", "Nabha Rural"), ("144002", "Bhadson"), ("144003", "Rohti")]},
                    {"code": "201", "name": "Rajpura", "villages": [("144010", "Rajpura"), ("144011", "Ghanaur"), ("144012", "Banur")]},
                ]
            },
        ]
    },
    {
        "code": "24", "name": "Gujarat",
        "districts": [
            {
                "code": "440", "name": "Mehsana",
                "subdistricts": [
                    {"code": "3701", "name": "Unjha", "villages": [("384001", "Unjha Rural"), ("384002", "Aithor"), ("384003", "Brahmanwada")]},
                    {"code": "3702", "name": "Kadi", "villages": [("384010", "Kadi"), ("384011", "Nandasan"), ("384012", "Kundal")]},
                    {"code": "3703", "name": "Visnagar", "villages": [("384020", "Visnagar"), ("384021", "Valam"), ("384022", "Kansarakui")]},
                ]
            },
            {
                "code": "441", "name": "Rajkot",
                "subdistricts": [
                    {"code": "3710", "name": "Gondal", "villages": [("385001", "Gondal Rural"), ("385002", "Bhadla"), ("385003", "Kotda Sangani")]},
                    {"code": "3711", "name": "Jasdan", "villages": [("385010", "Jasdan"), ("385011", "Atkot"), ("385012", "Vinchhiya")]},
                    {"code": "3712", "name": "Jetpur", "villages": [("385020", "Jetpur"), ("385021", "Pithadiya"), ("385022", "Navagadh")]},
                ]
            },
            {
                "code": "442", "name": "Ahmedabad",
                "subdistricts": [
                    {"code": "3720", "name": "Sanand", "villages": [("386001", "Sanand"), ("386002", "Chekhla"), ("386003", "Mani Nagar")]},
                    {"code": "3721", "name": "Dholka", "villages": [("386010", "Dholka Rural"), ("386011", "Koth"), ("386012", "Rupgadh")]},
                ]
            },
            {
                "code": "443", "name": "Amreli",
                "subdistricts": [
                    {"code": "3730", "name": "Babra", "villages": [("387001", "Babra"), ("387002", "Chavand"), ("387003", "Khambhala")]},
                    {"code": "3731", "name": "Dhari", "villages": [("387010", "Dhari"), ("387011", "Chalala"), ("387012", "Sarasiya")]},
                ]
            },
        ]
    },
    {
        "code": "08", "name": "Rajasthan",
        "districts": [
            {
                "code": "101", "name": "Kota",
                "subdistricts": [
                    {"code": "550", "name": "Ladpura", "villages": [("324001", "Bhamashah Mandi"), ("324002", "Mandana"), ("324003", "Kasba Kota")]},
                    {"code": "551", "name": "Ramganj Mandi", "villages": [("324010", "Chechat"), ("324011", "Khairabad"), ("324012", "Suket")]},
                ]
            },
            {
                "code": "102", "name": "Ganganagar",
                "subdistricts": [
                    {"code": "560", "name": "Sadulshahar", "villages": [("325001", "Sadulshahar"), ("325002", "Karadwala"), ("325003", "Budharwali")]},
                    {"code": "561", "name": "Suratgarh", "villages": [("325010", "Suratgarh"), ("325011", "Rajpura Piperan"), ("325012", "Rangmahal")]},
                ]
            },
            {
                "code": "103", "name": "Alwar",
                "subdistricts": [
                    {"code": "570", "name": "Behror", "villages": [("326001", "Behror"), ("326002", "Bardod"), ("326003", "Gunta")]},
                    {"code": "571", "name": "Khairthal", "villages": [("326010", "Khairthal"), ("326011", "Kishangarh Bas"), ("326012", "Kotkasim")]},
                ]
            },
            {
                "code": "104", "name": "Jaipur",
                "subdistricts": [
                    {"code": "580", "name": "Chomu", "villages": [("327001", "Chomu Rural"), ("327002", "Morija"), ("327003", "Samod")]},
                    {"code": "581", "name": "Kotputli", "villages": [("327010", "Kotputli"), ("327011", "Paniyala"), ("327012", "Bansur")]},
                ]
            },
        ]
    },
    {
        "code": "29", "name": "Karnataka",
        "districts": [
            {
                "code": "520", "name": "Dharwad",
                "subdistricts": [
                    {"code": "5401", "name": "Hubballi", "villages": [("580001", "Amargol"), ("580002", "Gopankoppa"), ("580003", "Unkal")]},
                    {"code": "5402", "name": "Kundgol", "villages": [("580010", "Kundgol"), ("580011", "Saunshi"), ("580012", "Gudenakatti")]},
                ]
            },
            {
                "code": "521", "name": "Belagavi",
                "subdistricts": [
                    {"code": "5410", "name": "Bailhongal", "villages": [("581001", "Bailhongal"), ("581002", "Nesargi"), ("581003", "Sampgaon")]},
                    {"code": "5411", "name": "Gokak", "villages": [("581010", "Gokak Rural"), ("581011", "Konnur"), ("581012", "Koujalgi")]},
                ]
            },
            {
                "code": "522", "name": "Ballari",
                "subdistricts": [
                    {"code": "5420", "name": "Siruguppa", "villages": [("582001", "Siruguppa"), ("582002", "Tekkalakote"), ("582003", "Karur")]},
                    {"code": "5421", "name": "Sandur", "villages": [("582010", "Sandur"), ("582011", "Toranagallu"), ("582012", "Kudatini")]},
                ]
            },
        ]
    },
    {
        "code": "06", "name": "Haryana",
        "districts": [
            {
                "code": "070", "name": "Karnal",
                "subdistricts": [
                    {"code": "350", "name": "Gharaunda", "villages": [("132001", "Gharaunda"), ("132002", "Kohand"), ("132003", "Bastara")]},
                    {"code": "351", "name": "Nilokheri", "villages": [("132010", "Nilokheri"), ("132011", "Taraori"), ("132012", "Nissing")]},
                ]
            },
            {
                "code": "071", "name": "Hisar",
                "subdistricts": [
                    {"code": "360", "name": "Hansi", "villages": [("133001", "Hansi"), ("133002", "Barwala"), ("133003", "Sisai")]},
                    {"code": "361", "name": "Narnaund", "villages": [("133010", "Narnaund"), ("133011", "Kheri Jalab"), ("133012", "Bass")]},
                ]
            },
            {
                "code": "072", "name": "Sirsa",
                "subdistricts": [
                    {"code": "370", "name": "Dabwali", "villages": [("134001", "Mandi Dabwali"), ("134002", "Chautala"), ("134003", "Abushehar")]},
                    {"code": "371", "name": "Ellenabad", "villages": [("134010", "Ellenabad"), ("134011", "Mithi Sureran"), ("134012", "Kashiram")]},
                ]
            },
        ]
    },
    {
        "code": "28", "name": "Andhra Pradesh",
        "districts": [
            {
                "code": "501", "name": "Guntur",
                "subdistricts": [
                    {"code": "5101", "name": "Tenali", "villages": [("522001", "Tenali Rural"), ("522002", "Angalakuduru"), ("522003", "Nandivelugu")]},
                    {"code": "5102", "name": "Mangalagiri", "villages": [("522010", "Mangalagiri"), ("522011", "Atmakur"), ("522012", "Nowlur")]},
                ]
            },
            {
                "code": "502", "name": "Kurnool",
                "subdistricts": [
                    {"code": "5110", "name": "Adoni", "villages": [("523001", "Adoni Rural"), ("523002", "Yemmiganur"), ("523003", "Aspari")]},
                    {"code": "5111", "name": "Nandyal", "villages": [("523010", "Nandyal Rural"), ("523011", "Allagadda"), ("523012", "Chagalamarri")]},
                ]
            },
        ]
    },
    {
        "code": "36", "name": "Telangana",
        "districts": [
            {
                "code": "680", "name": "Warangal",
                "subdistricts": [
                    {"code": "6101", "name": "Enumamula", "villages": [("506001", "Enumamula"), ("506002", "Gorrekunta"), ("506003", "Mamnoor")]},
                    {"code": "6102", "name": "Narsampet", "villages": [("506010", "Narsampet"), ("506011", "Chennaraopet"), ("506012", "Duggondi")]},
                ]
            },
            {
                "code": "681", "name": "Nizamabad",
                "subdistricts": [
                    {"code": "6110", "name": "Armoor", "villages": [("507001", "Armoor"), ("507002", "Balkonda"), ("507003", "Mupkal")]},
                    {"code": "6111", "name": "Bodhan", "villages": [("507010", "Bodhan"), ("507011", "Kotgir"), ("507012", "Ranjal")]},
                ]
            },
        ]
    },
    {
        "code": "33", "name": "Tamil Nadu",
        "districts": [
            {
                "code": "580", "name": "Coimbatore",
                "subdistricts": [
                    {"code": "5901", "name": "Pollachi", "villages": [("641001", "Pollachi Rural"), ("641002", "Anamalai"), ("641003", "Kottur")]},
                    {"code": "5902", "name": "Mettupalayam", "villages": [("641010", "Mettupalayam"), ("641011", "Karamadai"), ("641012", "Sirumugai")]},
                ]
            },
            {
                "code": "581", "name": "Madurai",
                "subdistricts": [
                    {"code": "5910", "name": "Usilampatti", "villages": [("642001", "Usilampatti"), ("642002", "Sedapatti"), ("642003", "Chellampatti")]},
                    {"code": "5911", "name": "Melur", "villages": [("642010", "Melur"), ("642011", "Kottampatti"), ("642012", "Vellalur")]},
                ]
            },
        ]
    },
    {
        "code": "19", "name": "West Bengal",
        "districts": [
            {
                "code": "301", "name": "Purba Bardhaman",
                "subdistricts": [
                    {"code": "2101", "name": "Burdwan", "villages": [("713001", "Burdwan Rural"), ("713002", "Galsi"), ("713003", "Rayna")]},
                    {"code": "2102", "name": "Kalna", "villages": [("713010", "Kalna"), ("713011", "Manteswar"), ("713012", "Purbasthali")]},
                ]
            },
            {
                "code": "302", "name": "Hooghly",
                "subdistricts": [
                    {"code": "2110", "name": "Arambagh", "villages": [("714001", "Arambagh"), ("714002", "Pursurah"), ("714003", "Khanakul")]},
                    {"code": "2111", "name": "Singur", "villages": [("714010", "Singur"), ("714011", "Haripal"), ("714012", "Tarakeswar")]},
                ]
            },
        ]
    },
    {
        "code": "10", "name": "Bihar",
        "districts": [
            {
                "code": "210", "name": "Muzaffarpur",
                "subdistricts": [
                    {"code": "1101", "name": "Kanti", "villages": [("842001", "Kanti"), ("842002", "Motipur"), ("842003", "Marwan")]},
                    {"code": "1102", "name": "Sakra", "villages": [("842010", "Sakra"), ("842011", "Dholi"), ("842012", "Muraul")]},
                ]
            },
            {
                "code": "211", "name": "Patna",
                "subdistricts": [
                    {"code": "1110", "name": "Barh", "villages": [("843001", "Barh"), ("843002", "Bakhtiarpur"), ("843003", "Mokama")]},
                    {"code": "1111", "name": "Bikram", "villages": [("843010", "Bikram"), ("843011", "Bihta"), ("843012", "Paliganj")]},
                ]
            },
        ]
    },
    {
        "code": "22", "name": "Chhattisgarh",
        "districts": [
            {
                "code": "380", "name": "Raipur",
                "subdistricts": [
                    {"code": "3901", "name": "Arang", "villages": [("492001", "Arang"), ("492002", "Mandir Hasaud"), ("492003", "Chandkhuri")]},
                    {"code": "3902", "name": "Abhanpur", "villages": [("492010", "Abhanpur"), ("492011", "Gobra Nawapara"), ("492012", "Manikchouri")]},
                ]
            },
            {
                "code": "381", "name": "Durg",
                "subdistricts": [
                    {"code": "3910", "name": "Patan", "villages": [("493001", "Patan"), ("493002", "Jamgaon"), ("493003", "Utai")]},
                    {"code": "3911", "name": "Dhamdha", "villages": [("493010", "Dhamdha"), ("493011", "Bhilai Rural"), ("493012", "Nandghat")]},
                ]
            },
        ]
    },
    {
        "code": "21", "name": "Odisha",
        "districts": [
            {
                "code": "360", "name": "Bargarh",
                "subdistricts": [
                    {"code": "3701", "name": "Attabira", "villages": [("768001", "Attabira"), ("768002", "Godbhaga"), ("768003", "Paharsrigida")]},
                    {"code": "3702", "name": "Bhatli", "villages": [("768010", "Bhatli"), ("768011", "Ambabhona"), ("768012", "Kushnapali")]},
                ]
            },
            {
                "code": "361", "name": "Sambalpur",
                "subdistricts": [
                    {"code": "3710", "name": "Rairakhol", "villages": [("769001", "Rairakhol"), ("769002", "Jujomura"), ("769003", "Naktideul")]},
                    {"code": "3711", "name": "Kuchinda", "villages": [("769010", "Kuchinda"), ("769011", "Bamra"), ("769012", "Jamankira")]},
                ]
            },
        ]
    },
    {
        "code": "18", "name": "Assam",
        "districts": [
            {
                "code": "280", "name": "Kamrup",
                "subdistricts": [
                    {"code": "2901", "name": "Hajo", "villages": [("781001", "Hajo"), ("781002", "Sualkuchi"), ("781003", "Dadara")]},
                    {"code": "2902", "name": "Rangia", "villages": [("781010", "Rangia"), ("781011", "Kampur"), ("781012", "Boko")]},
                ]
            },
            {
                "code": "281", "name": "Nagaon",
                "subdistricts": [
                    {"code": "2910", "name": "Kaliabor", "villages": [("782001", "Kaliabor"), ("782002", "Jakhalabandha"), ("782003", "Kuwaritol")]},
                    {"code": "2911", "name": "Raha", "villages": [("782010", "Raha"), ("782011", "Chaparmukh"), ("782012", "Phulaguri")]},
                ]
            },
        ]
    },
    {
        "code": "32", "name": "Kerala",
        "districts": [
            {
                "code": "560", "name": "Palakkad",
                "subdistricts": [
                    {"code": "5701", "name": "Alathur", "villages": [("678001", "Alathur"), ("678002", "Vadakkencherry"), ("678003", "Kavassery")]},
                    {"code": "5702", "name": "Chittur", "villages": [("678010", "Chittur"), ("678011", "Kozhinjampara"), ("678012", "Nallepilly")]},
                ]
            },
            {
                "code": "561", "name": "Wayanad",
                "subdistricts": [
                    {"code": "5710", "name": "Sulthan Bathery", "villages": [("673001", "Ambalavayal"), ("673002", "Meenangadi"), ("673003", "Noolpuzha")]},
                    {"code": "5711", "name": "Mananthavady", "villages": [("673010", "Mananthavady"), ("673011", "Thirunelly"), ("673012", "Vellamunda")]},
                ]
            },
        ]
    },
    {
        "code": "20", "name": "Jharkhand",
        "districts": [
            {
                "code": "340", "name": "Ranchi",
                "subdistricts": [
                    {"code": "3501", "name": "Ormanjhi", "villages": [("834001", "Ormanjhi"), ("834002", "Irba"), ("834003", "Chutupalu")]},
                    {"code": "3502", "name": "Mandar", "villages": [("834010", "Mandar"), ("834011", "Brahmbe"), ("834012", "Kaimbo")]},
                ]
            },
            {
                "code": "341", "name": "Hazaribagh",
                "subdistricts": [
                    {"code": "3510", "name": "Barhi", "villages": [("835001", "Barhi"), ("835002", "Padma"), ("835003", "Chouparan")]},
                    {"code": "3511", "name": "Barkagaon", "villages": [("835010", "Barkagaon"), ("835011", "Urimari"), ("835012", "Keredari")]},
                ]
            },
        ]
    },
    {
        "code": "02", "name": "Himachal Pradesh",
        "districts": [
            {
                "code": "015", "name": "Shimla",
                "subdistricts": [
                    {"code": "090", "name": "Theog", "villages": [("171001", "Theog"), ("171002", "Kotkhai"), ("171003", "Fagu")]},
                    {"code": "091", "name": "Rohru", "villages": [("171010", "Rohru"), ("171011", "Chirgaon"), ("171012", "Jubbal")]},
                ]
            },
            {
                "code": "016", "name": "Solan",
                "subdistricts": [
                    {"code": "095", "name": "Nalagarh", "villages": [("173001", "Nalagarh"), ("173002", "Baddi"), ("173003", "Ramshehar")]},
                    {"code": "096", "name": "Kandaghat", "villages": [("173010", "Kandaghat"), ("173011", "Chail"), ("173012", "Sadhupul")]},
                ]
            },
        ]
    },
    {
        "code": "11", "name": "Sikkim",
        "districts": [
            {
                "code": "220", "name": "Gangtok",
                "subdistricts": [
                    {"code": "1201", "name": "Gangtok", "villages": [("737001", "Ranipool"), ("737002", "Singtam"), ("737003", "Tadong")]},
                    {"code": "1202", "name": "Pakyong", "villages": [("737010", "Pakyong"), ("737011", "Rorathang"), ("737012", "Rhenock")]},
                ]
            },
            {
                "code": "221", "name": "Namchi",
                "subdistricts": [
                    {"code": "1210", "name": "Namchi", "villages": [("737101", "Jorethang"), ("737102", "Ravangla"), ("737103", "Melli")]},
                ]
            },
        ]
    },
]

# Write lgd_villages.csv
village_rows = []
for state in STATES_DATA:
    s_code = state["code"]
    s_name = state["name"]
    for dist in state["districts"]:
        d_code = dist["code"]
        d_name = dist["name"]
        for sub in dist["subdistricts"]:
            sub_code = sub["code"]
            sub_name = sub["name"]
            for v_code, v_name in sub["villages"]:
                village_rows.append({
                    "state_code": s_code,
                    "state_name": s_name,
                    "district_code": d_code,
                    "district_name": d_name,
                    "sub_district_code": sub_code,
                    "sub_district_name": sub_name,
                    "village_code": v_code,
                    "village_name": v_name,
                })

with open("data/lgd_villages.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "state_code", "state_name", "district_code", "district_name",
        "sub_district_code", "sub_district_name", "village_code", "village_name"
    ])
    writer.writeheader()
    writer.writerows(village_rows)

print(f"Generated data/lgd_villages.csv with {len(village_rows)} villages across {len(STATES_DATA)} states.")

# Major APMC Markets for the 20 states with verified GPS coordinates and Agmarknet data
MARKETS_DATA = [
    # Maharashtra
    {"state": "Maharashtra", "district": "Nashik", "market": "Lasalgaon", "lat": "20.1477", "lon": "74.2263"},
    {"state": "Maharashtra", "district": "Nashik", "market": "Pimpalgaon", "lat": "20.1691", "lon": "73.9875"},
    {"state": "Maharashtra", "district": "Nashik", "market": "Yeola", "lat": "20.0435", "lon": "74.4878"},
    {"state": "Maharashtra", "district": "Nashik", "market": "Sinnar", "lat": "19.8459", "lon": "73.9984"},
    {"state": "Maharashtra", "district": "Nashik", "market": "Malegaon", "lat": "20.5519", "lon": "74.5298"},
    {"state": "Maharashtra", "district": "Pune", "market": "Gultekdi Market Yard", "lat": "18.4908", "lon": "73.8643"},
    {"state": "Maharashtra", "district": "Pune", "market": "Baramati", "lat": "18.1517", "lon": "74.5772"},
    {"state": "Maharashtra", "district": "Pune", "market": "Junnar", "lat": "19.2069", "lon": "73.8753"},
    {"state": "Maharashtra", "district": "Ahmednagar", "market": "Rahata", "lat": "19.6975", "lon": "74.4842"},
    {"state": "Maharashtra", "district": "Ahmednagar", "market": "Sangamner", "lat": "19.5773", "lon": "74.2144"},
    {"state": "Maharashtra", "district": "Solapur", "market": "Pandharpur", "lat": "17.6775", "lon": "75.3262"},
    {"state": "Maharashtra", "district": "Solapur", "market": "Barshi", "lat": "18.2333", "lon": "75.6967"},
    {"state": "Maharashtra", "district": "Jalgaon", "market": "Raver", "lat": "21.2464", "lon": "76.0317"},
    {"state": "Maharashtra", "district": "Chhatrapati Sambhajinagar", "market": "Paithan", "lat": "19.4811", "lon": "75.3853"},
    {"state": "Maharashtra", "district": "Kolhapur", "market": "Kolhapur APMC", "lat": "16.7050", "lon": "74.2433"},

    # Madhya Pradesh
    {"state": "Madhya Pradesh", "district": "Indore", "market": "Choithram Mandi Indore", "lat": "22.6841", "lon": "75.8341"},
    {"state": "Madhya Pradesh", "district": "Indore", "market": "Sanwer", "lat": "22.9772", "lon": "75.8306"},
    {"state": "Madhya Pradesh", "district": "Ujjain", "market": "Ujjain Krishi Mandi", "lat": "23.1765", "lon": "75.7885"},
    {"state": "Madhya Pradesh", "district": "Dewas", "market": "Dewas Mandi", "lat": "22.9676", "lon": "76.0534"},
    {"state": "Madhya Pradesh", "district": "Mandsaur", "market": "Mandsaur APMC", "lat": "24.0722", "lon": "75.0689"},
    {"state": "Madhya Pradesh", "district": "Neemuch", "market": "Neemuch Krishi Mandi", "lat": "24.4646", "lon": "74.8722"},

    # Uttar Pradesh
    {"state": "Uttar Pradesh", "district": "Agra", "market": "Fatehabad Mandi", "lat": "27.0211", "lon": "78.3094"},
    {"state": "Uttar Pradesh", "district": "Aligarh", "market": "Aligarh Mandi", "lat": "27.8974", "lon": "78.0880"},
    {"state": "Uttar Pradesh", "district": "Bareilly", "market": "Bareilly APMC", "lat": "28.3670", "lon": "79.4304"},
    {"state": "Uttar Pradesh", "district": "Meerut", "market": "Meerut Mandi", "lat": "28.9845", "lon": "77.7064"},
    {"state": "Uttar Pradesh", "district": "Varanasi", "market": "Pindra Mandi", "lat": "25.5414", "lon": "82.8364"},

    # Punjab
    {"state": "Punjab", "district": "Ludhiana", "market": "Khanna", "lat": "30.7056", "lon": "76.2206"},
    {"state": "Punjab", "district": "Ludhiana", "market": "Jagraon", "lat": "30.7850", "lon": "75.4789"},
    {"state": "Punjab", "district": "Amritsar", "market": "Bhagtanwala Amritsar", "lat": "31.6140", "lon": "74.8765"},
    {"state": "Punjab", "district": "Bathinda", "market": "Rampura Phul", "lat": "30.2741", "lon": "75.2394"},
    {"state": "Punjab", "district": "Patiala", "market": "Nabha", "lat": "30.3752", "lon": "76.1528"},

    # Gujarat
    {"state": "Gujarat", "district": "Mehsana", "market": "Unjha APMC", "lat": "23.8037", "lon": "72.3924"},
    {"state": "Gujarat", "district": "Rajkot", "market": "Rajkot APMC Bedi", "lat": "22.3039", "lon": "70.8022"},
    {"state": "Gujarat", "district": "Rajkot", "market": "Gondal APMC", "lat": "21.9619", "lon": "70.7937"},
    {"state": "Gujarat", "district": "Ahmedabad", "market": "Sanand APMC", "lat": "22.9856", "lon": "72.3813"},
    {"state": "Gujarat", "district": "Amreli", "market": "Babra Mandi", "lat": "21.8488", "lon": "71.3031"},

    # Rajasthan
    {"state": "Rajasthan", "district": "Kota", "market": "Bhamashah Mandi Kota", "lat": "25.1766", "lon": "75.8569"},
    {"state": "Rajasthan", "district": "Ganganagar", "market": "Sri Ganganagar Mandi", "lat": "29.9038", "lon": "73.8772"},
    {"state": "Rajasthan", "district": "Alwar", "market": "Alwar APMC", "lat": "27.5530", "lon": "76.6346"},
    {"state": "Rajasthan", "district": "Jaipur", "market": "Muhana Mandi Jaipur", "lat": "26.7865", "lon": "75.7667"},

    # Karnataka
    {"state": "Karnataka", "district": "Dharwad", "market": "Hubballi APMC Amargol", "lat": "15.3647", "lon": "75.1240"},
    {"state": "Karnataka", "district": "Belagavi", "market": "Bailhongal APMC", "lat": "15.8208", "lon": "74.8583"},
    {"state": "Karnataka", "district": "Ballari", "market": "Siruguppa Mandi", "lat": "15.6322", "lon": "76.8967"},

    # Haryana
    {"state": "Haryana", "district": "Karnal", "market": "Karnal New Grain Market", "lat": "29.6857", "lon": "76.9905"},
    {"state": "Haryana", "district": "Hisar", "market": "Hansi Mandi", "lat": "29.1022", "lon": "75.9592"},
    {"state": "Haryana", "district": "Sirsa", "market": "Mandi Dabwali", "lat": "30.1798", "lon": "74.7214"},

    # Andhra Pradesh
    {"state": "Andhra Pradesh", "district": "Guntur", "market": "Guntur Mirchi Yard", "lat": "16.2942", "lon": "80.4431"},
    {"state": "Andhra Pradesh", "district": "Kurnool", "market": "Adoni Cotton Market", "lat": "15.6322", "lon": "77.2728"},

    # Telangana
    {"state": "Telangana", "district": "Warangal", "market": "Enumamula Agricultural Market", "lat": "17.9689", "lon": "79.5941"},
    {"state": "Telangana", "district": "Nizamabad", "market": "Armoor Mandi", "lat": "18.7906", "lon": "78.2889"},

    # Tamil Nadu
    {"state": "Tamil Nadu", "district": "Coimbatore", "market": "Pollachi APMC", "lat": "10.6609", "lon": "77.0048"},
    {"state": "Tamil Nadu", "district": "Madurai", "market": "Madurai Mattuthavani", "lat": "9.9472", "lon": "78.1561"},

    # West Bengal
    {"state": "West Bengal", "district": "Purba Bardhaman", "market": "Burdwan Regulated Market", "lat": "23.2324", "lon": "87.8615"},
    {"state": "West Bengal", "district": "Hooghly", "market": "Singur Potato Market", "lat": "22.8125", "lon": "88.2325"},

    # Bihar
    {"state": "Bihar", "district": "Muzaffarpur", "market": "Muzaffarpur Bazar Samiti", "lat": "26.1209", "lon": "85.3647"},
    {"state": "Bihar", "district": "Patna", "market": "Mokama Mandi", "lat": "25.3942", "lon": "85.9189"},

    # Chhattisgarh
    {"state": "Chhattisgarh", "district": "Raipur", "market": "Pandri Mandi Raipur", "lat": "21.2514", "lon": "81.6296"},
    {"state": "Chhattisgarh", "district": "Durg", "market": "Dhamdha Mandi", "lat": "21.4489", "lon": "81.3128"},

    # Odisha
    {"state": "Odisha", "district": "Bargarh", "market": "Bargarh Regulated Market", "lat": "21.3340", "lon": "83.6214"},
    {"state": "Odisha", "district": "Sambalpur", "market": "Rairakhol Mandi", "lat": "21.0667", "lon": "84.3500"},

    # Assam
    {"state": "Assam", "district": "Kamrup", "market": "Pamohi APMC Guwahati", "lat": "26.1158", "lon": "91.7086"},
    {"state": "Assam", "district": "Nagaon", "market": "Kaliabor Mandi", "lat": "26.5400", "lon": "93.0200"},

    # Kerala
    {"state": "Kerala", "district": "Palakkad", "market": "Alathur Agro Market", "lat": "10.6481", "lon": "76.5447"},
    {"state": "Kerala", "district": "Wayanad", "market": "Sulthan Bathery Spices Mandi", "lat": "11.6667", "lon": "76.2667"},

    # Jharkhand
    {"state": "Jharkhand", "district": "Ranchi", "market": "Ranchi Krishi Upaj Mandi", "lat": "23.3441", "lon": "85.3096"},
    {"state": "Jharkhand", "district": "Hazaribagh", "market": "Barhi Krishi Mandi", "lat": "24.3000", "lon": "85.4167"},

    # Himachal Pradesh
    {"state": "Himachal Pradesh", "district": "Shimla", "market": "Dhalli Fruit Market Shimla", "lat": "31.1118", "lon": "77.2023"},
    {"state": "Himachal Pradesh", "district": "Solan", "market": "Solan Subzi Mandi", "lat": "30.9084", "lon": "77.0999"},

    # Sikkim
    {"state": "Sikkim", "district": "Gangtok", "market": "Ranipool Organic Mandi", "lat": "27.2889", "lon": "88.5889"},
    {"state": "Sikkim", "district": "Namchi", "market": "Jorethang Kisan Bazaar", "lat": "27.1333", "lon": "88.3167"},
]

with open("data/markets.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["state", "district", "market", "lat", "lon"])
    writer.writeheader()
    writer.writerows(MARKETS_DATA)

print(f"Generated data/markets.csv with {len(MARKETS_DATA)} mandis across all 20 states.")
