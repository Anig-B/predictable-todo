-- Add skills and points to user_stats for full backend sync
ALTER TABLE public.user_stats
ADD COLUMN IF NOT EXISTS unlocked_skills text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS skill_points int DEFAULT 0;

-- Ensure RLS is active (it should be, but let's be safe)
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- If policies don't exist, this is a good place to ensure user isolation
-- (Assuming standard profile isolation based on user_id)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_stats' AND policyname = 'Users can update their own stats'
    ) THEN
        CREATE POLICY "Users can update their own stats"
        ON public.user_stats
        FOR UPDATE
        USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_stats' AND policyname = 'Users can view their own stats'
    ) THEN
        CREATE POLICY "Users can view their own stats"
        ON public.user_stats
        FOR SELECT
        USING (auth.uid() = user_id);
    END IF;
END $$;
