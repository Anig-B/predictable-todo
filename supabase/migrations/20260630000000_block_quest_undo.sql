-- ============================================================
-- DB-level enforcement for mission quest rules
-- ============================================================

-- ============================================================
-- 1. BLOCK UNCOMPLETE
-- Cannot set done = false on a mission quest
-- ============================================================
CREATE OR REPLACE FUNCTION public.prevent_quest_uncomplete()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.mission_id IS NOT NULL AND OLD.done = true AND NEW.done = false THEN
    RAISE EXCEPTION 'Cannot uncomplete a mission quest';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_quest_uncomplete ON public.tasks;
CREATE TRIGGER trg_prevent_quest_uncomplete
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_quest_uncomplete();

-- ============================================================
-- 2. BLOCK CONTENT EDITS ON MISSION QUESTS
-- A regular user cannot change title, description, points, etc.
-- on a quest. They ARE allowed to change completion fields
-- (done, proof_notes, proof_image, proof_rating, lastCompletedAt,
--  bonusEarned) and the mission_id itself.
-- Exceptions: admins and managers.
-- ============================================================
CREATE OR REPLACE FUNCTION public.prevent_quest_edit()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.mission_id IS NOT NULL THEN
    -- Allow if admin or manager
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
       OR EXISTS (SELECT 1 FROM public.mission_members
                   WHERE user_id = auth.uid()
                     AND mission_id::text = OLD.mission_id
                     AND role = 'manager') THEN
      RETURN NEW;
    END IF;

    -- Block changes to content fields (anything not completion-related)
    IF NEW.title IS DISTINCT FROM OLD.title
       OR NEW.description IS DISTINCT FROM OLD.description
       OR NEW.points IS DISTINCT FROM OLD.points
       OR NEW.priority IS DISTINCT FROM OLD.priority
       OR NEW.recurring IS DISTINCT FROM OLD.recurring
       OR NEW.scheduled_date_time IS DISTINCT FROM OLD.scheduled_date_time
       OR NEW.completed_at IS DISTINCT FROM OLD.completed_at
       OR NEW.proof_time IS DISTINCT FROM OLD.proof_time
       OR NEW.category IS DISTINCT FROM OLD.category
    THEN
      RAISE EXCEPTION 'Cannot edit mission quest content';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_quest_edit ON public.tasks;
CREATE TRIGGER trg_prevent_quest_edit
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_quest_edit();

-- ============================================================
-- 3. BLOCK DELETE OF MISSION QUESTS
-- Only admins or managers can delete
-- ============================================================
DROP POLICY IF EXISTS "Users can delete their own tasks" ON public.tasks;

CREATE POLICY "Users can delete their own tasks"
  ON public.tasks FOR DELETE
  USING (
    auth.uid() = user_id
    AND (
      mission_id IS NULL
      OR
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
      OR
      EXISTS (
        SELECT 1 FROM public.mission_members
        WHERE user_id = auth.uid()
          AND mission_id::text = tasks.mission_id
          AND role = 'manager'
      )
    )
  );

-- Re-create the update policy without the broken mission check
-- (edits are now enforced by trg_prevent_quest_edit instead)
DROP POLICY IF EXISTS "Users can update their own tasks" ON public.tasks;

CREATE POLICY "Users can update their own tasks"
  ON public.tasks FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 4. REQUIRE PROOF FOR QUEST COMPLETION
-- Cannot set done = true on a mission quest without proof
-- ============================================================

-- ============================================================
-- 5. BLOCK INSERT OF QUESTS BY REGULAR USERS
-- Only admins or managers can create tasks
-- with mission_id set
-- ============================================================
DROP POLICY IF EXISTS "Users can insert their own tasks" ON public.tasks;

CREATE POLICY "Users can insert their own tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND (
      mission_id IS NULL
      OR
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
      OR
      EXISTS (
        SELECT 1 FROM public.mission_members
        WHERE user_id = auth.uid()
          AND mission_id::text = tasks.mission_id
          AND role = 'manager'
      )
    )
  );

-- ============================================================
-- 6. VALIDATE MISSION_ID REFERENCES A REAL MISSION
-- Trigger on INSERT and UPDATE to ensure mission_id exists
-- ============================================================
CREATE OR REPLACE FUNCTION public.validate_quest_mission()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.mission_id IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM public.missions WHERE id::text = NEW.mission_id) THEN
      RAISE EXCEPTION 'mission_id references a non-existent mission';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_validate_quest_mission ON public.tasks;
CREATE TRIGGER trg_validate_quest_mission
  BEFORE INSERT OR UPDATE OF mission_id ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_quest_mission();

-- ============================================================
-- 7. REQUIRE PROOF FOR QUEST COMPLETION
-- ============================================================
CREATE OR REPLACE FUNCTION public.require_quest_proof()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.mission_id IS NOT NULL AND NEW.done = true AND (OLD.done = false OR OLD.done IS NULL) THEN
    IF (NEW.proof_notes IS NULL OR NEW.proof_notes = '') AND (NEW.proof_image IS NULL OR NEW.proof_image = '') THEN
      RAISE EXCEPTION 'Mission quest requires proof (notes or image) to complete';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_require_quest_proof ON public.tasks;
CREATE TRIGGER trg_require_quest_proof
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.require_quest_proof();
