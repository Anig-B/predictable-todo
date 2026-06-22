import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { google } from 'https://esm.sh/googleapis@134'

import sa from './service_account.json' with { type: 'json' }

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )
  const auth = new google.auth.GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  })
  const fcm = google.fcm('v1')

  // Find all due notifications that haven't been pushed yet
  const { data: notifications, error } = await supabase
    .from('notifications')
    .select('id, user_id, title, message')
    .lte('created_at', new Date().toISOString())
    .eq('is_push_sent', false)

  if (error || !notifications || notifications.length === 0) {
    return new Response(JSON.stringify({ ok: true, sent: 0, msg: 'No pending notifications' }))
  }

  let totalSent = 0;
  const processedIds: string[] = [];

  for (const notif of notifications) {
    // Get device tokens for this user
    const { data: tokens } = await supabase
      .from('device_tokens')
      .select('fcm_token')
      .eq('user_id', notif.user_id)

    if (tokens && tokens.length > 0) {
      for (const t of tokens) {
        try {
          await fcm.projects.messages.send({
            auth,
            parent: `projects/${sa.project_id}`,
            requestBody: {
              message: {
                token: t.fcm_token,
                notification: { title: notif.title, body: notif.message || '' },
              },
            },
          })
          totalSent++;
        } catch (_) {}
      }
    }
    processedIds.push(notif.id);
  }

  // Mark all processed notifications as sent
  if (processedIds.length > 0) {
    await supabase
      .from('notifications')
      .update({ is_push_sent: true })
      .in('id', processedIds)
  }

  return new Response(JSON.stringify({ ok: true, sent: totalSent, processed: processedIds.length }))
})
