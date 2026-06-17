-- Create leaderboard view for real-time ranking queries

DROP VIEW IF EXISTS public.leaderboard_view CASCADE;
CREATE VIEW public.leaderboard_view AS
SELECT
  p.id AS user_id,
  p.username,
  p.short_id,
  p.avatar_url,
  p.project,
  COALESCE(us.xp, 0) AS xp,
  COALESCE(us.weekly_xp, 0) AS weekly_xp,
  COALESCE(us.xp / 200, 0) + 1 AS level,
  COALESCE(us.current_streak, 0) AS current_streak,
  COALESCE(us.selected_badges, '{}'::text[]) AS selected_badges,
  COALESCE(us.total_lifetime_tasks, 0) AS total_lifetime_tasks
FROM public.profiles p
INNER JOIN public.user_stats us ON p.id = us.user_id
WHERE p.username IS NOT NULL AND p.username != '';

-- Grant access
GRANT SELECT ON public.leaderboard_view TO authenticated, anon;
