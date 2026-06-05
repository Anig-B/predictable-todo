-- Add missing columns to user_stats used by the Flutter app
ALTER TABLE public.user_stats
ADD COLUMN IF NOT EXISTS weekly_xp int DEFAULT 0,
ADD COLUMN IF NOT EXISTS level int DEFAULT 1,
ADD COLUMN IF NOT EXISTS total_lifetime_tasks int DEFAULT 0,
ADD COLUMN IF NOT EXISTS boss_id text,
ADD COLUMN IF NOT EXISTS boss_hp int DEFAULT 0,
ADD COLUMN IF NOT EXISTS boss_tasks_done int DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_boss_reset_at timestamptz,
ADD COLUMN IF NOT EXISTS last_boss_id text,
ADD COLUMN IF NOT EXISTS unlocked_badges text[] DEFAULT '{}'::text[],
ADD COLUMN IF NOT EXISTS boss_reward_claimed boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS daily_quest_reward_claimed boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS daily_quests jsonb DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS quests_last_reset_at timestamptz;
