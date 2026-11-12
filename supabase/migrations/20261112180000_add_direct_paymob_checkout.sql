-- Direct checkout foundation (Paymob hosted checkout)
alter table public.market_orders drop constraint if exists market_orders_status_check;
alter table public.market_orders
  add constraint market_orders_status_check
  check (status = any (array[
    'new','reviewing','accepted','awaiting_payment','paid','fulfilling',
    'completed','cancelled','failed','refunded'
  ]::text[]));

create table if not exists public.market_payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.market_orders(id) on delete restrict,
  profile_id uuid not null references public.player_profiles(id) on delete restrict,
  provider text not null default 'paymob' check (provider = 'paymob'),
  provider_intention_id text,
  provider_order_id text unique,
  provider_transaction_id text unique,
  amount_minor bigint not null check (amount_minor > 0),
  currency text not null check (currency in ('EGP','USD')),
  status text not null default 'pending'
    check (status in ('pending','paid','failed','refunded')),
  payment_method text,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists market_payments_order_id_idx on public.market_payments(order_id);
create index if not exists market_payments_profile_status_idx on public.market_payments(profile_id,status);

alter table public.market_payments enable row level security;
revoke all on public.market_payments from anon, authenticated;
grant select on public.market_payments to authenticated;
drop policy if exists "Admins can view market payments" on public.market_payments;
create policy "Admins can view market payments"
on public.market_payments for select to authenticated
using (public.is_market_admin());

comment on table public.market_payments is
'Private payment ledger. Only admins may read it; writes are performed by trusted Edge Functions using the service role.';
