import json

crop_data = {
    "Maharashtra": [
        # Grains
        {"name": "Wheat", "local": "गहू / गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "भात / धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Jowar (Sorghum)", "local": "ज्वारी / ज्वार", "cat": "Grain", "emoji": "🌾"},
        {"name": "Bajra (Pearl Millet)", "local": "बाजरी / बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "मका / मक्का", "cat": "Grain", "emoji": "🌽"},
        # Pulses
        {"name": "Tur / Arhar Dal", "local": "तूर / अरहर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Gram / Chana", "local": "हरभरा / चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Moong", "local": "मूग / मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Urad", "local": "उडीद / उड़द", "cat": "Pulse", "emoji": "🌱"},
        # Oilseeds & Cash
        {"name": "Soybean", "local": "सोयाबीन", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Cotton", "local": "कापूस / कपास", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Sugarcane", "local": "ऊस / गन्ना", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Groundnut", "local": "भुईमूग / मूंगफली", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Sunflower", "local": "सूर्यफूल / सूरजमुखी", "cat": "Oilseed & Cash", "emoji": "🌻"},
        # Vegetables
        {"name": "Onion", "local": "कांदा / प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Tomato", "local": "टोमॅटो / टमाटर", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Potato", "local": "बटाटा / आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Green Chili", "local": "हिरवी मिरची / हरी मिर्च", "cat": "Vegetable", "emoji": "🌶️"},
        {"name": "Garlic", "local": "लसूण / लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Ginger", "local": "आले / अदरक", "cat": "Vegetable", "emoji": "🫚"},
        {"name": "Brinjal (Eggplant)", "local": "वांगी / बैंगन", "cat": "Vegetable", "emoji": "🍆"},
        {"name": "Cauliflower", "local": "फ्लॉवर / गोभी", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Cabbage", "local": "कोबी / पत्ता गोभी", "cat": "Vegetable", "emoji": "🥬"},
        {"name": "Okra (Bhindi)", "local": "भेंडी / भिंडी", "cat": "Vegetable", "emoji": "🌱"},
        # Fruits
        {"name": "Grapes", "local": "द्राक्षे / अंगूर", "cat": "Fruit", "emoji": "🍇"},
        {"name": "Pomegranate", "local": "डाळिंब / अनार", "cat": "Fruit", "emoji": "🍎"},
        {"name": "Banana", "local": "केळी / केला", "cat": "Fruit", "emoji": "🍌"},
        {"name": "Mango", "local": "आंबा / आम (हापूस)", "cat": "Fruit", "emoji": "🥭"},
        {"name": "Orange (Santra)", "local": "संत्रा / संतरा", "cat": "Fruit", "emoji": "🍊"},
        {"name": "Custard Apple", "local": "सीताफळ / शरीफा", "cat": "Fruit", "emoji": "🍈"},
    ],
    "Madhya Pradesh": [
        # Grains
        {"name": "Wheat (Sharbati/Lokwan)", "local": "गेहूं / शरबती", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "धान / चावल", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Jowar", "local": "ज्वार", "cat": "Grain", "emoji": "🌾"},
        {"name": "Bajra", "local": "बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Barley (Jau)", "local": "जौ", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Gram / Chana", "local": "चना (डॉलर/देसी)", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Masoor (Lentil)", "local": "मसूर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Tur / Arhar", "local": "अरहर / तुअर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Moong", "local": "मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Urad", "local": "उड़द", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Green Pea (Matar)", "local": "मटर", "cat": "Pulse", "emoji": "🟢"},
        # Oilseeds & Cash
        {"name": "Soybean", "local": "सोयाबीन (पीला सोना)", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Mustard (Rai)", "local": "सरसों / राई", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Cotton", "local": "कपास", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Groundnut", "local": "मूंगफली", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Sesame (Til)", "local": "तिल", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Linseed (Alsi)", "local": "अलसी", "cat": "Oilseed & Cash", "emoji": "🌾"},
        # Vegetables & Spices
        {"name": "Garlic", "local": "लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Onion", "local": "प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Potato", "local": "आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Tomato", "local": "टमाटर", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Green Chili", "local": "हरी मिर्च", "cat": "Vegetable", "emoji": "🌶️"},
        {"name": "Ginger", "local": "अदरक", "cat": "Vegetable", "emoji": "🫚"},
        {"name": "Coriander", "local": "धनिया", "cat": "Vegetable", "emoji": "🌿"},
        {"name": "Fenugreek (Methi)", "local": "मेथी", "cat": "Vegetable", "emoji": "🥬"},
        # Fruits
        {"name": "Orange (Santra)", "local": "संतरा / नागपुरी संतरा", "cat": "Fruit", "emoji": "🍊"},
        {"name": "Guava", "local": "अमरूद", "cat": "Fruit", "emoji": "🍈"},
        {"name": "Banana", "local": "केला", "cat": "Fruit", "emoji": "🍌"},
    ],
    "Uttar Pradesh": [
        # Grains
        {"name": "Wheat", "local": "गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Bajra", "local": "बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Barley (Jau)", "local": "जौ", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Gram / Chana", "local": "चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Arhar / Tur", "local": "अरहर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Masoor", "local": "मसूर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Urad", "local": "उड़द", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Pea (Matar)", "local": "मटर", "cat": "Pulse", "emoji": "🟢"},
        # Oilseeds & Cash
        {"name": "Sugarcane", "local": "गन्ना", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Mustard (Sarson)", "local": "सरसों / लाही", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Sesame (Til)", "local": "तिल", "cat": "Oilseed & Cash", "emoji": "🌱"},
        # Vegetables
        {"name": "Potato", "local": "आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Tomato", "local": "टमाटर", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Onion", "local": "प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Garlic", "local": "लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Cauliflower", "local": "फूलगोभी", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Cabbage", "local": "पत्तागोभी", "cat": "Vegetable", "emoji": "🥬"},
        {"name": "Brinjal", "local": "बैंगन", "cat": "Vegetable", "emoji": "🍆"},
        {"name": "Green Chili", "local": "हरी मिर्च", "cat": "Vegetable", "emoji": "🌶️"},
        # Fruits
        {"name": "Mango", "local": "आम (दशहरी / लंगड़ा)", "cat": "Fruit", "emoji": "🥭"},
        {"name": "Guava", "local": "अमरूद (इलाहाबादी)", "cat": "Fruit", "emoji": "🍈"},
        {"name": "Aonla (Gooseberry)", "local": "आंवला", "cat": "Fruit", "emoji": "🍏"},
    ],
    "Punjab": [
        # Grains
        {"name": "Wheat", "local": "ਕਣਕ / गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Basmati Rice", "local": "ਬਾਸਮਤੀ ਚਾਵਲ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "ਝੋਨਾ / धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "ਮੱਕੀ / मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Barley", "local": "ਜੌਂ / जौ", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Moong", "local": "ਮੂੰਗੀ / मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Mash (Urad)", "local": "ਮਾਂਹ / उड़द", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Gram / Chana", "local": "ਛੋਲੇ / चना", "cat": "Pulse", "emoji": "🌱"},
        # Oilseeds & Cash
        {"name": "Cotton", "local": "ਨਰਮਾ / ਕਪਾਹ", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Mustard (Raya)", "local": "ਸਰ੍ਹੋਂ / सरसों", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Sugarcane", "local": "ਗੰਨਾ / गन्ना", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Sunflower", "local": "ਸੂਰਜਮੁਖੀ", "cat": "Oilseed & Cash", "emoji": "🌻"},
        # Vegetables
        {"name": "Potato", "local": "ਆਲੂ / आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Green Pea", "local": "ਮਟਰ / मटर", "cat": "Vegetable", "emoji": "🟢"},
        {"name": "Cauliflower", "local": "ਗੋਭੀ / फूलगोभी", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Carrot", "local": "ਗਾਜਰ / गाजर", "cat": "Vegetable", "emoji": "🥕"},
        {"name": "Garlic", "local": "ਲਸਣ / लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Onion", "local": "ਪਿਆਜ਼ / प्याज", "cat": "Vegetable", "emoji": "🧅"},
        # Fruits
        {"name": "Kinnow (Mandarin)", "local": "ਕਿੰਨੂ / किन्नू", "cat": "Fruit", "emoji": "🍊"},
        {"name": "Guava", "local": "ਅਮਰੂਦ / अमरूद", "cat": "Fruit", "emoji": "🍈"},
    ],
    "Gujarat": [
        # Grains
        {"name": "Wheat (Bhalia)", "local": "ભાલિયા ઘઉં / गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Bajra", "local": "બાજરી / बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "ડાંગર / धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "મકાઈ / मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Jowar", "local": "જુવાર / ज्वार", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Tuver / Tur", "local": "તુવેર / अरहर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Gram / Chana", "local": "ચણા / चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Moong", "local": "મગ / मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Urad", "local": "અડદ / उड़द", "cat": "Pulse", "emoji": "🌱"},
        # Oilseeds & Cash
        {"name": "Groundnut", "local": "મગફળી / मूंगफली", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Cotton", "local": "કપાસ / कपास", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Castor (Divela)", "local": "દિવેલા / अरंडी", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Sesame (Til)", "local": "તલ / तिल", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Mustard", "local": "રાઈ / सरसों", "cat": "Oilseed & Cash", "emoji": "🌼"},
        # Spices & Vegetables
        {"name": "Cumin (Jeera)", "local": "જીરું / जीरा", "cat": "Spice", "emoji": "🌿"},
        {"name": "Fennel (Saunf)", "local": "વરિયાળી / सौंफ", "cat": "Spice", "emoji": "🌿"},
        {"name": "Onion", "local": "ડુંગળી / प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Potato", "local": "બટાટા / आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Garlic", "local": "લસણ / लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Chili", "local": "મરચાં / मिर्च", "cat": "Vegetable", "emoji": "🌶️"},
        # Fruits
        {"name": "Mango (Kesar)", "local": "કેસર કેરી / आम", "cat": "Fruit", "emoji": "🥭"},
        {"name": "Banana", "local": "કેળા / केला", "cat": "Fruit", "emoji": "🍌"},
        {"name": "Papaya", "local": "પપૈયા / पपीता", "cat": "Fruit", "emoji": "🍈"},
        {"name": "Pomegranate", "local": "દાડમ / अनार", "cat": "Fruit", "emoji": "🍎"},
    ],
    "Rajasthan": [
        # Grains
        {"name": "Bajra", "local": "बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Wheat", "local": "गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Barley (Jau)", "local": "जौ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Jowar", "local": "ज्वार", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Moong", "local": "मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Moth Bean", "local": "मोठ", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Gram / Chana", "local": "चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Urad", "local": "उड़द", "cat": "Pulse", "emoji": "🌱"},
        # Oilseeds & Cash
        {"name": "Mustard / Rai", "local": "सरसों / राई", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Guar (Cluster Bean)", "local": "ग्वार", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Soybean", "local": "सोयाबीन", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Groundnut", "local": "मूंगफली", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Cotton", "local": "कपास", "cat": "Oilseed & Cash", "emoji": "☁️"},
        # Spices & Vegetables
        {"name": "Cumin (Jeera)", "local": "जीरा", "cat": "Spice", "emoji": "🌿"},
        {"name": "Coriander", "local": "धनिया", "cat": "Spice", "emoji": "🌿"},
        {"name": "Fenugreek (Methi)", "local": "दाना मेथी", "cat": "Spice", "emoji": "🌿"},
        {"name": "Fennel (Saunf)", "local": "सौंफ", "cat": "Spice", "emoji": "🌿"},
        {"name": "Garlic", "local": "लहसुन", "cat": "Vegetable", "emoji": "🧄"},
        {"name": "Onion", "local": "प्याज", "cat": "Vegetable", "emoji": "🧅"},
        # Fruits
        {"name": "Pomegranate", "local": "अनार (सिंदूरी)", "cat": "Fruit", "emoji": "🍎"},
        {"name": "Kinnow", "local": "किन्नू", "cat": "Fruit", "emoji": "🍊"},
    ],
    "Karnataka": [
        # Grains
        {"name": "Ragi (Finger Millet)", "local": "ರಾಗಿ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Paddy / Rice", "local": "ಭತ್ತ / ಅನ್ನ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "ಮೆಕ್ಕೆಜೋಳ", "cat": "Grain", "emoji": "🌽"},
        {"name": "Jowar", "local": "ಜೋಳ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Wheat", "local": "ಗೋಧಿ", "cat": "Grain", "emoji": "🌾"},
        # Pulses
        {"name": "Tur / Toor Dal", "local": "ತೊಗರಿ ಬೇಳೆ", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Bengal Gram (Chana)", "local": "ಕಡಲೆ", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Green Gram", "local": "ಹೆಸರು ಕಾಳು", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Black Gram (Urad)", "local": "ಉದ್ದು", "cat": "Pulse", "emoji": "🌱"},
        # Oilseeds & Cash
        {"name": "Sugarcane", "local": "ಕಬ್ಬು", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Cotton", "local": "ಹತ್ತಿ", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Groundnut", "local": "ಕಡಲೆಕಾಯಿ", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Sunflower", "local": "ಸೂರ್ಯಕಾಂತಿ", "cat": "Oilseed & Cash", "emoji": "🌻"},
        {"name": "Soybean", "local": "ಸೋಯಾಬೀನ್", "cat": "Oilseed & Cash", "emoji": "🌱"},
        # Spices & Vegetables
        {"name": "Byadgi Chili", "local": "ಬ್ಯಾಡಗಿ ಮೆಣಸಿನಕಾಯಿ", "cat": "Spice", "emoji": "🌶️"},
        {"name": "Turmeric", "local": "ಅರಿಶಿನ", "cat": "Spice", "emoji": "🌿"},
        {"name": "Onion", "local": "ಈರುಳ್ಳಿ", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Tomato", "local": "ಟೊಮೆಟೊ", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Potato", "local": "ಆಲೂಗಡ್ಡೆ", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Ginger", "local": "ಶುಂಠಿ", "cat": "Vegetable", "emoji": "🫚"},
        # Plantation & Fruits
        {"name": "Arecanut (Supari)", "local": "ಅಡಿಕೆ", "cat": "Fruit", "emoji": "🥥"},
        {"name": "Coffee", "local": "ಕಾಫಿ", "cat": "Fruit", "emoji": "☕"},
        {"name": "Coconut", "local": "ತೆಂಗಿನಕಾಯಿ", "cat": "Fruit", "emoji": "🥥"},
        {"name": "Banana", "local": "ಬಾಳೆಹಣ್ಣು", "cat": "Fruit", "emoji": "🍌"},
    ],
    "Haryana": [
        {"name": "Wheat", "local": "गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Basmati Paddy", "local": "बासमती धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Bajra", "local": "बाजरा", "cat": "Grain", "emoji": "🌾"},
        {"name": "Barley", "local": "जौ", "cat": "Grain", "emoji": "🌾"},
        {"name": "Gram / Chana", "local": "चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Moong", "local": "मूंग", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Mustard (Raya)", "local": "सरसों / राया", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Cotton", "local": "कपास", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Sugarcane", "local": "गन्ना", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Potato", "local": "आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Tomato", "local": "टमाटर", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Onion", "local": "प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Cauliflower", "local": "गोभी", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Kinnow", "local": "किन्नू", "cat": "Fruit", "emoji": "🍊"},
    ],
    "Andhra Pradesh": [
        {"name": "Paddy / Rice", "local": "వరి / ధాన్యం", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "మొక్కజొన్న", "cat": "Grain", "emoji": "🌽"},
        {"name": "Jowar", "local": "జొన్న", "cat": "Grain", "emoji": "🌾"},
        {"name": "Ragi", "local": "రాగి", "cat": "Grain", "emoji": "🌾"},
        {"name": "Red Gram (Tur)", "local": "కందులు", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Bengal Gram (Chana)", "local": "శనగలు", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Black Gram (Urad)", "local": "మినుములు", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Cotton", "local": "పత్తి", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Tobacco", "local": "పొగాకు", "cat": "Oilseed & Cash", "emoji": "🍂"},
        {"name": "Groundnut", "local": "వేరుశనగ", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Sugarcane", "local": "చెరకు", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Guntur Red Chili", "local": "గుంటూరు మిరపకాయ", "cat": "Spice", "emoji": "🌶️"},
        {"name": "Turmeric", "local": "పసుపు", "cat": "Spice", "emoji": "🌿"},
        {"name": "Tomato", "local": "టమాటా", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Onion", "local": "ఉల్లిపాయ", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Banana", "local": "అరటి", "cat": "Fruit", "emoji": "🍌"},
        {"name": "Mango", "local": "మామిడి (బంగినపల్లి)", "cat": "Fruit", "emoji": "🥭"},
    ],
    "Telangana": [
        {"name": "Paddy / Rice", "local": "వరి / బియ్యం", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "మొక్కజొన్న", "cat": "Grain", "emoji": "🌽"},
        {"name": "Jowar", "local": "జొన్న", "cat": "Grain", "emoji": "🌾"},
        {"name": "Red Gram (Tur)", "local": "కందులు", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Bengal Gram", "local": "శనగలు", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Cotton", "local": "పత్తి (White Gold)", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Soybean", "local": "సోయాబీన్", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Groundnut", "local": "వేరుశనగ", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Red Chili", "local": "ఎర్ర మిరపకాయ", "cat": "Spice", "emoji": "🌶️"},
        {"name": "Turmeric", "local": "పసుపు (నిజామాబాద్)", "cat": "Spice", "emoji": "🌿"},
        {"name": "Tomato", "local": "టమాటా", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Onion", "local": "ఉల్లిపాయ", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Mango", "local": "మామిడి", "cat": "Fruit", "emoji": "🥭"},
    ],
    "Tamil Nadu": [
        {"name": "Paddy / Rice", "local": "நெல் / அரிசி", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "மக்காச்சோளம்", "cat": "Grain", "emoji": "🌽"},
        {"name": "Ragi", "local": "கேழ்வரகு / ராகி", "cat": "Grain", "emoji": "🌾"},
        {"name": "Cumbu (Bajra)", "local": "கம்பு", "cat": "Grain", "emoji": "🌾"},
        {"name": "Black Gram (Urad)", "local": "உளுந்து", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Green Gram (Moong)", "local": "பாசிப்பயறு", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Sugarcane", "local": "கரும்பு", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Cotton", "local": "பருத்தி", "cat": "Oilseed & Cash", "emoji": "☁️"},
        {"name": "Groundnut", "local": "நிலக்கடலை", "cat": "Oilseed & Cash", "emoji": "🥜"},
        {"name": "Coconut", "local": "தேங்காய்", "cat": "Oilseed & Cash", "emoji": "🥥"},
        {"name": "Sesame (Gingelly)", "local": "எள்", "cat": "Oilseed & Cash", "emoji": "🌱"},
        {"name": "Small Onion (Shallot)", "local": "சின்ன வெங்காயம்", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Tomato", "local": "தக்காளி", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Turmeric", "local": "மஞ்சள் (ஈரோடு)", "cat": "Spice", "emoji": "🌿"},
        {"name": "Banana", "local": "வாழைப்பழம்", "cat": "Fruit", "emoji": "🍌"},
    ],
    "West Bengal": [
        {"name": "Aman / Boro Paddy", "local": "আমন / বোরো ধান", "cat": "Grain", "emoji": "🌾"},
        {"name": "Wheat", "local": "গম", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "ভুট্টা", "cat": "Grain", "emoji": "🌽"},
        {"name": "Masoor Dal", "local": "মসুর ডাল", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Gram (Chhola)", "local": "ছোলা", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Jute", "local": "পাট (সোনালী আঁশ)", "cat": "Oilseed & Cash", "emoji": "🌾"},
        {"name": "Mustard (Sarise)", "local": "সর্ষে", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Potato", "local": "আলু", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Brinjal (Begun)", "local": "বেগুন", "cat": "Vegetable", "emoji": "🍆"},
        {"name": "Cabbage", "local": "বাঁধাকপি", "cat": "Vegetable", "emoji": "🥬"},
        {"name": "Cauliflower", "local": "ফুলকপি", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Pointed Gourd (Potol)", "local": "পটল", "cat": "Vegetable", "emoji": "🥒"},
        {"name": "Tomato", "local": "টমেটো", "cat": "Vegetable", "emoji": "🍅"},
        {"name": "Mango", "local": "মালদা আম", "cat": "Fruit", "emoji": "🥭"},
        {"name": "Banana", "local": "কলা", "cat": "Fruit", "emoji": "🍌"},
        {"name": "Tea", "local": "দার্জিলিং চা", "cat": "Spice", "emoji": "🍵"},
    ],
    "Bihar": [
        {"name": "Paddy / Rice", "local": "धान", "cat": "Grain", "emoji": "🌾"},
        {"name": "Wheat", "local": "गेहूं", "cat": "Grain", "emoji": "🌾"},
        {"name": "Maize", "local": "मक्का", "cat": "Grain", "emoji": "🌽"},
        {"name": "Gram / Chana", "local": "चना", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Masoor", "local": "मसूर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Arhar / Tur", "local": "अरहर", "cat": "Pulse", "emoji": "🌱"},
        {"name": "Sugarcane", "local": "गन्ना", "cat": "Oilseed & Cash", "emoji": "🎋"},
        {"name": "Mustard", "local": "सरसों", "cat": "Oilseed & Cash", "emoji": "🌼"},
        {"name": "Jute", "local": "जूट / पटुआ", "cat": "Oilseed & Cash", "emoji": "🌾"},
        {"name": "Potato", "local": "आलू", "cat": "Vegetable", "emoji": "🥔"},
        {"name": "Onion", "local": "प्याज", "cat": "Vegetable", "emoji": "🧅"},
        {"name": "Cauliflower", "local": "गोभी", "cat": "Vegetable", "emoji": "🥦"},
        {"name": "Brinjal", "local": "बैंगन", "cat": "Vegetable", "emoji": "🍆"},
        {"name": "Makhana (Foxnut)", "local": "मिथिला मखाना", "cat": "Grain", "emoji": "⚪"},
        {"name": "Shahi Litchi", "local": "शाही लीची", "cat": "Fruit", "emoji": "🍓"},
        {"name": "Mango (Zardalu)", "local": "जर्दालू आम", "cat": "Fruit", "emoji": "🥭"},
        {"name": "Banana", "local": "हाजीपुर केला", "cat": "Fruit", "emoji": "🍌"},
    ],
}

# Generic catalog for any other Indian state
generic_crops = [
    {"name": "Wheat", "local": "गेहूं / Wheat", "cat": "Grain", "emoji": "🌾"},
    {"name": "Paddy / Rice", "local": "धान / Rice", "cat": "Grain", "emoji": "🌾"},
    {"name": "Maize", "local": "मक्का / Maize", "cat": "Grain", "emoji": "🌽"},
    {"name": "Gram / Chana", "local": "चना / Gram", "cat": "Pulse", "emoji": "🌱"},
    {"name": "Moong", "local": "मूंग / Moong", "cat": "Pulse", "emoji": "🌱"},
    {"name": "Tur / Arhar", "local": "अरहर / Tur", "cat": "Pulse", "emoji": "🌱"},
    {"name": "Mustard", "local": "सरसों / Mustard", "cat": "Oilseed & Cash", "emoji": "🌼"},
    {"name": "Soybean", "local": "सोयाबीन / Soybean", "cat": "Oilseed & Cash", "emoji": "🌱"},
    {"name": "Cotton", "local": "कपास / Cotton", "cat": "Oilseed & Cash", "emoji": "☁️"},
    {"name": "Sugarcane", "local": "गन्ना / Sugarcane", "cat": "Oilseed & Cash", "emoji": "🎋"},
    {"name": "Potato", "local": "आलू / Potato", "cat": "Vegetable", "emoji": "🥔"},
    {"name": "Onion", "local": "प्याज / Onion", "cat": "Vegetable", "emoji": "🧅"},
    {"name": "Tomato", "local": "टमाटर / Tomato", "cat": "Vegetable", "emoji": "🍅"},
    {"name": "Green Chili", "local": "हरी मिर्च / Green Chili", "cat": "Vegetable", "emoji": "🌶️"},
    {"name": "Garlic", "local": "लहसुन / Garlic", "cat": "Vegetable", "emoji": "🧄"},
    {"name": "Ginger", "local": "अदरक / Ginger", "cat": "Vegetable", "emoji": "🫚"},
    {"name": "Banana", "local": "केला / Banana", "cat": "Fruit", "emoji": "🍌"},
    {"name": "Mango", "local": "आम / Mango", "cat": "Fruit", "emoji": "🥭"},
]

out = '''/// Agricultural Crops, Grains, Pulses, Oilseeds, Vegetables & Fruits catalog
/// Tailored per Indian state with vernacular names, emojis, and categories.
class CropItem {
  final String name;
  final String localName;
  final String category;
  final String emoji;

  const CropItem({
    required this.name,
    required this.localName,
    required this.category,
    required this.emoji,
  });
}

class CropCatalogService {
  static const List<CropItem> defaultAllIndiaCrops = [
'''

for c in generic_crops:
    out += f"    CropItem(name: '{c['name']}', localName: '{c['local']}', category: '{c['cat']}', emoji: '{c['emoji']}'),\n"

out += '''  ];

  static const Map<String, List<CropItem>> stateCrops = {
'''

for s_name, crops in crop_data.items():
    out += f"    '{s_name}': [\n"
    for c in crops:
        out += f"      CropItem(name: '{c['name']}', localName: '{c['local']}', category: '{c['cat']}', emoji: '{c['emoji']}'),\n"
    out += "    ],\n"

out += '''  };

  /// Get list of CropItem objects for a given state, optionally filtered by category
  static List<CropItem> getCropsForState(String state, {String? category}) {
    List<CropItem> list = stateCrops[state] ?? defaultAllIndiaCrops;
    // Check case insensitive
    if (!stateCrops.containsKey(state)) {
      for (final entry in stateCrops.entries) {
        if (entry.key.toLowerCase() == state.toLowerCase()) {
          list = entry.value;
          break;
        }
      }
    }

    if (category == null || category == 'All') {
      return list;
    }

    return list.where((c) {
      if (category == 'Grains') return c.category == 'Grain';
      if (category == 'Pulses') return c.category == 'Pulse';
      if (category == 'Oilseeds & Cash') return c.category == 'Oilseed & Cash';
      if (category == 'Vegetables') return c.category == 'Vegetable';
      if (category == 'Fruits & Spices') return c.category == 'Fruit' || c.category == 'Spice';
      return c.category.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  /// Get simple list of crop names for a given state
  static List<String> getCropNamesForState(String state) {
    return getCropsForState(state).map((c) => c.name).toList();
  }
}
'''

with open('lib/data/services/crop_catalog_service.dart', 'w', encoding='utf-8') as f:
    f.write(out)

print("Generated lib/data/services/crop_catalog_service.dart successfully!")
