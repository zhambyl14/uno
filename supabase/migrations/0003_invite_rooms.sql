-- UNO FAMILY — invites now carry a room (0003).
--
-- Before this, a friend "invite" only inserted {from_id, to_id} and fired a
-- push — it never pointed at a room, so the friend had nowhere to land.
-- Now each invite references the waiting room it was sent from, the recipient
-- streams incoming invites over Realtime, and either side may delete a
-- handled invite.

alter table public.invites
  add column if not exists room_code text
    references public.rooms (code) on delete cascade;

-- Recipient (or sender) may clear a handled invite.
drop policy if exists "invites delete own" on public.invites;
create policy "invites delete own" on public.invites
  for delete using (auth.uid() = to_id or auth.uid() = from_id);

-- Stream incoming invites to the recipient in real time.
do $$
begin
  alter publication supabase_realtime add table public.invites;
exception
  when duplicate_object then null;
end $$;
