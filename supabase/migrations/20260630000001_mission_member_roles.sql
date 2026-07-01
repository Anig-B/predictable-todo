-- ============================================================
-- Replace permission booleans with role-based system
-- Roles: member (default), manager
-- ============================================================

-- 1. Add role column
ALTER TABLE public.mission_members ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'member'
  CHECK (role IN ('member', 'manager'));

-- 2. Drop policies that depend on the boolean columns
DROP POLICY IF EXISTS "Users can insert their own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Users can delete their own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Users can update their own tasks" ON public.tasks;
DROP POLICY IF EXISTS "Admins and invite-permission users can insert mission_members" ON public.mission_members;
DROP POLICY IF EXISTS "Task owner, admins, and reviewers can view proof_reviews" ON public.proof_reviews;
DROP POLICY IF EXISTS "Admins and reviewers can insert proof_reviews" ON public.proof_reviews;
DROP POLICY IF EXISTS "Admins and reviewers can update proof_reviews" ON public.proof_reviews;

-- 3. Drop boolean permission columns
ALTER TABLE public.mission_members DROP COLUMN IF EXISTS can_add_quests;
ALTER TABLE public.mission_members DROP COLUMN IF EXISTS can_edit_quests;
ALTER TABLE public.mission_members DROP COLUMN IF EXISTS can_delete_quests;
ALTER TABLE public.mission_members DROP COLUMN IF EXISTS can_view_stats;
ALTER TABLE public.mission_members DROP COLUMN IF EXISTS can_review_proofs;

-- 3. Recreate mission_members policies (from 20260628000000)
DROP POLICY IF EXISTS "Members and admins can view mission_members" ON public.mission_members;
CREATE POLICY "Members and admins can view mission_members"
  ON public.mission_members FOR SELECT
  USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admins and invite-permission users can insert mission_members" ON public.mission_members;
CREATE POLICY "Admins and managers can insert mission_members"
  ON public.mission_members FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.mission_id = mission_id
        AND mm.user_id = auth.uid()
        AND mm.role = 'manager'
    )
  );

DROP POLICY IF EXISTS "Admins can update mission_members" ON public.mission_members;
CREATE POLICY "Admins and managers can update mission_members"
  ON public.mission_members FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR (
      EXISTS (
        SELECT 1 FROM public.mission_members mm
        WHERE mm.mission_id = mission_id
          AND mm.user_id = auth.uid()
          AND mm.role = 'manager'
      )
      -- Allow updating own record (e.g. leave mission)
      OR user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can delete mission_members" ON public.mission_members;
CREATE POLICY "Admins and managers can delete mission_members"
  ON public.mission_members FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR (
      EXISTS (
        SELECT 1 FROM public.mission_members mm
        WHERE mm.mission_id = mission_id
          AND mm.user_id = auth.uid()
          AND mm.role = 'manager'
      )
    )
  );

-- 4. Recreate proof_reviews policies (from 20260628000000)
DROP POLICY IF EXISTS "Task owner, admins, and reviewers can view proof_reviews" ON public.proof_reviews;
CREATE POLICY "Task owner, admins, and reviewers can view proof_reviews"
  ON public.proof_reviews FOR SELECT
  USING (
    auth.uid() IN (SELECT user_id FROM public.tasks WHERE id = task_id)
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.role = 'manager'
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );

DROP POLICY IF EXISTS "Admins and reviewers can insert proof_reviews" ON public.proof_reviews;
CREATE POLICY "Admins and managers can insert proof_reviews"
  ON public.proof_reviews FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.role = 'manager'
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );

DROP POLICY IF EXISTS "Admins and reviewers can update proof_reviews" ON public.proof_reviews;
CREATE POLICY "Admins and managers can update proof_reviews"
  ON public.proof_reviews FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR EXISTS (
      SELECT 1 FROM public.mission_members mm
      WHERE mm.user_id = auth.uid()
        AND mm.role = 'manager'
        AND mm.mission_id::text IN (
          SELECT t.mission_id FROM public.tasks t WHERE t.id = task_id
        )
    )
  );
