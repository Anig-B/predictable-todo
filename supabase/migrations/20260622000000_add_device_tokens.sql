CREATE TABLE IF NOT EXISTS public.device_tokens (
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token  TEXT NOT NULL,
  platform   TEXT NOT NULL DEFAULT 'unknown' CHECK (platform IN ('android', 'ios', 'unknown')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, fcm_token)
);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own device tokens"
  ON public.device_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS device_tokens_user_id_idx ON public.device_tokens (user_id);

CREATE OR REPLACE FUNCTION public.upsert_device_token(
  p_fcm_token TEXT,
  p_platform  TEXT
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.device_tokens (user_id, fcm_token, platform, updated_at)
  VALUES (auth.uid(), p_fcm_token, p_platform, now())
  ON CONFLICT (user_id, fcm_token)
  DO UPDATE SET platform = p_platform, updated_at = now();
END;
$$;
