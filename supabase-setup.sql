-- Run once in the NEW Nkomazi Global FET College Supabase project.
create extension if not exists pgcrypto;
create table if not exists public.admin_users (user_id uuid primary key references auth.users(id) on delete cascade, created_at timestamptz not null default now());
create table if not exists public.applications (
 id uuid primary key default gen_random_uuid(), created_at timestamptz not null default now(),
 intake_year integer not null default 2027 check(intake_year between 2027 and 2100),
 first_name text not null check(length(first_name) between 1 and 100),
 last_name text not null check(length(last_name) between 1 and 100),
 email text not null check(length(email) between 3 and 255),
 phone text not null check(length(phone) between 5 and 25),
 current_grade text not null, package text not null, subjects text not null,
 message text, status text not null default 'pending' check(status in ('pending','reviewing','approved','rejected'))
);
create index if not exists applications_created_at_idx on public.applications(created_at desc);
create index if not exists applications_status_idx on public.applications(status);
alter table public.admin_users enable row level security;
alter table public.applications enable row level security;
revoke all on public.admin_users from anon, authenticated;
revoke all on public.applications from anon, authenticated;
grant select on public.admin_users to authenticated;
grant insert on public.applications to anon, authenticated;
grant select, update on public.applications to authenticated;
drop policy if exists "admins can see own role" on public.admin_users;
create policy "admins can see own role" on public.admin_users for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "public can submit applications" on public.applications;
create policy "public can submit applications" on public.applications for insert to anon,authenticated with check (status='pending' and intake_year=2027);
drop policy if exists "admins read applications" on public.applications;
create policy "admins read applications" on public.applications for select to authenticated using (exists(select 1 from public.admin_users a where a.user_id=(select auth.uid())));
drop policy if exists "admins update applications" on public.applications;
create policy "admins update applications" on public.applications for update to authenticated using (exists(select 1 from public.admin_users a where a.user_id=(select auth.uid()))) with check (exists(select 1 from public.admin_users a where a.user_id=(select auth.uid())));
-- After creating a staff user in Authentication > Users, grant access with:
-- insert into public.admin_users(user_id) values ('PASTE-AUTH-USER-UUID-HERE');
-- Never put service_role or secret keys into browser JavaScript.
