-- PoopyPals iOS - Supabase Migration #5
-- Helper functions and stored procedures

-- Function to calculate streak for a device
CREATE OR REPLACE FUNCTION calculate_streak(p_device_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_streak INTEGER := 0;
    v_current_date DATE := CURRENT_DATE;
    v_log_exists BOOLEAN;
BEGIN
    LOOP
        SELECT EXISTS(
            SELECT 1 FROM poop_logs
            WHERE device_id = p_device_id
            AND logged_at::date = v_current_date
            AND is_deleted = false
        ) INTO v_log_exists;

        EXIT WHEN NOT v_log_exists;

        v_streak := v_streak + 1;
        v_current_date := v_current_date - INTERVAL '1 day';
    END LOOP;

    RETURN v_streak;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to update device stats (can be called manually)
CREATE OR REPLACE FUNCTION update_device_stats(p_device_id UUID)
RETURNS VOID AS $$
DECLARE
    v_total_logs INTEGER;
    v_last_log_date DATE;
    v_streak INTEGER;
BEGIN
    -- Calculate total logs
    SELECT COUNT(*) INTO v_total_logs
    FROM poop_logs
    WHERE device_id = p_device_id AND is_deleted = false;

    -- Get last log date
    SELECT MAX(logged_at::date) INTO v_last_log_date
    FROM poop_logs
    WHERE device_id = p_device_id AND is_deleted = false;

    -- Calculate streak
    v_streak := calculate_streak(p_device_id);

    -- Update device
    UPDATE devices
    SET
        total_logs = v_total_logs,
        last_log_date = v_last_log_date,
        streak_count = v_streak,
        updated_at = NOW()
    WHERE id = p_device_id;
END;
$$ LANGUAGE plpgsql;

-- Function to award flush funds
CREATE OR REPLACE FUNCTION award_flush_funds(p_device_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE devices
    SET
        flush_funds = flush_funds + p_amount,
        updated_at = NOW()
    WHERE id = p_device_id;
END;
$$ LANGUAGE plpgsql;

-- Function to check and award achievement
CREATE OR REPLACE FUNCTION check_and_award_achievement(
    p_device_id UUID,
    p_achievement_key VARCHAR,
    p_title VARCHAR,
    p_description TEXT,
    p_type VARCHAR,
    p_reward INTEGER DEFAULT 50
)
RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Check if achievement already unlocked
    SELECT EXISTS(
        SELECT 1 FROM achievements
        WHERE device_id = p_device_id AND achievement_key = p_achievement_key
    ) INTO v_exists;

    IF v_exists THEN
        RETURN false;
    END IF;

    -- Insert achievement
    INSERT INTO achievements (
        device_id, achievement_key, achievement_type,
        title, description, flush_funds_reward
    ) VALUES (
        p_device_id, p_achievement_key, p_type,
        p_title, p_description, p_reward
    );

    -- Award flush funds
    PERFORM award_flush_funds(p_device_id, p_reward);

    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Function to unlock default avatar components for new device
CREATE OR REPLACE FUNCTION setup_default_avatar(p_device_id UUID)
RETURNS VOID AS $$
DECLARE
    v_component RECORD;
BEGIN
    -- Unlock all default components
    FOR v_component IN
        SELECT id FROM avatar_components WHERE is_default = true
    LOOP
        INSERT INTO device_avatar_inventory (device_id, component_id, unlocked_via)
        VALUES (p_device_id, v_component.id, 'default')
        ON CONFLICT (device_id, component_id) DO NOTHING;
    END LOOP;

    -- Create avatar config with defaults
    INSERT INTO avatar_configs (
        device_id,
        head_component_id,
        eyes_component_id,
        mouth_component_id
    )
    SELECT
        p_device_id,
        (SELECT id FROM avatar_components WHERE type = 'head' AND is_default = true LIMIT 1),
        (SELECT id FROM avatar_components WHERE type = 'eyes' AND is_default = true LIMIT 1),
        (SELECT id FROM avatar_components WHERE type = 'mouth' AND is_default = true LIMIT 1)
    ON CONFLICT (device_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Trigger to setup avatar on new device
CREATE OR REPLACE FUNCTION setup_new_device()
RETURNS TRIGGER AS $$
BEGIN
    -- Setup default avatar components
    PERFORM setup_default_avatar(NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_setup_new_device
    AFTER INSERT ON devices
    FOR EACH ROW
    EXECUTE FUNCTION setup_new_device();

COMMENT ON FUNCTION calculate_streak IS 'Calculates current streak for a device';
COMMENT ON FUNCTION update_device_stats IS 'Manually updates device statistics';
COMMENT ON FUNCTION award_flush_funds IS 'Awards flush funds to a device';
COMMENT ON FUNCTION check_and_award_achievement IS 'Checks and awards achievement if not already unlocked';
COMMENT ON FUNCTION setup_default_avatar IS 'Sets up default avatar components for new device';
