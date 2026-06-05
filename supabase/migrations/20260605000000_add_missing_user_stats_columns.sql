-- Create activity_logs table
create table if not exists public.activity_logs (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users not null default auth.uid(),
  task_id text not null,
  task text not null,
  project text not null default 'General',
  points int not null default 0,
  time text not null default '',
  icon text not null default '📝',
  rating int not null default 0,
  notes text,
  image_url text,
  created_at timestamptz not null default now()
);

-- Ensure all columns exist (safe if table already existed without them)
alter table public.activity_logs
  add column if not exists task_id text,
  add column if not exists task text,
  add column if not exists project text not null default 'General',
  add column if not exists points int not null default 0,
  add column if not exists time text not null default '',
  add column if not exists icon text not null default '📝',
  add column if not exists rating int not null default 0,
  add column if not exists notes text,
  add column if not exists image_url text,
  add column if not exists created_at timestamptz not null default now();

-- Drop old camelCase columns if they exist (leftover from earlier schema attempts)
alter table public.activity_logs
  drop column if exists "taskId",
  drop column if exists "imageUrl",
  drop column if exists "createdAt";

-- Enable RLS
alter table public.activity_logs enable row level security;

-- Policies (safe re-run)
do $$ begin
  if not exists (select 1 from pg_policies where tablename = 'activity_logs' and policyname = 'Users can view their own activity logs') then
    create policy "Users can view their own activity logs"
      on public.activity_logs for select
      using (auth.uid() = user_id);
  end if;

  if not exists (select 1 from pg_policies where tablename = 'activity_logs' and policyname = 'Users can insert their own activity logs') then
    create policy "Users can insert their own activity logs"
      on public.activity_logs for insert
      with check (auth.uid() = user_id);
  end if;

  if not exists (select 1 from pg_policies where tablename = 'activity_logs' and policyname = 'Users can delete their own activity logs') then
    create policy "Users can delete their own activity logs"
      on public.activity_logs for delete
      using (auth.uid() = user_id);
  end if;
end $$;

-- Add all missing columns to user_stats used by the Flutter app
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
ADD COLUMN IF NOT EXISTS quests_last_reset_at timestamptz,
ADD COLUMN IF NOT EXISTS selected_badges text[] DEFAULT '{}'::text[],
ADD COLUMN IF NOT EXISTS last_active_at timestamptz,
ADD COLUMN IF NOT EXISTS unlocked_skills text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS skill_points int DEFAULT 0;

-- Refresh schema cache so PostgREST picks up the new columns
NOTIFY pgrst, 'reload schema';
