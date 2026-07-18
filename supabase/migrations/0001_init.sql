-- UNO FAMILY — Supabase schema (online mode).
-- Run in the Supabase SQL editor, then enable Realtime for `rooms`
-- and `room_actions` (Database → Replication).

-- ── profiles ────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  nickname     text not null,
  avatar_id    text not null default 'cat',
  friend_code  text not null unique,
  xp           int  not null default 0,
  coins        int  not null default 100,
  rank_points  int  not null default 0,
  is_child     boolean not null default false,
  is_guest     boolean not null default false,
  games        int  not null default 0,
  wins         int  not null default 0,
  owned_items  jsonb not null default '[]'::jsonb,
  card_skin    text not null default 'skin_classic',
  table_theme  text not null default 'theme_green',
  created_at   timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Anyone signed in may look up a profile by friend code (to add friends),
-- but may only modify their own row.
create policy "profiles readable" on public.profiles
  for select using (auth.role() = 'authenticated');
create policy "profiles insert own" on public.profiles
  for insert with check (auth.uid() = id);
create policy "profiles update own" on public.profiles
  for update using (auth.uid() = id);

-- ── friendships (symmetric: two rows per friendship) ─────────────────────────
create table if not exists public.friendships (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  friend_id  uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, friend_id)
);

alter table public.friendships enable row level security;

create policy "friendships own" on public.friendships
  for select using (auth.uid() = user_id);
create policy "friendships insert own" on public.friendships
  for insert with check (auth.uid() = user_id or auth.uid() = friend_id);
create policy "friendships delete own" on public.friendships
  for delete using (auth.uid() = user_id or auth.uid() = friend_id);

-- ── rooms ────────────────────────────────────────────────────────────────────
create table if not exists public.rooms (
  code        text primary key,
  host_id     uuid not null references public.profiles (id) on delete cascade,
  is_public   boolean not null default false,
  mode        int not null default 0,
  status      int not null default 0,        -- 0 waiting, 1 playing, 2 closed
  players     jsonb not null default '[]'::jsonb,
  game_state  jsonb,                          -- host-authoritative snapshot
  created_at  timestamptz not null default now()
);

alter table public.rooms enable row level security;

-- Rooms are shared game surfaces: any authenticated player may read/join.
create policy "rooms readable" on public.rooms
  for select using (auth.role() = 'authenticated');
create policy "rooms insert" on public.rooms
  for insert with check (auth.uid() = host_id);
create policy "rooms update" on public.rooms
  for update using (auth.role() = 'authenticated');
create policy "rooms delete host" on public.rooms
  for delete using (auth.uid() = host_id);

-- ── room_actions (client → host action queue) ────────────────────────────────
create table if not exists public.room_actions (
  id         bigint generated always as identity primary key,
  room_code  text not null references public.rooms (code) on delete cascade,
  action     jsonb not null,
  created_at timestamptz not null default now()
);

alter table public.room_actions enable row level security;

create policy "room_actions readable" on public.room_actions
  for select using (auth.role() = 'authenticated');
create policy "room_actions insert" on public.room_actions
  for insert with check (auth.role() = 'authenticated');

-- ── invites (drives friend "invite" push via an Edge Function) ───────────────
create table if not exists public.invites (
  id         bigint generated always as identity primary key,
  from_id    uuid not null references public.profiles (id) on delete cascade,
  to_id      uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.invites enable row level security;

create policy "invites readable" on public.invites
  for select using (auth.uid() = to_id or auth.uid() = from_id);
create policy "invites insert" on public.invites
  for insert with check (auth.uid() = from_id);

-- Realtime: add rooms + room_actions to the supabase_realtime publication.
alter publication supabase_realtime add table public.rooms;
alter publication supabase_realtime add table public.room_actions;
