-- PoopyPals iOS - Migration #7
-- Fix RLS policies to work without session variables
-- Solution: Create SECURITY DEFINER functions that bypass RLS for device operations

-- Function to register or get device (bypasses RLS)
CREATE OR REPLACE FUNCTION register_or_get_device(
    p_device_id VARCHAR(255),
    p_platform VARCHAR(50) DEFAULT 'ios',
    p_app_version VARCHAR(20) DEFAULT NULL,
    p_os_version VARCHAR(20) DEFAULT NULL,
    p_device_model VARCHAR(100) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_device_record devices%ROWTYPE;
    v_device_internal_id UUID;
BEGIN
    -- Try to find existing device
    SELECT * INTO v_device_record
    FROM devices
    WHERE device_id = p_device_id
    LIMIT 1;

    IF FOUND THEN
        -- Device exists, update last_seen_at
        UPDATE devices
        SET last_seen_at = NOW(),
            updated_at = NOW()
        WHERE id = v_device_record.id;
        
        RETURN v_device_record.id;
    ELSE
        -- Device doesn't exist, create it
        INSERT INTO devices (
            device_id,
            platform,
            app_version,
            os_version,
            device_model,
            first_seen_at,
            last_seen_at
        ) VALUES (
            p_device_id,
            p_platform,
            p_app_version,
            p_os_version,
            p_device_model,
            NOW(),
            NOW()
        ) RETURNING id INTO v_device_internal_id;
        
        RETURN v_device_internal_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get device internal ID by device_id string
CREATE OR REPLACE FUNCTION get_device_internal_id(p_device_id VARCHAR(255))
RETURNS UUID AS $$
DECLARE
    v_internal_id UUID;
BEGIN
    SELECT id INTO v_internal_id
    FROM devices
    WHERE device_id = p_device_id
    LIMIT 1;
    
    RETURN v_internal_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update RLS policies to be more permissive for device-based auth
-- Drop old restrictive policies
DROP POLICY IF EXISTS "Devices can read own data" ON devices;
DROP POLICY IF EXISTS "Devices can update own data" ON devices;

-- New policies: Allow operations when filtering by device_id
-- SELECT: Allow reading devices (app filters by device_id in WHERE clause)
CREATE POLICY "Allow device reads by device_id" ON devices
    FOR SELECT
    USING (true);

-- UPDATE: Allow updating devices (app filters by device_id in WHERE clause)
CREATE POLICY "Allow device updates by device_id" ON devices
    FOR UPDATE
    USING (true);

-- INSERT already works (existing policy)

-- Update poop_logs policies
DROP POLICY IF EXISTS "Devices can read own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can insert own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can update own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can delete own logs" ON poop_logs;

-- New policies for poop_logs
CREATE POLICY "Allow log reads" ON poop_logs
    FOR SELECT
    USING (true);

CREATE POLICY "Allow log inserts" ON poop_logs
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow log updates" ON poop_logs
    FOR UPDATE
    USING (true);

CREATE POLICY "Allow log deletes" ON poop_logs
    FOR DELETE
    USING (true);

COMMENT ON FUNCTION register_or_get_device IS 'Registers or retrieves device. Bypasses RLS for device registration.';
COMMENT ON FUNCTION get_device_internal_id IS 'Gets device internal UUID by device_id string. Bypasses RLS.';

