-- Optimize RLS and add missing indices based on Supabase Best Practices

-- 1. Create indices on common filter columns (user_id) if they don't exist
CREATE INDEX IF NOT EXISTS user_stats_user_id_idx ON public.user_stats (user_id);
CREATE INDEX IF NOT EXISTS notes_user_id_idx ON public.notes (user_id);

-- 2. Optimize user_stats RLS policies
-- We drop and recreate or just replace. Since these are standard policies, we'll redefine them.
DO $$
BEGIN
    -- user_stats
    DROP POLICY IF EXISTS "Users can update their own stats" ON public.user_stats;
    CREATE POLICY "Users can update their own stats"
    ON public.user_stats FOR UPDATE
    USING ((SELECT auth.uid()) = user_id);

    DROP POLICY IF EXISTS "Users can view their own stats" ON public.user_stats;
    CREATE POLICY "Users can view their own stats"
    ON public.user_stats FOR SELECT
    USING ((SELECT auth.uid()) = user_id);

    -- notes
    DROP POLICY IF EXISTS "Users can view their own notes" ON public.notes;
    CREATE POLICY "Users can view their own notes"
    ON public.notes FOR SELECT
    USING ((SELECT auth.uid()) = user_id);

    DROP POLICY IF EXISTS "Users can insert their own notes" ON public.notes;
    CREATE POLICY "Users can insert their own notes"
    ON public.notes FOR INSERT
    WITH CHECK ((SELECT auth.uid()) = user_id);

    DROP POLICY IF EXISTS "Users can update their own notes" ON public.notes;
    CREATE POLICY "Users can update their own notes"
    ON public.notes FOR UPDATE
    USING ((SELECT auth.uid()) = user_id);

    DROP POLICY IF EXISTS "Users can delete their own notes" ON public.notes;
    CREATE POLICY "Users can delete their own notes"
    ON public.notes FOR DELETE
    USING ((SELECT auth.uid()) = user_id);
END $$;
