-- Add is_push_sent flag to notifications table
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS is_push_sent BOOLEAN DEFAULT false;

-- Create an index to make the cron job query faster
CREATE INDEX IF NOT EXISTS idx_notifications_pending_push ON public.notifications(created_at) WHERE is_push_sent = false;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create the cron job to run every minute
-- We must drop it first if it exists so we can safely re-run the migration
SELECT cron.unschedule('process-scheduled-notifications-job');

SELECT cron.schedule(
  'process-scheduled-notifications-job',
  '* * * * *',
  $$
    SELECT net.http_post(
      url := 'https://bgryhkvorqgjlvmtbcht.supabase.co/functions/v1/process-scheduled-notifications',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJncnloa3ZvcnFnamx2bXRiY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NjQ4MDQsImV4cCI6MjA5MDQ0MDgwNH0.vyWYG8EAIG72TYmfAE23hOyomv6PT52P9LgzKWS2hcQ"}'::jsonb,
      body := '{}'::jsonb
    );
  $$
);
