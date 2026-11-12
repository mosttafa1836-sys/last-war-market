drop policy if exists "Admins can delete price offers" on public.market_offers;
create policy "Admins can delete price offers"
on public.market_offers
for delete
to authenticated
using ((select public.is_market_admin()));

create or replace function public.admin_delete_market_offer(p_offer_id uuid)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $function$
begin
  if auth.uid() is null or not coalesce(public.is_market_admin(), false) then
    raise exception 'غير مصرح بحذف عرض السعر';
  end if;
  delete from public.market_offers where id = p_offer_id;
  if not found then
    raise exception 'العرض غير موجود أو تم حذفه بالفعل';
  end if;
  return true;
end;
$function$;
revoke all on function public.admin_delete_market_offer(uuid) from public, anon;
grant execute on function public.admin_delete_market_offer(uuid) to authenticated;

create or replace function public.admin_delete_market_order(p_order_id uuid)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $function$
begin
  if auth.uid() is null or not coalesce(public.is_market_admin(), false) then
    raise exception 'غير مصرح بحذف الطلب';
  end if;
  delete from public.market_orders where id = p_order_id;
  if not found then
    raise exception 'الطلب غير موجود أو تم حذفه بالفعل';
  end if;
  return true;
end;
$function$;
revoke all on function public.admin_delete_market_order(uuid) from public, anon;
grant execute on function public.admin_delete_market_order(uuid) to authenticated;
