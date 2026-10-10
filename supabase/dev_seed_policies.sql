-- CHỈ DÙNG KHI DEV: cho phép app (khóa anon) tự nạp dữ liệu mẫu qua DatabaseSeeder.
-- Làm xong NHỚ chạy supabase/drop_dev_seed_policies.sql để đóng lại.
do $$
declare t text;
begin
  foreach t in array array['movies', 'cinemas', 'rooms', 'combos', 'promotions'] loop
    execute format('drop policy if exists "%1$s_dev_seed" on public.%1$s', t);
    execute format('create policy "%1$s_dev_seed" on public.%1$s for insert to anon, authenticated with check (true)', t);
  end loop;
end $$;
