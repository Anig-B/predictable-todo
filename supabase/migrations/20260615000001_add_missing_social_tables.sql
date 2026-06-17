-- Create missing social tables and RPC functions with RLS policies

-- ── Notifications ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type text NOT NULL DEFAULT 'system',
  title text NOT NULL DEFAULT '',
  message text,
  is_read boolean NOT NULL DEFAULT false,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own notifications" ON public.notifications;
CREATE POLICY "Users can insert own notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own notifications" ON public.notifications;
CREATE POLICY "Users can delete own notifications"
  ON public.notifications FOR DELETE
  USING (auth.uid() = user_id);


-- ── Friends ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.friends (
  uid_1 uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  uid_2 uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (uid_1, uid_2)
);

ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own friendships" ON public.friends;
CREATE POLICY "Users can view own friendships"
  ON public.friends FOR SELECT
  USING (auth.uid() = uid_1 OR auth.uid() = uid_2);

DROP POLICY IF EXISTS "Users can insert own friendships" ON public.friends;
CREATE POLICY "Users can insert own friendships"
  ON public.friends FOR INSERT
  WITH CHECK (auth.uid() = uid_1);

DROP POLICY IF EXISTS "Users can delete own friendships" ON public.friends;
CREATE POLICY "Users can delete own friendships"
  ON public.friends FOR DELETE
  USING (auth.uid() = uid_1 OR auth.uid() = uid_2);


-- ── Social Challenges ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.social_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenger_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  challenged_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
  reward int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.social_challenges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view challenges they're involved in" ON public.social_challenges;
CREATE POLICY "Users can view challenges they're involved in"
  ON public.social_challenges FOR SELECT
  USING (auth.uid() = challenger_id OR auth.uid() = challenged_id);

DROP POLICY IF EXISTS "Users can send challenges" ON public.social_challenges;
CREATE POLICY "Users can send challenges"
  ON public.social_challenges FOR INSERT
  WITH CHECK (auth.uid() = challenger_id);

DROP POLICY IF EXISTS "Users can update challenges they're involved in" ON public.social_challenges;
CREATE POLICY "Users can update challenges they're involved in"
  ON public.social_challenges FOR UPDATE
  USING (auth.uid() = challenger_id OR auth.uid() = challenged_id);

-- Auto-create notification when a challenge is sent
CREATE OR REPLACE FUNCTION public.notify_challenge_sent()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, type, title, message, metadata)
  VALUES (
    NEW.challenged_id,
    'challenge_received',
    'New Challenge!',
    'Someone has challenged you to a duel.',
    jsonb_build_object('challenge_id', NEW.id, 'challenger_id', NEW.challenger_id)
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_challenge_created ON public.social_challenges;
CREATE TRIGGER on_challenge_created
  AFTER INSERT ON public.social_challenges
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_challenge_sent();


-- ── RPC: accept_challenge ─────────────────────────────────

DROP FUNCTION IF EXISTS public.accept_challenge(uuid);
CREATE FUNCTION public.accept_challenge(challenge_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_challenger_id uuid;
  v_challenged_id uuid;
BEGIN
  SELECT challenger_id, challenged_id INTO v_challenger_id, v_challenged_id
  FROM public.social_challenges
  WHERE id = challenge_id AND status = 'pending';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Challenge not found or already resolved');
  END IF;

  -- Update challenge status
  UPDATE public.social_challenges SET status = 'accepted' WHERE id = challenge_id;

  -- Create bidirectional friendship
  INSERT INTO public.friends (uid_1, uid_2) VALUES (v_challenger_id, v_challenged_id)
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object('success', true);
END;
$$;


-- ── RPC: claim_boss_reward ────────────────────────────────

DROP FUNCTION IF EXISTS public.claim_boss_reward();
CREATE FUNCTION public.claim_boss_reward()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_user_id uuid;
  v_reward int;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Read the boss reward from user_stats (handled client-side, mark claimed)
  UPDATE public.user_stats
  SET boss_reward_claimed = true
  WHERE user_id = v_user_id AND boss_reward_claimed = false;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Reward already claimed or no boss defeated');
  END IF;

  RETURN jsonb_build_object('success', true);
END;
$$;

NOTIFY pgrst, 'reload schema';
