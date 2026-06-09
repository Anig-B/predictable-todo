-- Add missing gamification columns to user_stats for full state sync

ALTER TABLE public.user_stats
ADD COLUMN IF NOT EXISTS bonus_xp int DEFAULT 0,
ADD COLUMN IF NOT EXISTS combo_points int DEFAULT 0,
ADD COLUMN IF NOT EXISTS combo_count int DEFAULT 0,
ADD COLUMN IF NOT EXISTS shields int DEFAULT 1,
ADD COLUMN IF NOT EXISTS loot_count int DEFAULT 0,
ADD COLUMN IF NOT EXISTS spin_used boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS last_spun_date timestamptz;

-- Add INSERT policy so upsert works for new rows
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_stats' AND policyname = 'Users can insert their own stats') THEN
    CREATE POLICY "Users can insert their own stats"
      ON public.user_stats FOR INSERT
      WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

-- Refresh schema cache so PostgREST picks up the new columns
NOTIFY pgrst, 'reload schema';
