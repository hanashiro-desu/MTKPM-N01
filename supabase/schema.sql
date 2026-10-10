-- MOVIEGO · Lược đồ Supabase. Chạy toàn bộ file này trong Supabase > SQL Editor (chạy lại được nhiều lần).
-- Khóa publishable/anon dùng trong app KHÔNG tạo được bảng, nên bước này phải làm ở dashboard.

create extension if not exists pgcrypto;

-- ───────────── Bảng ─────────────
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text not null default '',
  role text not null default 'customer' check (role in ('customer', 'staff', 'manager')),
  member_tier text not null default 'standard' check (member_tier in ('standard', 'vip')),
  points int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.movies (
  id bigint primary key,
  title text not null,
  original_title text not null default '',
  overview text not null default '',
  poster_path text not null default '',
  backdrop_path text not null default '',
  release_date date,
  vote_average numeric(3,1) not null default 0,
  vote_count int not null default 0,
  runtime int not null default 120,
  genres text[] not null default '{}',
  languages text[] not null default '{}',
  cast_names text[] not null default '{}',
  directors text[] not null default '{}',
  trailer_url text not null default '',
  status text not null default 'now_playing' check (status in ('now_playing', 'upcoming')),
  is_popular boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.cinemas (
  id text primary key,
  name text not null,
  address text not null default '',
  phone text not null default '',
  image_url text not null default ''
);

create table if not exists public.rooms (
  id text primary key,
  cinema_id text not null references public.cinemas(id) on delete cascade,
  name text not null,
  type text not null default '2D',
  seat_count int not null default 48
);

create table if not exists public.showtimes (
  id uuid primary key default gen_random_uuid(),
  movie_id bigint not null references public.movies(id) on delete cascade,
  room_id text not null references public.rooms(id) on delete cascade,
  starts_at timestamptz not null,
  base_price numeric(10,0) not null default 90000,
  unique (movie_id, room_id, starts_at)
);

create table if not exists public.combos (
  id text primary key,
  name text not null,
  price numeric(10,0) not null
);

create table if not exists public.promotions (
  code text primary key,
  min_subtotal numeric(10,0) not null default 0,
  discount_rate numeric(4,3) not null check (discount_rate between 0 and 1),
  active boolean not null default true
);

create table if not exists public.bookings (
  id text primary key default ('BK' || upper(substr(md5(gen_random_uuid()::text), 1, 8))),
  user_id uuid not null references auth.users(id) on delete cascade,
  showtime_id uuid not null references public.showtimes(id),
  total numeric(10,0) not null check (total >= 0),
  status text not null default 'upcoming' check (status in ('upcoming', 'used', 'cancelled')),
  payment_method text not null default 'cod',
  transaction_id text,
  created_at timestamptz not null default now()
);

-- Mỗi ghế của một suất chiếu chỉ có tối đa 1 dòng (unique) -> không thể đặt trùng ghế.
create table if not exists public.booking_seats (
  id uuid primary key default gen_random_uuid(),
  showtime_id uuid not null references public.showtimes(id) on delete cascade,
  seat_code text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  booking_id text references public.bookings(id) on delete cascade,
  state text not null check (state in ('held', 'booked')),
  held_until timestamptz,
  created_at timestamptz not null default now(),
  unique (showtime_id, seat_code)
);

create table if not exists public.booking_combos (
  booking_id text not null references public.bookings(id) on delete cascade,
  combo_id text not null references public.combos(id),
  quantity int not null default 1 check (quantity > 0),
  primary key (booking_id, combo_id)
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  movie_id bigint not null references public.movies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text not null default '',
  created_at timestamptz not null default now(),
  unique (movie_id, user_id)
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_id bigint not null references public.movies(id) on delete cascade,
  primary key (user_id, movie_id)
);

-- ───────────── Tự tạo hồ sơ khi đăng ký ─────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.raw_user_meta_data ->> 'phone', '')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ───────────── Hàm phân quyền ─────────────
create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from profiles where id = auth.uid() and role in ('staff', 'manager'));
$$;

create or replace function public.is_manager()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'manager');
$$;

-- ───────────── Hàm nghiệp vụ (RPC) ─────────────
-- Tìm hoặc tạo suất chiếu (app gọi khi khách chọn rạp/giờ).
create or replace function public.ensure_showtime(p_movie bigint, p_room text, p_starts timestamptz)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  select id into v_id from showtimes
   where movie_id = p_movie and room_id = p_room and starts_at = p_starts;
  if v_id is null then
    insert into showtimes (movie_id, room_id, starts_at) values (p_movie, p_room, p_starts)
    on conflict (movie_id, room_id, starts_at) do nothing;
    select id into v_id from showtimes
     where movie_id = p_movie and room_id = p_room and starts_at = p_starts;
  end if;
  return v_id;
end $$;

-- Giữ ghế tạm thời. Hoặc giữ được tất cả (true), hoặc không giữ ghế nào (false).
create or replace function public.hold_seats(p_showtime uuid, p_seats text[], p_minutes int default 10)
returns boolean language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  v_until timestamptz := now() + make_interval(mins => greatest(p_minutes, 1));
  v_count int;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  delete from booking_seats
   where showtime_id = p_showtime and state = 'held' and held_until < now();

  update booking_seats set held_until = v_until
   where showtime_id = p_showtime and user_id = v_uid and state = 'held'
     and seat_code = any (p_seats);

  insert into booking_seats (showtime_id, seat_code, user_id, state, held_until)
  select p_showtime, s, v_uid, 'held', v_until from unnest(p_seats) as s
  on conflict (showtime_id, seat_code) do nothing;

  select count(*) into v_count from booking_seats
   where showtime_id = p_showtime and user_id = v_uid and state = 'held'
     and seat_code = any (p_seats);

  if v_count <> coalesce(array_length(p_seats, 1), 0) then
    delete from booking_seats
     where showtime_id = p_showtime and user_id = v_uid and state = 'held'
       and seat_code = any (p_seats);
    return false;
  end if;
  return true;
end $$;

create or replace function public.release_seats(p_showtime uuid, p_seats text[])
returns void language plpgsql security definer set search_path = public as $$
begin
  delete from booking_seats
   where showtime_id = p_showtime and user_id = auth.uid() and state = 'held'
     and seat_code = any (p_seats);
end $$;

-- Xác nhận vé: yêu cầu ghế đang được chính người này giữ và chưa hết hạn.
create or replace function public.confirm_booking(
  p_showtime uuid, p_seats text[], p_combos jsonb, p_total numeric, p_method text, p_txn text
) returns text language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_id text; v_held int;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  select count(*) into v_held from booking_seats
   where showtime_id = p_showtime and user_id = v_uid and state = 'held'
     and held_until >= now() and seat_code = any (p_seats);
  if v_held <> coalesce(array_length(p_seats, 1), 0) then
    raise exception 'seats not held or hold expired';
  end if;

  insert into bookings (user_id, showtime_id, total, status, payment_method, transaction_id)
  values (v_uid, p_showtime, p_total, 'upcoming', coalesce(p_method, 'cod'), p_txn)
  returning id into v_id;

  update booking_seats set state = 'booked', booking_id = v_id, held_until = null
   where showtime_id = p_showtime and user_id = v_uid and state = 'held'
     and seat_code = any (p_seats);

  insert into booking_combos (booking_id, combo_id, quantity)
  select v_id, c.key, greatest(c.value::int, 1)
  from jsonb_each_text(coalesce(p_combos, '{}'::jsonb)) as c;

  return v_id;
end $$;

-- Khách chỉ được hủy vé của mình; chỉ nhân viên/quản lý được đánh dấu "đã sử dụng".
create or replace function public.set_booking_status(p_id text, p_status text)
returns void language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not authenticated'; end if;
  if p_status not in ('used', 'cancelled') then raise exception 'permission denied'; end if;

  if p_status = 'cancelled' then
    update bookings set status = 'cancelled'
     where id = p_id and (user_id = v_uid or is_staff()) and status = 'upcoming';
    delete from booking_seats where booking_id = p_id;
  else
    if not is_staff() then raise exception 'permission denied'; end if;
    update bookings set status = 'used' where id = p_id and status = 'upcoming';
  end if;
end $$;

-- ───────────── Bảo mật hàng (RLS) ─────────────
alter table public.profiles       enable row level security;
alter table public.movies         enable row level security;
alter table public.cinemas        enable row level security;
alter table public.rooms          enable row level security;
alter table public.showtimes      enable row level security;
alter table public.combos         enable row level security;
alter table public.promotions     enable row level security;
alter table public.bookings       enable row level security;
alter table public.booking_seats  enable row level security;
alter table public.booking_combos enable row level security;
alter table public.reviews        enable row level security;
alter table public.favorites      enable row level security;

-- Danh mục: ai cũng xem được; chỉ quản lý được sửa.
do $$
declare t text;
begin
  foreach t in array array['movies', 'cinemas', 'rooms', 'showtimes', 'combos', 'promotions'] loop
    execute format('drop policy if exists "%1$s_read" on public.%1$s', t);
    execute format('create policy "%1$s_read" on public.%1$s for select using (true)', t);
    execute format('drop policy if exists "%1$s_manager_write" on public.%1$s', t);
    execute format(
      'create policy "%1$s_manager_write" on public.%1$s for all using (public.is_manager()) with check (public.is_manager())', t);
  end loop;
end $$;

drop policy if exists "profiles_read" on public.profiles;
create policy "profiles_read" on public.profiles for select
  using (id = auth.uid() or public.is_staff());
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid());
-- Người dùng chỉ được sửa họ tên và số điện thoại; không tự đổi role/điểm.
revoke update on public.profiles from anon, authenticated;
grant update (full_name, phone) on public.profiles to authenticated;

-- Ghế: ai cũng xem được trạng thái ghế để vẽ sơ đồ; ghi chỉ qua các hàm RPC ở trên.
drop policy if exists "booking_seats_read" on public.booking_seats;
create policy "booking_seats_read" on public.booking_seats for select using (true);

drop policy if exists "bookings_read" on public.bookings;
create policy "bookings_read" on public.bookings for select
  using (user_id = auth.uid() or public.is_staff());

drop policy if exists "booking_combos_read" on public.booking_combos;
create policy "booking_combos_read" on public.booking_combos for select
  using (exists (select 1 from public.bookings b
                 where b.id = booking_id and (b.user_id = auth.uid() or public.is_staff())));

drop policy if exists "reviews_read" on public.reviews;
create policy "reviews_read" on public.reviews for select using (true);
drop policy if exists "reviews_write_own" on public.reviews;
create policy "reviews_write_own" on public.reviews for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "favorites_own" on public.favorites;
create policy "favorites_own" on public.favorites for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Cho phép gọi hàm nghiệp vụ từ app
revoke all on function public.hold_seats(uuid, text[], int) from public;
revoke all on function public.release_seats(uuid, text[]) from public;
revoke all on function public.confirm_booking(uuid, text[], jsonb, numeric, text, text) from public;
revoke all on function public.set_booking_status(text, text) from public;
grant execute on function public.ensure_showtime(bigint, text, timestamptz) to anon, authenticated;
grant execute on function public.hold_seats(uuid, text[], int) to authenticated;
grant execute on function public.release_seats(uuid, text[]) to authenticated;
grant execute on function public.confirm_booking(uuid, text[], jsonb, numeric, text, text) to authenticated;
grant execute on function public.set_booking_status(text, text) to authenticated;

-- Realtime cho sơ đồ ghế
do $$
begin
  alter publication supabase_realtime add table public.booking_seats;
exception when duplicate_object then null;
end $$;
