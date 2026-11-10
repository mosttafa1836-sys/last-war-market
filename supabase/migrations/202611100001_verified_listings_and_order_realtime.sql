-- Last War Market: verified listing badge + real-time admin purchase alerts
alter table public.player_profiles
  add column if not exists is_verified boolean not null default false;

create or replace function public.guard_profile_verification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not coalesce(public.is_market_admin(), false) then
    if tg_op = 'INSERT' then
      new.is_verified := false;
    elsif new.is_verified is distinct from old.is_verified then
      raise exception 'Only marketplace admins can verify listings';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists guard_profile_verification_trigger on public.player_profiles;
create trigger guard_profile_verification_trigger
before insert or update of is_verified on public.player_profiles
for each row execute function public.guard_profile_verification();

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'market_orders'
  ) then
    alter publication supabase_realtime add table public.market_orders;
  end if;
end;
$$;
