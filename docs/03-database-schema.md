# PoopyPals iOS - Database Schema (Supabase/PostgreSQL)

## 🗄️ Schema Overview

PoopyPals uses **Supabase (PostgreSQL)** for cloud storage with device-based identification (no authentication required). The schema is optimized for iOS with efficient querying, minimal joins, and offline-first design.

## 🔑 Key Design Principles

1. **Device-Based Sync** - No user accounts, data tied to device IDs
2. **Denormalization for Performance** - Optimize for read-heavy iOS operations
3. **Timestamp Everything** - Enable sync conflict resolution
4. **Soft Deletes** - Support undo and sync reconciliation
5. **Efficient Indexing** - Fast queries for common iOS use cases

## 📊 Schema Diagram

```
┌──────────────┐         ┌──────────────┐
│   devices    │◄────────│  poop_logs   │
└──────────────┘         └──────────────┘
       │                        │
       │                        │
       ▼                        ▼
┌──────────────┐         ┌──────────────┐
│ device_stats │         │ achievements │
└──────────────┘         └──────────────┘
       │
       │
       ▼
┌──────────────┐         ┌──────────────┐
│avatar_configs│◄────────│avatar_components│
└──────────────┘         └──────────────┘
       │
       │
       ▼
┌──────────────┐
│  challenges  │
└──────────────┘
```

## 📋 Table Definitions

### 1. `devices` - Device Registry
Stores device information for anonymous sync.

```sql
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(255) UNIQUE NOT NULL,           -- iOS Keychain UUID
    platform VARCHAR(50) NOT NULL DEFAULT 'ios',      -- 'ios', 'android', 'web'
    app_version VARCHAR(20),                          -- e.g., "1.0.0"
    os_version VARCHAR(20),                           -- e.g., "iOS 17.2"
    device_model VARCHAR(100),                        -- e.g., "iPhone 15 Pro"

    -- Stats (denormalized for performance)
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
```

**iOS Usage:**
- Device registers on first launch
- `device_id` generated once and stored in Keychain
- Stats cached locally, synced periodically

---

### 2. `poop_logs` - Bathroom Logs
Core data model for tracking bathroom visits.

```sql
CREATE TABLE poop_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,

    -- Core Data
    logged_at TIMESTAMP WITH TIME ZONE NOT NULL,      -- When the log was created
    duration_seconds INTEGER NOT NULL,                -- How long (in seconds)
    rating VARCHAR(20) NOT NULL,                      -- 'great', 'good', 'okay', 'bad', 'terrible'
    consistency INTEGER NOT NULL CHECK (consistency BETWEEN 1 AND 7),  -- Bristol Stool Scale
    notes TEXT,

    -- Gamification
    flush_funds_earned INTEGER DEFAULT 10 NOT NULL,   -- Rewards for logging
    is_streak_counted BOOLEAN DEFAULT true,           -- Does this count towards streak?

    -- Metadata
    local_id VARCHAR(100),                            -- iOS local identifier (for sync)
    is_deleted BOOLEAN DEFAULT false NOT NULL,        -- Soft delete
    synced_at TIMESTAMP WITH TIME ZONE,               -- Last sync time

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_poop_logs_device ON poop_logs(device_id) WHERE is_deleted = false;
CREATE INDEX idx_poop_logs_logged_at ON poop_logs(logged_at DESC);
CREATE INDEX idx_poop_logs_device_date ON poop_logs(device_id, logged_at DESC) WHERE is_deleted = false;
CREATE INDEX idx_poop_logs_sync ON poop_logs(device_id, synced_at) WHERE is_deleted = false;
```

**iOS Optimization:**
- Composite index on `device_id + logged_at` for efficient history queries
- `local_id` enables offline sync reconciliation
- Soft deletes preserve data for sync conflicts

---

### 3. `achievements` - Unlocked Achievements
Track user milestones and accomplishments.

```sql
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,

    -- Achievement Data
    achievement_key VARCHAR(100) NOT NULL,            -- e.g., 'first_log', 'streak_7', 'logs_50'
    achievement_type VARCHAR(50) NOT NULL,            -- 'milestone', 'streak', 'special'
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    icon_name VARCHAR(100),                           -- SF Symbol name

    -- Rewards
    flush_funds_reward INTEGER DEFAULT 0,
    avatar_component_unlock_id UUID,                  -- Optional component unlock

    -- Metadata
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    is_viewed BOOLEAN DEFAULT false,                  -- Has user seen the unlock?

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_achievements_device ON achievements(device_id);
CREATE INDEX idx_achievements_unlocked ON achievements(unlocked_at DESC);
CREATE UNIQUE INDEX idx_achievements_unique ON achievements(device_id, achievement_key);
```

**Achievement Keys (Examples):**
- `first_log` - "First Steps"
- `streak_7` - "Week Warrior"
- `streak_30` - "Monthly Master"
- `logs_100` - "Century Club"
- `morning_person` - "Early Bird" (5 logs before 9am)

---

### 4. `avatar_components` - Avatar Customization Parts
Store available avatar parts (heads, eyes, mouths, accessories).

```sql
CREATE TYPE component_type AS ENUM ('head', 'eyes', 'mouth', 'accessory');

CREATE TABLE avatar_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Component Data
    name VARCHAR(200) NOT NULL,
    type component_type NOT NULL,
    svg_data TEXT NOT NULL,                           -- SVG path/code for rendering
    rarity VARCHAR(50) DEFAULT 'common',              -- 'common', 'rare', 'epic', 'legendary'

    -- Unlock Conditions
    cost_flush_funds INTEGER DEFAULT 0,               -- Cost to purchase (0 = free/default)
    unlock_condition VARCHAR(200),                    -- e.g., 'streak_30', 'achievement_century'
    is_default BOOLEAN DEFAULT false,                 -- Pre-unlocked for new users

    -- Display
    preview_image_url TEXT,                           -- Optional preview image
    display_order INTEGER DEFAULT 0,                  -- Shop display order

    -- Status
    is_active BOOLEAN DEFAULT true,                   -- Available for unlock?

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_avatar_components_type ON avatar_components(type) WHERE is_active = true;
CREATE INDEX idx_avatar_components_cost ON avatar_components(cost_flush_funds);
CREATE INDEX idx_avatar_components_default ON avatar_components(is_default) WHERE is_default = true;
```

---

### 5. `device_avatar_inventory` - User's Unlocked Components
Junction table tracking which components each device has unlocked.

```sql
CREATE TABLE device_avatar_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    component_id UUID REFERENCES avatar_components(id) ON DELETE CASCADE,

    -- Unlock Method
    unlocked_via VARCHAR(50),                         -- 'purchase', 'achievement', 'default'
    unlock_cost INTEGER DEFAULT 0,                    -- How much was paid (if purchased)

    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    UNIQUE(device_id, component_id)
);

-- Indexes
CREATE INDEX idx_inventory_device ON device_avatar_inventory(device_id);
CREATE INDEX idx_inventory_component ON device_avatar_inventory(component_id);
```

---

### 6. `avatar_configs` - Current Avatar Setup
Stores the currently equipped avatar configuration for each device.

```sql
CREATE TABLE avatar_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE UNIQUE,

    -- Current Components (nullable for flexibility)
    head_component_id UUID REFERENCES avatar_components(id),
    eyes_component_id UUID REFERENCES avatar_components(id),
    mouth_component_id UUID REFERENCES avatar_components(id),
    accessory_component_id UUID REFERENCES avatar_components(id),

    -- Metadata
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_avatar_configs_device ON avatar_configs(device_id);
```

---

### 7. `challenges` - Global Challenge Definitions
Store available challenges (daily, streak, milestone).

```sql
CREATE TYPE challenge_type AS ENUM ('daily', 'streak', 'milestone');
CREATE TYPE condition_type AS ENUM ('log_count', 'consistent_time', 'rating_achieved', 'streak_reached');

CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Challenge Details
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    challenge_type challenge_type NOT NULL,

    -- Reward
    flush_funds_reward INTEGER DEFAULT 50 NOT NULL,
    bonus_multiplier DECIMAL(3,2) DEFAULT 1.0,        -- e.g., 1.5 for weekend bonus

    -- Conditions
    condition_type condition_type NOT NULL,
    condition_target INTEGER NOT NULL,                -- e.g., 3 logs for log_count
    timeframe_days INTEGER,                           -- e.g., 7 for weekly challenge

    -- Status
    is_active BOOLEAN DEFAULT true NOT NULL,
    start_date DATE,                                  -- Optional start date
    end_date DATE,                                    -- Optional end date

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_challenges_active ON challenges(is_active) WHERE is_active = true;
CREATE INDEX idx_challenges_type ON challenges(challenge_type);
CREATE INDEX idx_challenges_dates ON challenges(start_date, end_date);
```

**Challenge Examples:**
- **Daily:** "Log 3 times today" (log_count = 3, timeframe = 1)
- **Streak:** "Maintain 7-day streak" (streak_reached = 7)
- **Milestone:** "Achieve 100 total logs" (log_count = 100)

---

### 8. `device_challenge_progress` - User Challenge Tracking
Track progress on challenges per device.

```sql
CREATE TABLE device_challenge_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,

    -- Progress
    current_progress INTEGER DEFAULT 0 NOT NULL,
    is_completed BOOLEAN DEFAULT false NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_progress_at TIMESTAMP WITH TIME ZONE,

    UNIQUE(device_id, challenge_id)
);

-- Indexes
CREATE INDEX idx_challenge_progress_device ON device_challenge_progress(device_id);
CREATE INDEX idx_challenge_progress_active ON device_challenge_progress(device_id, is_completed) WHERE is_completed = false;
```

---

## 🔐 Row Level Security (RLS) Policies

Supabase RLS ensures devices can only access their own data.

```sql
-- Enable RLS on all tables
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE poop_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_avatar_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE avatar_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_challenge_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Devices can only access their own data
CREATE POLICY "Devices can read own data" ON devices
    FOR SELECT USING (device_id = current_setting('app.device_id'));

CREATE POLICY "Devices can update own data" ON devices
    FOR UPDATE USING (device_id = current_setting('app.device_id'));

-- Similar policies for other tables...
-- (Full RLS setup in migration files)
```

**iOS Implementation:**
```swift
// Set device_id context before queries
let deviceID = DeviceIDService.shared.getDeviceID()
supabase.rpc("set_device_context", params: ["device_id": deviceID])
```

---

## 📈 Database Functions (Stored Procedures)

### Update Device Stats
```sql
CREATE OR REPLACE FUNCTION update_device_stats(p_device_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE devices
    SET
        total_logs = (SELECT COUNT(*) FROM poop_logs WHERE device_id = p_device_id AND is_deleted = false),
        last_log_date = (SELECT MAX(logged_at::date) FROM poop_logs WHERE device_id = p_device_id AND is_deleted = false),
        updated_at = NOW()
    WHERE id = p_device_id;
END;
$$ LANGUAGE plpgsql;
```

### Calculate Streak
```sql
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
$$ LANGUAGE plpgsql;
```

---

## 🔄 Sync Strategy

### Conflict Resolution
- **Last Write Wins** based on `updated_at` timestamp
- **Soft Deletes** preserve data for conflict resolution
- **Local ID Mapping** tracks iOS local records

### Sync Flow
1. Device fetches latest `synced_at` timestamp
2. Query for records `updated_at > synced_at`
3. Download new/updated records
4. Upload local changes
5. Resolve conflicts (last write wins)
6. Update `synced_at` timestamp

---

## 📊 Common Queries (iOS Optimized)

### Fetch Today's Logs
```sql
SELECT * FROM poop_logs
WHERE device_id = :deviceID
AND logged_at::date = CURRENT_DATE
AND is_deleted = false
ORDER BY logged_at DESC;
```

### Fetch History (Paginated)
```sql
SELECT * FROM poop_logs
WHERE device_id = :deviceID
AND is_deleted = false
ORDER BY logged_at DESC
LIMIT 30 OFFSET :offset;
```

### Get Current Avatar
```sql
SELECT
    ac.*,
    h.svg_data as head_svg,
    e.svg_data as eyes_svg,
    m.svg_data as mouth_svg,
    a.svg_data as accessory_svg
FROM avatar_configs ac
LEFT JOIN avatar_components h ON ac.head_component_id = h.id
LEFT JOIN avatar_components e ON ac.eyes_component_id = e.id
LEFT JOIN avatar_components m ON ac.mouth_component_id = m.id
LEFT JOIN avatar_components a ON ac.accessory_component_id = a.id
WHERE ac.device_id = :deviceID;
```

---

## 🎯 Migration Strategy

### Initial Setup
1. Create tables in order (respecting foreign keys)
2. Seed default avatar components
3. Seed initial challenges
4. Set up RLS policies
5. Create indexes

### Version Management
- Use Supabase migrations
- Track schema version in iOS app
- Handle migration failures gracefully

---

## 📚 Related Documentation

- [Supabase Integration](./05-supabase-integration.md)
- [Device Identification](./06-device-identification.md)
- [Error Handling](./07-error-handling.md)

---

**Last Updated:** 2025-11-11
**Version:** 1.0.0
