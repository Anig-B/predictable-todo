-- Create notes table
create table if not exists public.notes (
  id text primary key,
  user_id uuid references auth.users not null default auth.uid(),
  content text not null,
  created_at timestamptz not null default now()
);

-- Enable RLS
alter table public.notes enable row level security;

-- Policies
create policy "Users can view their own notes"
  on public.notes for select
  using (auth.uid() = user_id);

create policy "Users can insert their own notes"
  on public.notes for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own notes"
  on public.notes for update
  using (auth.uid() = user_id);

create policy "Users can delete their own notes"
  on public.notes for delete
  using (auth.uid() = user_id);

-- Enable realtime (optional but recommended for syncing between devices)
begin;
  -- Remove existing publication if exists then recreate
  drop publication if exists supabase_realtime;
  create publication supabase_realtime for all tables;
commit;
