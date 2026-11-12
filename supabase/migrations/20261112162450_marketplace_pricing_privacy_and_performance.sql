alter table public.seller_private_details
  add column if not exists seller_cost numeric(14,2),
  add column if not exists admin_margin numeric(14,2) not null default 0;

alter table public.seller_private_details
  drop constraint if exists seller_private_details_seller_cost_nonnegative,
  add constraint seller_private_details_seller_cost_nonnegative check (seller_cost is null or seller_cost >= 0),
  drop constraint if exists seller_private_details_admin_margin_nonnegative,
  add constraint seller_private_details_admin_margin_nonnegative check (admin_margin >= 0);

create index if not exists listing_reports_profile_id_idx on public.listing_reports(profile_id);
create index if not exists listing_reports_reporter_user_id_idx on public.listing_reports(reporter_user_id);
create index if not exists market_offers_profile_id_idx on public.market_offers(profile_id);
create index if not exists market_orders_buyer_user_id_idx on public.market_orders(buyer_user_id);
create index if not exists market_orders_profile_id_idx on public.market_orders(profile_id);
create index if not exists seller_private_details_user_id_idx on public.seller_private_details(user_id);
create index if not exists seller_reviews_profile_id_idx on public.seller_reviews(profile_id);
create index if not exists seller_reviews_reviewer_user_id_idx on public.seller_reviews(reviewer_user_id);
create index if not exists seller_reviews_seller_user_id_idx on public.seller_reviews(seller_user_id);

drop policy if exists "Public can view seller display names" on public.seller_public_profiles;
drop policy if exists "Admins can update seller pricing" on public.seller_private_details;
create policy "Admins can update seller pricing"
on public.seller_private_details for update to authenticated
using (coalesce(public.is_market_admin(),false))
with check (coalesce(public.is_market_admin(),false));

revoke all on function public.get_public_seller_profile(uuid) from public, anon, authenticated;
revoke all on function public.guard_profile_verification() from public, anon, authenticated;
