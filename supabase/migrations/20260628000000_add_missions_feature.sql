-- ============================================================
-- Missions Feature – DB Schema
-- Order: 3 ALTERs → 3 CREATEs → RLS policies → trigger update
-- ============================================================

-- 1. Add role to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user'
  CHECK (role IN ('user', 'admin'));

-- 2. Add mission_id to tasks
ALTER TABLE public.tasks ADD COLUMN IF NOT EXISTS mission_id TEXT;

-- 3. Add quest_id to activity_logs
ALTER TABLE public.activity_logs ADD COLUMN IF NOT EXISTS quest_id TEXT;

-- ============================================================
-- Create all new tables first (no RLS yet)
-- ============================================================

-- 4. Create missions table
CREATE TABLE IF NOT EXISTS public.missions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  icon        TEXT,
  color       TEXT,
  created_by  UUID REFERENCES public.profiles(id),
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- 5. Create mission_members table
CREATE TABLE IF NOT EXISTS public.mission_members (
  mission_id        UUID REFERENCES public.missions(id) ON DELETE CASCADE,
  user_id           UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  can_add_quests    BOOLEAN DEFAULT false,
  can_edit_quests   BOOLEAN DEFAULT false,
  can_delete_quests BOOLEAN DEFAULT false,
  can_view_stats    BOOLEAN DEFAULT false,
  can_review_proofs BOOLEAN DEFAULT false,
  invited_by        UUID REFERENCES public.profiles(id),
  joined_at         TIMESTAMPTZ,
  PRIMARY KEY (mission_id, user_id)
);

-- 6. Create proof_reviews table
CREATE TABLE IF NOT EXISTS public.proof_reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id     TEXT REFERENCES public.tasks(id),
  reviewed_by UUID REFERENCES public.profiles(id),
  approved    BOOLEAN,
  feedback    TEXT,
  reviewed_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- Enable RLS + add policies for all 3 tables
-- ============================================================

-- missions
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members and admins can view missions"
  ON public.missions FOR SELECT
  USING (
    auth.uid() IN (SELECT user_id FROM public.mission_members WHERE mission_id = id)
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can insert missions"
  ON public.missions FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update missions"
  ON public.missions FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete missions"
  ON public.missions FOR DELETE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- mission_members
ALTER TABLE public.mission_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members and admins can view mission_members"
  ON public.mission_members FOR SELECT
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins and invite-permission users can insert mission_members"
  ON public.mission_members FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.mission_id = mission_id
        AND mm.user_id = auth.uid()
        AND mm.can_add_quests = true
    )
  );

CREATE POLICY "Admins can update mission_members"
  ON public.mission_members FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete mission_members"
  ON public.mission_members FOR DELETE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- proof_reviews
ALTER TABLE public.proof_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Task owner, admins, and reviewers can view proof_reviews"
  ON public.proof_reviews FOR SELECT
  USING (
    auth.uid() IN (SELECT user_id FROM public.tasks WHERE id = task_id)
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.can_review_proofs = true
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );

CREATE POLICY "Admins and reviewers can insert proof_reviews"
  ON public.proof_reviews FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.can_review_proofs = true
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );

CREATE POLICY "Admins and reviewers can update proof_reviews"
  ON public.proof_reviews FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.can_review_proofs = true
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );

-- ============================================================
-- 7. (Manual step – run separately after migration)
--    UPDATE profiles SET role = 'admin' WHERE id = '<admin-uuid>';
-- ============================================================

-- ============================================================
-- 8. Update task completion trigger for quest-aware logging
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_task_completion()
RETURNS trigger AS $$
DECLARE
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
  quest_id_val text;
BEGIN
  -- Get current stats
  SELECT xp, updated_at, combo_count, combo_points, combo_multi
  INTO cur_xp, last_updated, cur_combo_count, cur_combo_points, cur_combo_multi
  FROM public.user_stats WHERE user_id = new.user_id;

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

    -- Set quest_id if this task belongs to a mission
    quest_id_val := case when new.mission_id is not null then new.id else null end;

    -- Insert activity log with proof and quest_id
    insert into public.activity_logs (task_id, user_id, task, points, time, icon, rating, notes, image_url, quest_id)
    values (new.id, new.user_id, new.title, xp_change, now()::text, '✅', coalesce(new.priority + 1, 3), new.proof_notes, new.proof_image, quest_id_val);
  end if;

  -- Uncompletion Logic: (true -> false)
  if new.done = false and old.done = true then
    select points into xp_change from public.activity_logs where task_id = old.id and user_id = old.user_id limit 1;

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

    delete from public.activity_logs where task_id = old.id and user_id = old.user_id;
    new.proof_notes := null;
    new.proof_image := null;
  end if;

  return new;
end;
$$ LANGUAGE plpgsql SECURITY DEFINER;
