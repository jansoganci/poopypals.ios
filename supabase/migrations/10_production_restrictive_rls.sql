-- PoopyPals iOS - Migration #10
-- Production Restrictive RLS Policies
-- Blocks all direct table access, forcing use of RPC functions for security

-- ============================================================================
-- DROP PERMISSIVE POLICIES
-- ============================================================================

-- Drop existing permissive policies from migration #7
DROP POLICY IF EXISTS "Allow device reads by device_id" ON devices;
DROP POLICY IF EXISTS "Allow device updates by device_id" ON devices;
DROP POLICY IF EXISTS "Allow log reads" ON poop_logs;
DROP POLICY IF EXISTS "Allow log inserts" ON poop_logs;
DROP POLICY IF EXISTS "Allow log updates" ON poop_logs;
DROP POLICY IF EXISTS "Allow log deletes" ON poop_logs;
DROP POLICY IF EXISTS "Allow log inserts with valid device" ON poop_logs;

-- Drop old policies from migration #1 and #2 (if they still exist)
DROP POLICY IF EXISTS "Devices can read own data" ON devices;
DROP POLICY IF EXISTS "Devices can update own data" ON devices;
DROP POLICY IF EXISTS "Devices can read own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can insert own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can update own logs" ON poop_logs;
DROP POLICY IF EXISTS "Devices can delete own logs" ON poop_logs;

-- ============================================================================
-- DEVICES TABLE - RESTRICTIVE POLICIES
-- ============================================================================

-- Drop new restrictive policies if they already exist (for idempotency)
DROP POLICY IF EXISTS "Deny device reads" ON devices;
DROP POLICY IF EXISTS "Allow device inserts" ON devices;
DROP POLICY IF EXISTS "Deny device updates" ON devices;

-- SELECT: Deny all direct reads (only RPC functions can read via SECURITY DEFINER)
-- This prevents users from querying devices table directly
CREATE POLICY "Deny device reads" ON devices
    FOR SELECT
    USING (false);

-- INSERT: Keep permissive (device registration needs this)
-- Device registration uses RPC function, but INSERT policy must allow it
-- The RPC function register_or_get_device uses SECURITY DEFINER, so it bypasses RLS anyway
-- But we keep this policy for safety
CREATE POLICY "Allow device inserts" ON devices
    FOR INSERT
    WITH CHECK (true);

-- UPDATE: Deny all direct updates (only RPC functions can update)
CREATE POLICY "Deny device updates" ON devices
    FOR UPDATE
    USING (false);

-- ============================================================================
-- POOP_LOGS TABLE - RESTRICTIVE POLICIES
-- ============================================================================

-- Drop new restrictive policies if they already exist (for idempotency)
DROP POLICY IF EXISTS "Deny log reads" ON poop_logs;
DROP POLICY IF EXISTS "Deny log inserts" ON poop_logs;
DROP POLICY IF EXISTS "Deny log updates" ON poop_logs;
DROP POLICY IF EXISTS "Deny log deletes" ON poop_logs;

-- SELECT: Deny all direct reads (only RPC functions can read)
CREATE POLICY "Deny log reads" ON poop_logs
    FOR SELECT
    USING (false);

-- INSERT: Deny all direct inserts (only RPC functions can insert)
CREATE POLICY "Deny log inserts" ON poop_logs
    FOR INSERT
    WITH CHECK (false);

-- UPDATE: Deny all direct updates (only RPC functions can update)
CREATE POLICY "Deny log updates" ON poop_logs
    FOR UPDATE
    USING (false);

-- DELETE: Deny all direct deletes (only RPC functions can delete)
CREATE POLICY "Deny log deletes" ON poop_logs
    FOR DELETE
    USING (false);

-- ============================================================================
-- ACHIEVEMENTS TABLE - RESTRICTIVE POLICIES
-- ============================================================================

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Devices can read own achievements" ON achievements;
DROP POLICY IF EXISTS "Devices can insert own achievements" ON achievements;
DROP POLICY IF EXISTS "Devices can update own achievements" ON achievements;

-- Drop new restrictive policies if they already exist (for idempotency)
DROP POLICY IF EXISTS "Deny achievement reads" ON achievements;
DROP POLICY IF EXISTS "Deny achievement inserts" ON achievements;
DROP POLICY IF EXISTS "Deny achievement updates" ON achievements;

-- SELECT: Deny all direct reads (only RPC functions can read)
CREATE POLICY "Deny achievement reads" ON achievements
    FOR SELECT
    USING (false);

-- INSERT: Deny all direct inserts (only RPC functions can insert)
CREATE POLICY "Deny achievement inserts" ON achievements
    FOR INSERT
    WITH CHECK (false);

-- UPDATE: Deny all direct updates (only RPC functions can update)
CREATE POLICY "Deny achievement updates" ON achievements
    FOR UPDATE
    USING (false);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON POLICY "Deny device reads" ON devices IS 
    'Blocks direct SELECT access. Use fetch_device_stats() RPC function instead.';

COMMENT ON POLICY "Deny log reads" ON poop_logs IS 
    'Blocks direct SELECT access. Use fetch_poop_logs() or fetch_today_logs() RPC functions instead.';

COMMENT ON POLICY "Deny log inserts" ON poop_logs IS 
    'Blocks direct INSERT access. Use create_poop_log() RPC function instead.';

COMMENT ON POLICY "Deny log updates" ON poop_logs IS 
    'Blocks direct UPDATE access. Use update_poop_log() RPC function instead.';

COMMENT ON POLICY "Deny log deletes" ON poop_logs IS 
    'Blocks direct DELETE access. Use delete_poop_log() RPC function instead.';

COMMENT ON POLICY "Deny achievement reads" ON achievements IS 
    'Blocks direct SELECT access. Use fetch_unlocked_achievements() RPC function instead.';

COMMENT ON POLICY "Deny achievement inserts" ON achievements IS 
    'Blocks direct INSERT access. Use unlock_achievement() RPC function instead.';

COMMENT ON POLICY "Deny achievement updates" ON achievements IS 
    'Blocks direct UPDATE access. Use mark_achievement_viewed() RPC function instead.';

