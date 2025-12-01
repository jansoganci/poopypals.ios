-- PoopyPals iOS - Supabase Migration #3
-- Create avatar-related tables

-- Component type enum
CREATE TYPE component_type AS ENUM ('head', 'eyes', 'mouth', 'accessory');

-- Avatar components (global catalog)
CREATE TABLE IF NOT EXISTS avatar_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(200) NOT NULL,
    type component_type NOT NULL,
    svg_data TEXT NOT NULL,
    rarity VARCHAR(50) DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),

    -- Unlock conditions
    cost_flush_funds INTEGER DEFAULT 0 CHECK (cost_flush_funds >= 0),
    unlock_condition VARCHAR(200),
    is_default BOOLEAN DEFAULT false,

    -- Display
    preview_image_url TEXT,
    display_order INTEGER DEFAULT 0,

    is_active BOOLEAN DEFAULT true,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Device avatar inventory (unlocked components per device)
CREATE TABLE IF NOT EXISTS device_avatar_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE NOT NULL,
    component_id UUID REFERENCES avatar_components(id) ON DELETE CASCADE NOT NULL,

    unlocked_via VARCHAR(50) CHECK (unlocked_via IN ('purchase', 'achievement', 'default')),
    unlock_cost INTEGER DEFAULT 0,

    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    UNIQUE(device_id, component_id)
);

-- Avatar configs (current equipped components per device)
CREATE TABLE IF NOT EXISTS avatar_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE UNIQUE NOT NULL,

    head_component_id UUID REFERENCES avatar_components(id),
    eyes_component_id UUID REFERENCES avatar_components(id),
    mouth_component_id UUID REFERENCES avatar_components(id),
    accessory_component_id UUID REFERENCES avatar_components(id),

    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_avatar_components_type ON avatar_components(type) WHERE is_active = true;
CREATE INDEX idx_avatar_components_cost ON avatar_components(cost_flush_funds);
CREATE INDEX idx_avatar_components_default ON avatar_components(is_default) WHERE is_default = true;

CREATE INDEX idx_inventory_device ON device_avatar_inventory(device_id);
CREATE INDEX idx_inventory_component ON device_avatar_inventory(component_id);

CREATE INDEX idx_avatar_configs_device ON avatar_configs(device_id);

-- Enable RLS
ALTER TABLE avatar_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_avatar_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE avatar_configs ENABLE ROW LEVEL SECURITY;

-- RLS Policies - avatar_components (public read)
CREATE POLICY "Anyone can read avatar components" ON avatar_components
    FOR SELECT
    USING (is_active = true);

-- RLS Policies - device_avatar_inventory
CREATE POLICY "Devices can read own inventory" ON device_avatar_inventory
    FOR SELECT
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can add to own inventory" ON device_avatar_inventory
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

-- RLS Policies - avatar_configs
CREATE POLICY "Devices can read own config" ON avatar_configs
    FOR SELECT
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can update own config" ON avatar_configs
    FOR UPDATE
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can insert own config" ON avatar_configs
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

-- Triggers
CREATE TRIGGER update_avatar_components_updated_at
    BEFORE UPDATE ON avatar_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_avatar_configs_updated_at
    BEFORE UPDATE ON avatar_configs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE avatar_components IS 'Global catalog of available avatar components';
COMMENT ON TABLE device_avatar_inventory IS 'Tracks which components each device has unlocked';
COMMENT ON TABLE avatar_configs IS 'Current equipped avatar configuration per device';
