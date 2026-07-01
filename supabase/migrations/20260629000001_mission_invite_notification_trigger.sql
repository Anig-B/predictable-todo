-- Auto-create notification when a mission invite is sent
CREATE OR REPLACE FUNCTION public.notify_mission_invite()
RETURNS trigger AS $$
DECLARE
  mission_name TEXT;
BEGIN
  SELECT name INTO mission_name FROM public.missions WHERE id = NEW.mission_id;

  INSERT INTO public.notifications (user_id, type, title, message, metadata)
  VALUES (
    NEW.user_id,
    'mission_invite',
    'Mission Invite',
    COALESCE('You have been invited to join "' || mission_name || '"', 'You have been invited to join a mission'),
    jsonb_build_object('mission_id', NEW.mission_id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_mission_member_insert ON public.mission_members;
CREATE TRIGGER on_mission_member_insert
  AFTER INSERT ON public.mission_members
  FOR EACH ROW
  WHEN (NEW.joined_at IS NULL)
  EXECUTE FUNCTION public.notify_mission_invite();

-- RPC for accepting a mission invite
CREATE OR REPLACE FUNCTION public.accept_mission_invite(p_mission_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.mission_members
  SET joined_at = now()
  WHERE mission_id = p_mission_id AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC for declining a mission invite
CREATE OR REPLACE FUNCTION public.decline_mission_invite(p_mission_id UUID, p_user_id UUID)
RETURNS void AS $$
BEGIN
  DELETE FROM public.mission_members
  WHERE mission_id = p_mission_id AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
