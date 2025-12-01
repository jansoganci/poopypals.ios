-- PoopyPals iOS - Supabase Migration #4
-- Create achievements and challenges tables

-- Achievements table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE NOT NULL,

    achievement_key VARCHAR(100) NOT NULL,
    achievement_type VARCHAR(50) NOT NULL CHECK (achievement_type IN ('milestone', 'streak', 'special')),

    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    icon_name VARCHAR(100),

    flush_funds_reward INTEGER DEFAULT 0,
    avatar_component_unlock_id UUID REFERENCES avatar_components(id),

    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    is_viewed BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Challenge types
CREATE TYPE challenge_type AS ENUM ('daily', 'streak', 'milestone');
CREATE TYPE condition_type AS ENUM ('log_count', 'consistent_time', 'rating_achieved', 'streak_reached');

-- Challenges table (global)
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    challenge_type challenge_type NOT NULL,

    flush_funds_reward INTEGER DEFAULT 50 NOT NULL,
    bonus_multiplier DECIMAL(3,2) DEFAULT 1.0,

    condition_type condition_type NOT NULL,
    condition_target INTEGER NOT NULL,
    timeframe_days INTEGER,

    is_active BOOLEAN DEFAULT true NOT NULL,
    start_date DATE,
    end_date DATE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Device challenge progress
CREATE TABLE IF NOT EXISTS device_challenge_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE NOT NULL,
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE NOT NULL,

    current_progress INTEGER DEFAULT 0 NOT NULL,
    is_completed BOOLEAN DEFAULT false NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,

    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_progress_at TIMESTAMP WITH TIME ZONE,

    UNIQUE(device_id, challenge_id)
);

-- Indexes
CREATE INDEX idx_achievements_device ON achievements(device_id);
CREATE INDEX idx_achievements_unlocked ON achievements(unlocked_at DESC);
CREATE UNIQUE INDEX idx_achievements_unique ON achievements(device_id, achievement_key);

CREATE INDEX idx_challenges_active ON challenges(is_active) WHERE is_active = true;
CREATE INDEX idx_challenges_type ON challenges(challenge_type);
CREATE INDEX idx_challenges_dates ON challenges(start_date, end_date);

CREATE INDEX idx_challenge_progress_device ON device_challenge_progress(device_id);
CREATE INDEX idx_challenge_progress_active ON device_challenge_progress(device_id, is_completed)
    WHERE is_completed = false;

-- Enable RLS
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_challenge_progress ENABLE ROW LEVEL SECURITY;

-- RLS Policies - achievements
CREATE POLICY "Devices can read own achievements" ON achievements
    FOR SELECT
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can insert own achievements" ON achievements
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

-- RLS Policies - challenges (public read)
CREATE POLICY "Anyone can read active challenges" ON challenges
    FOR SELECT
    USING (is_active = true);

-- RLS Policies - device_challenge_progress
CREATE POLICY "Devices can read own progress" ON device_challenge_progress
    FOR SELECT
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can update own progress" ON device_challenge_progress
    FOR UPDATE
    USING (device_id = get_current_device_id());

CREATE POLICY "Devices can insert own progress" ON device_challenge_progress
    FOR INSERT
    WITH CHECK (device_id = get_current_device_id());

-- Triggers
CREATE TRIGGER update_challenges_updated_at
    BEFORE UPDATE ON challenges
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE achievements IS 'Tracks unlocked achievements per device';
COMMENT ON TABLE challenges IS 'Global challenge definitions';
COMMENT ON TABLE device_challenge_progress IS 'Tracks challenge progress per device';
