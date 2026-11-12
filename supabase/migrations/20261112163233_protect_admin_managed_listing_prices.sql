create or replace function public.guard_seller_profile_updates()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  if coalesce((select public.is_market_admin()),false) then return new; end if;
  if new.id is distinct from old.id or new.created_at is distinct from old.created_at then
    raise exception 'لا يمكن تعديل بيانات النظام.';
  end if;
  new.price := old.price;
  new.price_currency := old.price_currency;
  new.is_published := false;
  new.is_featured := old.is_featured;
  new.is_sold := old.is_sold;
  new.is_verified := old.is_verified;
  return new;
end;
$function$;
comment on function public.guard_seller_profile_updates() is
'Prevents sellers from changing final listing price, currency, publication, featured, sold, or verification status; admins retain full control.';
