-- PoopyPals iOS - Supabase Migration #6
-- Create leaderboard functions for competitive rankings

-- Weekly Leaderboard Function
CREATE OR REPLACE FUNCTION get_weekly_leaderboard(
    p_metric VARCHAR,  -- 'streak', 'total_logs', or 'flush_funds'
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY 
            CASE p_metric
                WHEN 'streak' THEN d.streak_count
                WHEN 'total_logs' THEN d.total_logs
                WHEN 'flush_funds' THEN d.flush_funds
                ELSE d.streak_count
            END DESC
        )::INTEGER as rank,
        d.id as device_id,
        d.streak_count,
        d.total_logs,
        d.flush_funds,
        d.last_seen_at
    FROM devices d
    WHERE 
        d.is_active = true
        AND d.last_seen_at >= NOW() - INTERVAL '30 days'
        AND (
            CASE p_metric
                WHEN 'streak' THEN d.streak_count > 0
                WHEN 'total_logs' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '7 days'
                    AND pl.is_deleted = false
                )
                WHEN 'flush_funds' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '7 days'
                    AND pl.is_deleted = false
                )
                ELSE true
            END
        )
    ORDER BY 
        CASE p_metric
            WHEN 'streak' THEN d.streak_count
            WHEN 'total_logs' THEN d.total_logs
            WHEN 'flush_funds' THEN d.flush_funds
            ELSE d.streak_count
        END DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Monthly Leaderboard Function
CREATE OR REPLACE FUNCTION get_monthly_leaderboard(
    p_metric VARCHAR,  -- 'streak', 'total_logs', or 'flush_funds'
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY 
            CASE p_metric
                WHEN 'streak' THEN d.streak_count
                WHEN 'total_logs' THEN d.total_logs
                WHEN 'flush_funds' THEN d.flush_funds
                ELSE d.streak_count
            END DESC
        )::INTEGER as rank,
        d.id as device_id,
        d.streak_count,
        d.total_logs,
        d.flush_funds,
        d.last_seen_at
    FROM devices d
    WHERE 
        d.is_active = true
        AND d.last_seen_at >= NOW() - INTERVAL '30 days'
        AND (
            CASE p_metric
                WHEN 'streak' THEN d.streak_count > 0
                WHEN 'total_logs' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '30 days'
                    AND pl.is_deleted = false
                )
                WHEN 'flush_funds' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '30 days'
                    AND pl.is_deleted = false
                )
                ELSE true
            END
        )
    ORDER BY 
        CASE p_metric
            WHEN 'streak' THEN d.streak_count
            WHEN 'total_logs' THEN d.total_logs
            WHEN 'flush_funds' THEN d.flush_funds
            ELSE d.streak_count
        END DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Yearly Leaderboard Function
CREATE OR REPLACE FUNCTION get_yearly_leaderboard(
    p_metric VARCHAR,  -- 'streak', 'total_logs', or 'flush_funds'
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY 
            CASE p_metric
                WHEN 'streak' THEN d.streak_count
                WHEN 'total_logs' THEN d.total_logs
                WHEN 'flush_funds' THEN d.flush_funds
                ELSE d.streak_count
            END DESC
        )::INTEGER as rank,
        d.id as device_id,
        d.streak_count,
        d.total_logs,
        d.flush_funds,
        d.last_seen_at
    FROM devices d
    WHERE 
        d.is_active = true
        AND d.last_seen_at >= NOW() - INTERVAL '30 days'
        AND (
            CASE p_metric
                WHEN 'streak' THEN d.streak_count > 0
                WHEN 'total_logs' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '365 days'
                    AND pl.is_deleted = false
                )
                WHEN 'flush_funds' THEN EXISTS (
                    SELECT 1 FROM poop_logs pl
                    WHERE pl.device_id = d.id
                    AND pl.logged_at >= NOW() - INTERVAL '365 days'
                    AND pl.is_deleted = false
                )
                ELSE true
            END
        )
    ORDER BY 
        CASE p_metric
            WHEN 'streak' THEN d.streak_count
            WHEN 'total_logs' THEN d.total_logs
            WHEN 'flush_funds' THEN d.flush_funds
            ELSE d.streak_count
        END DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- User Rank Function
CREATE OR REPLACE FUNCTION get_user_rank(
    p_device_id VARCHAR,  -- device_id as VARCHAR (UUID string)
    p_period VARCHAR,     -- 'weekly', 'monthly', 'yearly'
    p_metric VARCHAR      -- 'streak', 'total_logs', 'flush_funds'
)
RETURNS TABLE (
    rank INTEGER,
    device_id UUID,
    streak_count INTEGER,
    total_logs INTEGER,
    flush_funds INTEGER,
    last_seen_at TIMESTAMPTZ
) AS $$
DECLARE
    v_interval INTERVAL;
    v_internal_device_id UUID;
BEGIN
    -- Get internal device ID from device_id string
    SELECT id INTO v_internal_device_id
    FROM devices d
    WHERE d.device_id = p_device_id
    LIMIT 1;
    
    -- If device not found, return empty
    IF v_internal_device_id IS NULL THEN
        RETURN;
    END IF;
    
    -- Determine time interval based on period
    CASE p_period
        WHEN 'weekly' THEN v_interval := INTERVAL '7 days';
        WHEN 'monthly' THEN v_interval := INTERVAL '30 days';
        WHEN 'yearly' THEN v_interval := INTERVAL '365 days';
        ELSE v_interval := INTERVAL '7 days';
    END CASE;
    
    RETURN QUERY
    WITH ranked_devices AS (
        SELECT
            d.id,
            d.streak_count,
            d.total_logs,
            d.flush_funds,
            d.last_seen_at,
            ROW_NUMBER() OVER (ORDER BY 
                CASE p_metric
                    WHEN 'streak' THEN d.streak_count
                    WHEN 'total_logs' THEN d.total_logs
                    WHEN 'flush_funds' THEN d.flush_funds
                    ELSE d.streak_count
                END DESC
            )::INTEGER as rank
        FROM devices d
        WHERE 
            d.is_active = true
            AND d.last_seen_at >= NOW() - INTERVAL '30 days'
            AND (
                CASE p_metric
                    WHEN 'streak' THEN d.streak_count > 0
                    WHEN 'total_logs' THEN EXISTS (
                        SELECT 1 FROM poop_logs pl
                        WHERE pl.device_id = d.id
                        AND pl.logged_at >= NOW() - v_interval
                        AND pl.is_deleted = false
                    )
                    WHEN 'flush_funds' THEN EXISTS (
                        SELECT 1 FROM poop_logs pl
                        WHERE pl.device_id = d.id
                        AND pl.logged_at >= NOW() - v_interval
                        AND pl.is_deleted = false
                    )
                    ELSE true
                END
            )
    )
    SELECT
        rd.rank,
        rd.id as device_id,
        rd.streak_count,
        rd.total_logs,
        rd.flush_funds,
        rd.last_seen_at
    FROM ranked_devices rd
    WHERE rd.id = v_internal_device_id;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions to anonymous users (public leaderboards)
GRANT EXECUTE ON FUNCTION get_weekly_leaderboard(VARCHAR, INTEGER) TO anon;
GRANT EXECUTE ON FUNCTION get_monthly_leaderboard(VARCHAR, INTEGER) TO anon;
GRANT EXECUTE ON FUNCTION get_yearly_leaderboard(VARCHAR, INTEGER) TO anon;
GRANT EXECUTE ON FUNCTION get_user_rank(VARCHAR, VARCHAR, VARCHAR) TO anon;

-- Add function comments for documentation
COMMENT ON FUNCTION get_weekly_leaderboard IS 'Returns weekly leaderboard rankings based on specified metric (streak, total_logs, or flush_funds)';
COMMENT ON FUNCTION get_monthly_leaderboard IS 'Returns monthly leaderboard rankings based on specified metric (streak, total_logs, or flush_funds)';
COMMENT ON FUNCTION get_yearly_leaderboard IS 'Returns yearly leaderboard rankings based on specified metric (streak, total_logs, or flush_funds)';
COMMENT ON FUNCTION get_user_rank IS 'Returns the rank of a specific user for the given period and metric';

