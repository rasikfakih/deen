-- Migration: leaderboard scope (Today/Week/All + streak/hasanat rows).
-- Run `supabase db push` before RELEASE, not before merge. Providers
-- degrade gracefully when these objects are missing (empty state + Sync
-- CTA), so the app never crashes on a pre-push backend.

-- Per-day aggregates for the Today tab.
create table if not exists daily_stats (
  user_id uuid references auth.users(id) on delete cascade,
  date date not null,
  total_minutes int default 0,
  total_ayahs int default 0,
  total_hasanat int default 0,
  primary key (user_id, date)
);

alter table daily_stats enable row level security;

drop policy if exists "Users can read own daily stats" on daily_stats;
create policy "Users can read own daily stats" on daily_stats
  for select using (auth.uid() = user_id);

drop policy if exists "Users can upsert own daily stats" on daily_stats;
create policy "Users can upsert own daily stats" on daily_stats
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own daily stats" on daily_stats;
create policy "Users can update own daily stats" on daily_stats
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete own daily stats" on daily_stats;
create policy "Users can delete own daily stats" on daily_stats
  for delete using (auth.uid() = user_id);

drop policy if exists "Circle members can read daily leaderboard" on daily_stats;
create policy "Circle members can read daily leaderboard" on daily_stats
  for select using (
    exists (
      select 1 from circle_members cm
      where cm.user_id = daily_stats.user_id
      and exists (
        select 1 from circle_members my
        where my.user_id = auth.uid()
        and my.circle_id = cm.circle_id
      )
    )
  );

-- Weekly rows gain hasanat + streak for rich rows and the All tab.
alter table weekly_stats
  add column if not exists total_hasanat int default 0;
alter table weekly_stats
  add column if not exists current_streak int default 0;

create index if not exists daily_stats_date_idx on daily_stats (date);
create index if not exists daily_stats_user_idx on daily_stats (user_id);
