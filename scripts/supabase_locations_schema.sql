-- ==============================================================================
-- KisanMitra Location Master Schema (PostgreSQL / Supabase)
-- States, Districts, Sub-districts (Tehsils/Talukas), Villages & APMC Mandis
-- ==============================================================================

-- 1. States Table
CREATE TABLE IF NOT EXISTS public.states (
    state_code VARCHAR(10) PRIMARY KEY,
    state_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Districts Table
CREATE TABLE IF NOT EXISTS public.districts (
    state_code VARCHAR(10) REFERENCES public.states(state_code) ON DELETE CASCADE,
    district_code VARCHAR(10) PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_districts_state ON public.districts(state_code);

-- 3. Sub-districts / Tehsils / Talukas Table
CREATE TABLE IF NOT EXISTS public.sub_districts (
    state_code VARCHAR(10) REFERENCES public.states(state_code) ON DELETE CASCADE,
    district_code VARCHAR(10) REFERENCES public.districts(district_code) ON DELETE CASCADE,
    sub_district_code VARCHAR(15) PRIMARY KEY,
    sub_district_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_subs_district ON public.sub_districts(district_code);

-- 4. Villages Table
CREATE TABLE IF NOT EXISTS public.villages (
    state_code VARCHAR(10) REFERENCES public.states(state_code) ON DELETE CASCADE,
    district_code VARCHAR(10) REFERENCES public.districts(district_code) ON DELETE CASCADE,
    sub_district_code VARCHAR(15) REFERENCES public.sub_districts(sub_district_code) ON DELETE CASCADE,
    village_code VARCHAR(20) PRIMARY KEY,
    village_name VARCHAR(150) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_villages_subdistrict ON public.villages(sub_district_code);
CREATE INDEX IF NOT EXISTS idx_villages_name ON public.villages(village_name);

-- 5. APMC Markets / Mandis Table
CREATE TABLE IF NOT EXISTS public.markets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_name VARCHAR(150) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10),
    district_code VARCHAR(10),
    sub_district_code VARCHAR(15),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    mapping_method VARCHAR(50),
    needs_review BOOLEAN DEFAULT false,
    operating_hours VARCHAR(100) DEFAULT '08:00 AM - 04:00 PM',
    contact_phone VARCHAR(25) DEFAULT '+91 253 222345',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_markets_state ON public.markets(state_name);
CREATE INDEX IF NOT EXISTS idx_markets_district ON public.markets(district_name);

-- Function to find nearest mandis from farmer's GPS coordinates (Haversine formula in SQL)
CREATE OR REPLACE FUNCTION public.get_nearby_mandis(
    farmer_lat DOUBLE PRECISION,
    farmer_lon DOUBLE PRECISION,
    max_radius_km DOUBLE PRECISION DEFAULT 150.0
)
RETURNS TABLE (
    id UUID,
    market_name VARCHAR,
    district_name VARCHAR,
    state_name VARCHAR,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_km DOUBLE PRECISION
)
LANGUAGE sql
AS $$
    SELECT 
        m.id,
        m.market_name,
        m.district_name,
        m.state_name,
        m.latitude,
        m.longitude,
        (6371 * acos(
            cos(radians(farmer_lat)) * cos(radians(m.latitude)) *
            cos(radians(m.longitude) - radians(farmer_lon)) +
            sin(radians(farmer_lat)) * sin(radians(m.latitude))
        )) AS distance_km
    FROM public.markets m
    WHERE m.latitude IS NOT NULL AND m.longitude IS NOT NULL
      AND (6371 * acos(
            cos(radians(farmer_lat)) * cos(radians(m.latitude)) *
            cos(radians(m.longitude) - radians(farmer_lon)) +
            sin(radians(farmer_lat)) * sin(radians(m.latitude))
        )) <= max_radius_km
    ORDER BY distance_km ASC;
$$;
