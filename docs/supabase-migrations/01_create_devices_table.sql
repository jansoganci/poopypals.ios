-- PoopyPals iOS - Supabase Migration #1
-- Create devices table for device-based authentication

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create devices table
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(255) UNIQUE NOT NULL,
    platform VARCHAR(50) NOT NULL DEFAULT 'ios',
    app_version VARCHAR(20),
    os_version VARCHAR(20),
    device_model VARCHAR(100),

    -- Denormalized stats for performance
    streak_count INTEGER DEFAULT 0 NOT NULL,
    total_logs INTEGER DEFAULT 0 NOT NULL,
    flush_funds INTEGER DEFAULT 0 NOT NULL,
    last_log_date DATE,

    -- Metadata
    first_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_last_seen ON devices(last_seen_at);
CREATE INDEX idx_devices_active ON devices(is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

-- Function to get current device ID from session
CREATE OR REPLACE FUNCTION get_current_device_id()
RETURNS UUID AS $$
BEGIN
    RETURN current_setting('app.device_id', TRUE)::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- RLS Policies
CREATE POLICY "Devices can read own data" ON devices
    FOR SELECT
    USING (id = get_current_device_id() OR device_id = current_setting('app.device_id', TRUE));

CREATE POLICY "Devices can update own data" ON devices
    FOR UPDATE
    USING (id = get_current_device_id());

CREATE POLICY "Anyone can insert devices" ON devices
    FOR INSERT
    WITH CHECK (true);

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_devices_updated_at
    BEFORE UPDATE ON devices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE devices IS 'Stores device registrations for anonymous device-based authentication';
