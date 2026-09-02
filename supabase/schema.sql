-- Deen Supabase Schema - Family Circles & Profiles
-- Run in Supabase SQL Editor. Requires pgcrypto for gen_random_uuid.

create extension if not exists "pgcrypto";

-- Profiles: one row per auth user
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

drop policy if exists "Users can read own profile" on profiles;
create policy "Users can read own profile" on profiles
  for select using (auth.uid() = id);

drop policy if exists "Users can upsert own profile" on profiles;
create policy "Users can upsert own profile" on profiles
  for insert with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on profiles;
create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- Circles: private family circles with 6-char invite code
create table if not exists circles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code varchar(6) unique not null check (invite_code ~ '^[A-Za-z0-9]{6}$'),
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);

alter table circles enable row level security;

drop policy if exists "Members can read their circles" on circles;
create policy "Members can read their circles" on circles
  for select using (
    exists (
      select 1 from circle_members
      where circle_members.circle_id = circles.id
      and circle_members.user_id = auth.uid()
    )
  );

drop policy if exists "Authenticated can create circles" on circles;
create policy "Authenticated can create circles" on circles
  for insert with check (auth.uid() = created_by);

-- Circle members: many-to-many
create table if not exists circle_members (
  circle_id uuid references circles(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  joined_at timestamptz default now(),
  primary key (circle_id, user_id)
);

alter table circle_members enable row level security;

drop policy if exists "Members can read members of their circles" on circle_members;
create policy "Members can read members of their circles" on circle_members
  for select using (
    exists (
      select 1 from circle_members cm
      where cm.circle_id = circle_members.circle_id
      and cm.user_id = auth.uid()
    )
  );

drop policy if exists "Users can join via invite code" on circle_members;
create policy "Users can join via invite code" on circle_members
  for insert with check (auth.uid() = user_id);

-- Weekly stats: per user per week (Monday start)
create table if not exists weekly_stats (
  user_id uuid references auth.users(id) on delete cascade,
  week_start_date date not null,
  total_minutes int default 0,
  total_ayahs int default 0,
  primary key (user_id, week_start_date)
);

alter table weekly_stats enable row level security;

drop policy if exists "Users can read own weekly stats" on weekly_stats;
create policy "Users can read own weekly stats" on weekly_stats
  for select using (auth.uid() = user_id);

drop policy if exists "Users can upsert own weekly stats" on weekly_stats;
create policy "Users can upsert own weekly stats" on weekly_stats
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own weekly stats" on weekly_stats;
create policy "Users can update own weekly stats" on weekly_stats
  for update using (auth.uid() = user_id);

drop policy if exists "Circle members can read leaderboard" on weekly_stats;
create policy "Circle members can read leaderboard" on weekly_stats
  for select using (
    exists (
      select 1 from circle_members cm
      where cm.user_id = weekly_stats.user_id
      and exists (
        select 1 from circle_members my
        where my.user_id = auth.uid()
        and my.circle_id = cm.circle_id
      )
    )
  );
