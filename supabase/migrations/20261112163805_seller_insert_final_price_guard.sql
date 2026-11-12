create or replace function public.guard_seller_profile_inserts()
returns trigger language plpgsql set search_path = ''
as $function$
begin
  if coalesce((select public.is_market_admin()), false) then return new; end if;
  new.price := '';
  new.price_currency := 'USD';
  new.is_published := false;
  new.is_featured := false;
  new.is_sold := false;
  new.is_verified := false;
  return new;
end;
$function$;
drop trigger if exists guard_seller_profile_inserts_trigger on public.player_profiles;
create trigger guard_seller_profile_inserts_trigger before insert on public.player_profiles
for each row execute function public.guard_seller_profile_inserts();