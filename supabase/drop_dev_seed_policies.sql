do $$
declare t text;
begin
  foreach t in array array['movies', 'cinemas', 'rooms', 'combos', 'promotions'] loop
    execute format('drop policy if exists "%1$s_dev_seed" on public.%1$s', t);
  end loop;
end $$;
