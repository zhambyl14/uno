-- UNO FAMILY — push token storage (online mode).
-- Firebase never stores game data: Firebase only mints device push tokens,
-- which the client uploads here. All sending happens server-side from
-- Supabase (Edge Function `send-push`, service-role key, reads this table).

create table if not exists public.device_tokens (
  user_id     uuid not null references public.profiles (id) on delete cascade,
  token       text not null,
  platform    text not null default 'unknown', -- 'android' | 'ios' | 'web'
  updated_at  timestamptz not null default now(),
  primary key (user_id, token)
);

alter table public.device_tokens enable row level security;

-- A player may only register/remove their own device tokens. Reading all
-- tokens (to actually send a push) is done by the Edge Function using the
-- service-role key, which bypasses RLS — no policy needed for that.
create policy "device_tokens insert own" on public.device_tokens
  for insert with check (auth.uid() = user_id);
create policy "device_tokens update own" on public.device_tokens
  for update using (auth.uid() = user_id);
create policy "device_tokens delete own" on public.device_tokens
  for delete using (auth.uid() = user_id);

-- ── Sending pushes (documented, not executed here) ────────────────────────
-- 1. Deploy the Edge Function in supabase/functions/send-push/.
-- 2. Set its secret: `supabase secrets set FCM_SERVICE_ACCOUNT='<json>'`
--    (Firebase Console → Project settings → Service accounts → Generate key).
-- 3. In Supabase Dashboard → Database → Webhooks, add a webhook on
--    INSERT into `public.invites` that calls the deployed function URL.
--    This keeps the service-role key out of SQL entirely (the dashboard
--    webhook signs the request for you).
