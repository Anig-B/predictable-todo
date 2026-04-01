-- Add proof fields to activity_logs
alter table public.activity_logs 
add column if not exists "notes" text,
add column if not exists "imageUrl" text;

-- Add proof fields to tasks
alter table public.tasks 
add column if not exists "proof_notes" text,
add column if not exists "proof_image" text;

-- Create storage bucket for task proofs
insert into storage.buckets (id, name, public) 
values ('task-proofs', 'task-proofs', true)
on conflict (id) do nothing;

-- Storage policies
create policy "Users can upload their own proofs"
on storage.objects for insert
with check (bucket_id = 'task-proofs' and (auth.uid())::text = (storage.foldername(name))[1]);

create policy "Users can view all proofs"
on storage.objects for select
using (bucket_id = 'task-proofs');

-- Trigger update for rewards
create or replace function handle_task_completion()
returns trigger as $$
declare
  last_updated timestamptz;
  cur_xp integer;
  cur_combo_count integer;
  cur_combo_points integer;
  cur_combo_multi numeric;
  
  new_combo_count integer;
  new_combo_points integer;
  new_combo_multi numeric;
  xp_change integer;
  proof_bonus integer := 0;
begin
  -- Get current stats
  select xp, updated_at, combo_count, combo_points, combo_multi 
  into cur_xp, last_updated, cur_combo_count, cur_combo_points, cur_combo_multi
  from public.user_stats where user_id = new.user_id;

  -- Default to current values
  new_combo_count := coalesce(cur_combo_count, 0);
  new_combo_points := coalesce(cur_combo_points, 0);
  new_combo_multi := coalesce(cur_combo_multi, 1.0);

  -- Completion Logic: (false -> true)
  if (new.done = true and old.done = false) or (new.done = true and old.done is null) then
    -- Reset combo if window (24 hours) has passed
    if last_updated is not null and now() - last_updated > interval '24 hours' then
      new_combo_count := 0;
      new_combo_points := 0;
    end if;

    new_combo_count := new_combo_count + 1;
    new_combo_points := new_combo_points + new.points;
    
    -- Calculate New Multiplier
    if new_combo_points >= 500 then new_combo_multi := 4.0;
    elsif new_combo_points >= 250 then new_combo_multi := 3.0;
    elsif new_combo_points >= 100 then new_combo_multi := 2.0;
    else new_combo_multi := 1.0;
    end if;

    -- Calculate proof bonus
    if new.proof_notes is not null and new.proof_notes != '' then proof_bonus := proof_bonus + 10; end if;
    if new.proof_image is not null and new.proof_image != '' then proof_bonus := proof_bonus + 15; end if;

    xp_change := floor(new.points * new_combo_multi) + coalesce(new."bonusEarned", 0) + proof_bonus;

    update public.user_stats
    set 
      xp = xp + xp_change,
      combo_count = new_combo_count,
      combo_points = new_combo_points,
      combo_multi = new_combo_multi,
      current_streak = case when current_streak = 0 then 1 else current_streak end,
      updated_at = now()
    where user_id = new.user_id;
    
    -- Insert activity log with proof
    insert into public.activity_logs ("taskId", user_id, task, points, time, icon, rating, notes, "imageUrl")
    values (new.id, new.user_id, new.title, xp_change, now()::text, '✅', coalesce(new.priority + 1, 3), new.proof_notes, new.proof_image);
  end if;

  -- Uncompletion Logic: (true -> false)
  if new.done = false and old.done = true then
    select points into xp_change from public.activity_logs where "taskId" = old.id and user_id = old.user_id limit 1;
    
    new_combo_count := greatest(0, new_combo_count - 1);
    new_combo_points := greatest(0, new_combo_points - old.points);

    if new_combo_points >= 500 then new_combo_multi := 4.0;
    elsif new_combo_points >= 250 then new_combo_multi := 3.0;
    elsif new_combo_points >= 100 then new_combo_multi := 2.0;
    else new_combo_multi := 1.0;
    end if;

    update public.user_stats
    set 
      xp = greatest(0, xp - coalesce(xp_change, 0)),
      combo_count = new_combo_count,
      combo_points = new_combo_points,
      combo_multi = new_combo_multi
    where user_id = new.user_id;
    
    delete from public.activity_logs where "taskId" = old.id and user_id = old.user_id;
    new.proof_notes := null;
    new.proof_image := null;
  end if;

  return new;
end;
$$ language plpgsql security definer;
