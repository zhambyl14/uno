// UNO FAMILY — send-push Edge Function.
//
// Called by a Supabase Database Webhook (Dashboard → Database → Webhooks)
// on INSERT into `public.invites`. Looks up the target player's device
// tokens and sends ONE fixed, child-safe notification via FCM HTTP v1.
// Firebase never stores app data — this function only uses it to deliver
// a push; all state lives in Postgres.
//
// Deploy:
//   supabase functions deploy send-push
//   supabase secrets set FCM_SERVICE_ACCOUNT='<Firebase service-account JSON>'
//
// Then in the Dashboard: Database → Webhooks → New webhook
//   table: invites · event: INSERT · type: HTTP request → this function URL.

import { createClient } from 'npm:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT')!;

const serviceAccount = JSON.parse(serviceAccountJson);
const projectId = serviceAccount.project_id as string;

async function fcmAccessToken(): Promise<string> {
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  return token.token ?? '';
}

// Only these two soft, pre-approved message shapes are ever sent — no
// free-form text ever reaches a push payload (child-safety invariant).
type PushKind = 'invite' | 'daily_gift' | 'season';

const TITLES: Record<PushKind, string> = {
  invite: 'UNO FAMILY',
  daily_gift: 'UNO FAMILY',
  season: 'UNO FAMILY',
};
const BODIES: Record<PushKind, string> = {
  invite: 'Досың сені ойынға шақырды 🎮',
  daily_gift: 'Күнделікті сыйлығың дайын! 🎁',
  season: 'Жаңа маусым басталды! 🏆',
};

Deno.serve(async (req) => {
  const payload = await req.json();
  const record = payload.record as { from_id: string; to_id: string };
  if (!record?.to_id) {
    return new Response('ignored', { status: 200 });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: tokens } = await admin
    .from('device_tokens')
    .select('token')
    .eq('user_id', record.to_id);

  if (!tokens || tokens.length === 0) {
    return new Response('no tokens', { status: 200 });
  }

  const accessToken = await fcmAccessToken();
  const kind: PushKind = 'invite';

  await Promise.all(
    tokens.map((row) =>
      fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token: row.token,
              notification: { title: TITLES[kind], body: BODIES[kind] },
            },
          }),
        },
      )
    ),
  );

  return new Response('sent', { status: 200 });
});
