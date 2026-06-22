const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const supabaseUrl = functions.config().supabase?.url;
const supabaseKey = functions.config().supabase?.service_key;

exports.sendPush = functions.https.onCall(async (data) => {
  const { userId, title, body, payload } = data;
  if (!userId) return { sent: 0 };

  const response = await fetch(`${supabaseUrl}/rest/v1/device_tokens?user_id=eq.${userId}&select=fcm_token`, {
    headers: { apikey: supabaseKey, Authorization: `Bearer ${supabaseKey}` },
  });

  const tokens = await response.json();
  if (!tokens?.length) return { sent: 0 };

  const messages = tokens.map(t => ({
    token: t.fcm_token,
    notification: { title, body },
    data: payload || {},
  }));

  const result = await admin.messaging().sendEach(messages);
  return { sent: result.successCount };
});
