create or replace function public.admin_set_listing_pricing(
  p_profile_id uuid,
  p_seller_cost numeric,
  p_admin_margin numeric,
  p_currency text
) returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_total numeric(14,2);
begin
  if auth.uid() is null or not coalesce(public.is_market_admin(),false) then
    raise exception 'غير مصرح بتعديل التسعير';
  end if;
  if p_seller_cost is null or p_admin_margin is null or p_seller_cost < 0 or p_admin_margin < 0 then
    raise exception 'التكلفة والهامش يجب أن يكونا صفرًا أو أكثر';
  end if;
  if p_currency not in ('USD','EGP','EUR','TRY','SAR','AED') then
    raise exception 'عملة غير مدعومة';
  end if;
  v_total := p_seller_cost + p_admin_margin;
  update public.seller_private_details
     set seller_cost=p_seller_cost,admin_margin=p_admin_margin,seller_cost_currency=p_currency
   where profile_id=p_profile_id;
  if not found then raise exception 'تفاصيل البائع غير موجودة لهذا الإعلان'; end if;
  update public.player_profiles set price=v_total::text,price_currency=p_currency where id=p_profile_id;
  if not found then raise exception 'الإعلان غير موجود'; end if;
  return true;
end;
$function$;
revoke all on function public.admin_set_listing_pricing(uuid,numeric,numeric,text) from public,anon;
grant execute on function public.admin_set_listing_pricing(uuid,numeric,numeric,text) to authenticated;
