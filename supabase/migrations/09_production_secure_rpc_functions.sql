-- PoopyPals iOS - Migration #9
-- Production Secure RPC Functions
-- All CRUD operations go through RPC functions that enforce device-based security

-- ============================================================================
-- POOP LOGS RPC FUNCTIONS (6 functions)
-- ============================================================================

-- Function: Create Poop Log
CREATE OR REPLACE FUNCTION create_poop_log(
    p_device_id VARCHAR(255),
    p_log_data TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_log_id UUID;
    v_log_record RECORD;
    v_log_jsonb JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Parse JSON string to JSONB
    v_log_jsonb := p_log_data::JSONB;
    
    -- Insert log
    INSERT INTO poop_logs (
        device_id,
        logged_at,
        duration_seconds,
        rating,
        consistency,
        notes,
        flush_funds_earned,
        is_streak_counted,
        local_id,
        is_deleted,
        synced_at,
        created_at,
        updated_at
    ) VALUES (
        v_internal_device_id,
        (v_log_jsonb->>'logged_at')::TIMESTAMPTZ,
        (v_log_jsonb->>'duration_seconds')::INTEGER,
        v_log_jsonb->>'rating',
        (v_log_jsonb->>'consistency')::INTEGER,
        v_log_jsonb->>'notes',
        COALESCE((v_log_jsonb->>'flush_funds_earned')::INTEGER, 10),
        COALESCE((v_log_jsonb->>'is_streak_counted')::BOOLEAN, true),
        v_log_jsonb->>'local_id',
        COALESCE((v_log_jsonb->>'is_deleted')::BOOLEAN, false),
        CASE WHEN v_log_jsonb->>'synced_at' IS NOT NULL THEN (v_log_jsonb->>'synced_at')::TIMESTAMPTZ ELSE NULL END,
        COALESCE((v_log_jsonb->>'created_at')::TIMESTAMPTZ, NOW()),
        COALESCE((v_log_jsonb->>'updated_at')::TIMESTAMPTZ, NOW())
    ) RETURNING * INTO v_log_record;
    
    -- Return as JSONB
    RETURN row_to_json(v_log_record)::JSONB;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Update Poop Log
CREATE OR REPLACE FUNCTION update_poop_log(
    p_device_id VARCHAR(255),
    p_log_id UUID,
    p_log_data TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_log_record RECORD;
    v_log_jsonb JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Parse JSON string to JSONB
    v_log_jsonb := p_log_data::JSONB;
    
    -- Verify ownership and update
    UPDATE poop_logs
    SET
        logged_at = COALESCE((v_log_jsonb->>'logged_at')::TIMESTAMPTZ, logged_at),
        duration_seconds = COALESCE((v_log_jsonb->>'duration_seconds')::INTEGER, duration_seconds),
        rating = COALESCE(v_log_jsonb->>'rating', rating),
        consistency = COALESCE((v_log_jsonb->>'consistency')::INTEGER, consistency),
        notes = COALESCE(v_log_jsonb->>'notes', notes),
        flush_funds_earned = COALESCE((v_log_jsonb->>'flush_funds_earned')::INTEGER, flush_funds_earned),
        is_streak_counted = COALESCE((v_log_jsonb->>'is_streak_counted')::BOOLEAN, is_streak_counted),
        local_id = COALESCE(v_log_jsonb->>'local_id', local_id),
        is_deleted = COALESCE((v_log_jsonb->>'is_deleted')::BOOLEAN, is_deleted),
        synced_at = CASE WHEN v_log_jsonb->>'synced_at' IS NOT NULL THEN (v_log_jsonb->>'synced_at')::TIMESTAMPTZ ELSE synced_at END,
        updated_at = NOW()
    WHERE id = p_log_id
    AND device_id = v_internal_device_id
    RETURNING * INTO v_log_record;
    
    IF v_log_record.id IS NULL THEN
        RAISE EXCEPTION 'Log not found or access denied';
    END IF;
    
    -- Return as JSONB
    RETURN row_to_json(v_log_record)::JSONB;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Delete Poop Log (Soft Delete)
CREATE OR REPLACE FUNCTION delete_poop_log(
    p_device_id VARCHAR(255),
    p_log_id UUID
)
RETURNS VOID AS $$
DECLARE
    v_internal_device_id UUID;
    v_updated_count INTEGER;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Soft delete (verify ownership)
    UPDATE poop_logs
    SET is_deleted = true, updated_at = NOW()
    WHERE id = p_log_id
    AND device_id = v_internal_device_id;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    IF v_updated_count = 0 THEN
        RAISE EXCEPTION 'Log not found or access denied';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Fetch Poop Logs (Paginated)
CREATE OR REPLACE FUNCTION fetch_poop_logs(
    p_device_id VARCHAR(255),
    p_limit INT DEFAULT 30,
    p_offset INT DEFAULT 0
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_logs JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RETURN '[]'::JSONB;
    END IF;
    
    -- Fetch logs
    SELECT jsonb_agg(row_to_json(logs))
    INTO v_logs
    FROM (
        SELECT *
        FROM poop_logs
        WHERE device_id = v_internal_device_id
        AND is_deleted = false
        ORDER BY logged_at DESC
        LIMIT p_limit
        OFFSET p_offset
    ) logs;
    
    RETURN COALESCE(v_logs, '[]'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Fetch Today's Logs
CREATE OR REPLACE FUNCTION fetch_today_logs(
    p_device_id VARCHAR(255)
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_logs JSONB;
    v_today_start TIMESTAMPTZ;
    v_today_end TIMESTAMPTZ;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RETURN '[]'::JSONB;
    END IF;
    
    -- Calculate today's range
    v_today_start := date_trunc('day', NOW());
    v_today_end := v_today_start + INTERVAL '1 day';
    
    -- Fetch today's logs
    SELECT jsonb_agg(row_to_json(logs))
    INTO v_logs
    FROM (
        SELECT *
        FROM poop_logs
        WHERE device_id = v_internal_device_id
        AND is_deleted = false
        AND logged_at >= v_today_start
        AND logged_at < v_today_end
        ORDER BY logged_at DESC
    ) logs;
    
    RETURN COALESCE(v_logs, '[]'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Fetch Single Poop Log
CREATE OR REPLACE FUNCTION fetch_poop_log(
    p_device_id VARCHAR(255),
    p_log_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_log_record RECORD;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Fetch log (verify ownership)
    SELECT * INTO v_log_record
    FROM poop_logs
    WHERE id = p_log_id
    AND device_id = v_internal_device_id
    AND is_deleted = false;
    
    IF v_log_record.id IS NULL THEN
        RAISE EXCEPTION 'Log not found or access denied';
    END IF;
    
    -- Return as JSONB
    RETURN row_to_json(v_log_record)::JSONB;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ACHIEVEMENTS RPC FUNCTIONS (3 functions)
-- ============================================================================

-- Function: Fetch Unlocked Achievements
CREATE OR REPLACE FUNCTION fetch_unlocked_achievements(
    p_device_id VARCHAR(255)
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_achievements JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RETURN '[]'::JSONB;
    END IF;
    
    -- Fetch achievements
    SELECT jsonb_agg(row_to_json(achievements))
    INTO v_achievements
    FROM (
        SELECT *
        FROM achievements
        WHERE device_id = v_internal_device_id
        ORDER BY unlocked_at DESC
    ) achievements;
    
    RETURN COALESCE(v_achievements, '[]'::JSONB);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Unlock Achievement
CREATE OR REPLACE FUNCTION unlock_achievement(
    p_device_id VARCHAR(255),
    p_achievement_data TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_achievement_record RECORD;
    v_achievement_jsonb JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Parse JSON string to JSONB
    v_achievement_jsonb := p_achievement_data::JSONB;
    
    -- Insert achievement
    INSERT INTO achievements (
        device_id,
        achievement_key,
        achievement_type,
        title,
        description,
        icon_name,
        flush_funds_reward,
        avatar_component_unlock_id,
        unlocked_at,
        is_viewed,
        created_at
    ) VALUES (
        v_internal_device_id,
        v_achievement_jsonb->>'achievement_key',
        v_achievement_jsonb->>'achievement_type',
        v_achievement_jsonb->>'title',
        v_achievement_jsonb->>'description',
        v_achievement_jsonb->>'icon_name',
        COALESCE((v_achievement_jsonb->>'flush_funds_reward')::INTEGER, 0),
        CASE WHEN v_achievement_jsonb->>'avatar_component_unlock_id' IS NOT NULL 
             THEN (v_achievement_jsonb->>'avatar_component_unlock_id')::UUID 
             ELSE NULL END,
        COALESCE((v_achievement_jsonb->>'unlocked_at')::TIMESTAMPTZ, NOW()),
        COALESCE((v_achievement_jsonb->>'is_viewed')::BOOLEAN, false),
        NOW()
    ) RETURNING * INTO v_achievement_record;
    
    -- Award flush funds if reward > 0
    IF v_achievement_record.flush_funds_reward > 0 THEN
        PERFORM award_flush_funds(v_internal_device_id, v_achievement_record.flush_funds_reward);
    END IF;
    
    -- Return as JSONB
    RETURN row_to_json(v_achievement_record)::JSONB;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Mark Achievement as Viewed
CREATE OR REPLACE FUNCTION mark_achievement_viewed(
    p_device_id VARCHAR(255),
    p_achievement_id UUID
)
RETURNS VOID AS $$
DECLARE
    v_internal_device_id UUID;
    v_updated_count INTEGER;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Update is_viewed (verify ownership)
    UPDATE achievements
    SET is_viewed = true
    WHERE id = p_achievement_id
    AND device_id = v_internal_device_id;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    IF v_updated_count = 0 THEN
        RAISE EXCEPTION 'Achievement not found or access denied';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DEVICE STATS RPC FUNCTIONS (2 functions)
-- ============================================================================

-- Function: Fetch Device Stats
CREATE OR REPLACE FUNCTION fetch_device_stats(
    p_device_id VARCHAR(255)
)
RETURNS JSONB AS $$
DECLARE
    v_internal_device_id UUID;
    v_stats RECORD;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Fetch stats from devices table
    SELECT 
        streak_count,
        flush_funds,
        total_logs,
        last_log_date
    INTO v_stats
    FROM devices
    WHERE id = v_internal_device_id;
    
    IF v_stats IS NULL THEN
        RAISE EXCEPTION 'Device not found';
    END IF;
    
    -- Return as JSONB
    RETURN jsonb_build_object(
        'streak_count', v_stats.streak_count,
        'flush_funds', v_stats.flush_funds,
        'total_logs', v_stats.total_logs,
        'last_log_date', v_stats.last_log_date
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Update Device Stats Fields
CREATE OR REPLACE FUNCTION update_device_stats_fields(
    p_device_id VARCHAR(255),
    p_stats_data TEXT
)
RETURNS VOID AS $$
DECLARE
    v_internal_device_id UUID;
    v_stats_jsonb JSONB;
BEGIN
    -- Get internal device ID
    v_internal_device_id := get_device_internal_id(p_device_id);
    
    IF v_internal_device_id IS NULL THEN
        RAISE EXCEPTION 'Device not registered';
    END IF;
    
    -- Parse JSON string to JSONB
    v_stats_jsonb := p_stats_data::JSONB;
    
    -- Update stats (only update provided fields)
    UPDATE devices
    SET
        streak_count = COALESCE((v_stats_jsonb->>'streak_count')::INTEGER, streak_count),
        flush_funds = COALESCE((v_stats_jsonb->>'flush_funds')::INTEGER, flush_funds),
        total_logs = COALESCE((v_stats_jsonb->>'total_logs')::INTEGER, total_logs),
        last_log_date = CASE WHEN v_stats_jsonb->>'last_log_date' IS NOT NULL 
                            THEN (v_stats_jsonb->>'last_log_date')::DATE 
                            ELSE last_log_date END,
        updated_at = NOW()
    WHERE id = v_internal_device_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

-- Grant execute permissions to anonymous users
GRANT EXECUTE ON FUNCTION create_poop_log(VARCHAR, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION update_poop_log(VARCHAR, UUID, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION delete_poop_log(VARCHAR, UUID) TO anon;
GRANT EXECUTE ON FUNCTION fetch_poop_logs(VARCHAR, INT, INT) TO anon;
GRANT EXECUTE ON FUNCTION fetch_today_logs(VARCHAR) TO anon;
GRANT EXECUTE ON FUNCTION fetch_poop_log(VARCHAR, UUID) TO anon;

GRANT EXECUTE ON FUNCTION fetch_unlocked_achievements(VARCHAR) TO anon;
GRANT EXECUTE ON FUNCTION unlock_achievement(VARCHAR, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION mark_achievement_viewed(VARCHAR, UUID) TO anon;

GRANT EXECUTE ON FUNCTION fetch_device_stats(VARCHAR) TO anon;
GRANT EXECUTE ON FUNCTION update_device_stats_fields(VARCHAR, TEXT) TO anon;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION create_poop_log IS 'Creates a poop log for the specified device. Enforces device ownership.';
COMMENT ON FUNCTION update_poop_log IS 'Updates a poop log. Verifies device ownership before update.';
COMMENT ON FUNCTION delete_poop_log IS 'Soft deletes a poop log. Verifies device ownership before delete.';
COMMENT ON FUNCTION fetch_poop_logs IS 'Fetches paginated poop logs for the specified device.';
COMMENT ON FUNCTION fetch_today_logs IS 'Fetches today''s poop logs for the specified device.';
COMMENT ON FUNCTION fetch_poop_log IS 'Fetches a single poop log. Verifies device ownership.';

COMMENT ON FUNCTION fetch_unlocked_achievements IS 'Fetches all unlocked achievements for the specified device.';
COMMENT ON FUNCTION unlock_achievement IS 'Unlocks an achievement for the specified device and awards flush funds.';
COMMENT ON FUNCTION mark_achievement_viewed IS 'Marks an achievement as viewed. Verifies device ownership.';

COMMENT ON FUNCTION fetch_device_stats IS 'Fetches device statistics (streak, flush funds, total logs).';
COMMENT ON FUNCTION update_device_stats_fields IS 'Updates device statistics fields. Only updates provided fields.';

