-- Add selected_badges and last_active_at to user_stats
ALTER TABLE public.user_stats
ADD COLUMN IF NOT EXISTS selected_badges text[] DEFAULT '{}'::text[],
ADD COLUMN IF NOT EXISTS last_active_at timestamptz;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';
