import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { google } from 'https://esm.sh/googleapis@134'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  const { userId, title, body, data }: {
    userId: string
    title: string
    body: string
    data?: Record<string, string>
  } = await req.json()

  const { data: tokens } = await supabase
    .from('device_tokens')
    .select('fcm_token')
    .eq('user_id', userId)

  if (!tokens?.length) {
    return new Response(JSON.stringify({ ok: true, sent: 0 }))
  }

  const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT')
  if (!serviceAccountJson) {
    return new Response(JSON.stringify({ error: 'FCM_SERVICE_ACCOUNT not set' }), { status: 500 })
  }

  const sa = JSON.parse(serviceAccountJson)

  const auth = new google.auth.GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  })

  const fcm = google.fcm('v1')
  const sent = 0

  for (const t of tokens) {
    try {
      const parent = `projects/${sa.project_id}`
      await fcm.projects.messages.send({
        auth,
        parent,
        requestBody: {
          message: {
            token: t.fcm_token,
            notification: { title, body },
            data: data ?? {},
          },
        },
      })
    } catch (_) {}
  }

  return new Response(JSON.stringify({ ok: true, sent: tokens.length }))
})
