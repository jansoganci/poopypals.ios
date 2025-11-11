-- PoopyPals iOS - Supabase Migration #2
-- Create poop_logs table for tracking bathroom visits

CREATE TABLE IF NOT EXISTS poop_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE NOT NULL,

    -- Core data
    logged_at TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0 AND duration_seconds <= 7200),
    rating VARCHAR(20) NOT NULL CHECK (rating IN ('great', 'good', 'okay', 'bad', 'terrible')),
    consistency INTEGER NOT NULL CHECK (consistency BETWEEN 1 AND 7),
    notes TEXT,

    -- Gamification
    flush_funds_earned INTEGER DEFAULT 10 NOT NULL,
    is_streak_counted BOOLEAN DEFAULT true,

    -- Sync metadata
    local_id VARCHAR(100),
    is_deleted BOOLEAN DEFAULT false NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes for performance
CREATE INDEX idx_poop_logs_device ON poop_logs(device_id) WHERE is_deleted = false;
CREATE INDEX idx_poop_logs_logged_at ON poop_logs(logged_at DESC);
CREATE INDEX idx_poop_logs_device_date ON poop_logs(device_id, logged_at DESC) WHERE is_deleted = false;
CREATE INDEX idx_poop_logs_sync ON poop_logs(device_id, synced_at) WHERE is_deleted = false;
CREATE INDEX idx_poop_logs_local_id ON poop_logs(device_id, local_id) WHERE local_id IS NOT NULL;

-- Enable RLS
ALTER TABLE poop_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Devices can read own logs" ON poop_logs
    FOR SELECT
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can insert own logs" ON poop_logs
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

CREATE POLICY "Devices can update own logs" ON poop_logs
    FOR UPDATE
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can delete own logs" ON poop_logs
    FOR DELETE
    USING (device_id = get_current_device_id());

-- Trigger for updated_at
CREATE TRIGGER update_poop_logs_updated_at
    BEFORE UPDATE ON poop_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to update device stats after log insert
CREATE OR REPLACE FUNCTION update_device_stats_on_log()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total logs count
    UPDATE devices
    SET
        total_logs = total_logs + 1,
        last_log_date = NEW.logged_at::date,
        updated_at = NOW()
    WHERE id = NEW.device_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_device_stats_after_log_insert
    AFTER INSERT ON poop_logs
    FOR EACH ROW
    WHEN (NEW.is_deleted = false)
    EXECUTE FUNCTION update_device_stats_on_log();

COMMENT ON TABLE poop_logs IS 'Stores bathroom visit logs with metrics and gamification data';
