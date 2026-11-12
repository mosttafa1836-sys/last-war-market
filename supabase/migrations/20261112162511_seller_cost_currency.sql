alter table public.seller_private_details
  add column if not exists seller_cost_currency text not null default 'USD';
alter table public.seller_private_details
  drop constraint if exists seller_private_details_cost_currency_check,
  add constraint seller_private_details_cost_currency_check
  check (seller_cost_currency in ('USD','EGP','EUR','TRY','SAR','AED'));
