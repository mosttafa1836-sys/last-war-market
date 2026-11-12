create or replace function public.get_public_listing_views(p_listing_ids uuid[])
returns table(listing_id uuid,view_count bigint)
language sql stable security invoker set search_path = ''
as $function$
  select p.id,count(e.id)::bigint from unnest(coalesce(p_listing_ids,array[]::uuid[])) requested(id)
  join public.player_profiles p on p.id=requested.id and p.is_published=true
  left join public.site_events e on e.listing_id=p.id and e.event_type='listing_view'
  group by p.id;
$function$;
revoke all on function public.get_public_listing_views(uuid[]) from public,anon,authenticated;