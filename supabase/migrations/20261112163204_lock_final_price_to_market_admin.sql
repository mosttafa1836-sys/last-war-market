create or replace function public.guard_seller_profile_updates()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  if coalesce((select public.is_market_admin()),false) then return new; end if;
  new.price := old.price;
  new.price_currency := old.price_currency;
  new.is_published := false;
  return new;
end;
$function$;
