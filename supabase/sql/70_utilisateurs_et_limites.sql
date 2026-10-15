-- Cuisinix : compteur d'utilisateurs anonymes et limite de scans par jour.
-- Aucune donnée personnelle : seulement un identifiant aléatoire généré par l'app.
-- Les tables sont fermées (RLS sans règle) : seules les fonctions ci-dessous y accèdent.

create table if not exists public.cuisinix_devices (
  device_id   text primary key,
  first_seen  timestamptz not null default now(),
  last_seen   timestamptz not null default now(),
  app_version text,
  scan_total  integer not null default 0
);

create table if not exists public.cuisinix_scan_usage (
  day       date    not null,
  device_id text    not null,   -- '__global__' = total de tous les utilisateurs du jour
  scans     integer not null default 0,
  primary key (day, device_id)
);

alter table public.cuisinix_devices    enable row level security;
alter table public.cuisinix_scan_usage enable row level security;

-- Jour courant en Tunisie
create or replace function public.cuisinix_today() returns date
language sql stable as $$ select (now() at time zone 'Africa/Tunis')::date $$;

-- Appelée par l'app à chaque ouverture : enregistre / met à jour l'appareil
create or replace function public.register_device(p_device text, p_version text default null)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if p_device is null or p_device !~ '^[A-Za-z0-9_-]{16,64}$' then
    return;
  end if;
  insert into cuisinix_devices (device_id, app_version)
  values (p_device, left(p_version, 20))
  on conflict (device_id) do update
    set last_seen = now(),
        app_version = coalesce(excluded.app_version, cuisinix_devices.app_version);
end $$;

-- Appelée uniquement par la fonction serveur : réserve un scan
-- Retourne 'ok', 'device_limit' ou 'global_limit'
create or replace function public.consume_scan(p_device text, p_device_limit int, p_global_limit int)
returns text
language plpgsql security definer set search_path = public as $$
declare d date := cuisinix_today(); n int;
begin
  insert into cuisinix_scan_usage (day, device_id, scans) values (d, p_device, 0)
    on conflict do nothing;
  insert into cuisinix_scan_usage (day, device_id, scans) values (d, '__global__', 0)
    on conflict do nothing;

  update cuisinix_scan_usage set scans = scans + 1
   where day = d and device_id = p_device and scans < p_device_limit
   returning scans into n;
  if n is null then return 'device_limit'; end if;

  update cuisinix_scan_usage set scans = scans + 1
   where day = d and device_id = '__global__' and scans < p_global_limit
   returning scans into n;
  if n is null then
    update cuisinix_scan_usage set scans = scans - 1 where day = d and device_id = p_device;
    return 'global_limit';
  end if;

  insert into cuisinix_devices (device_id, scan_total) values (p_device, 1)
    on conflict (device_id) do update
      set scan_total = cuisinix_devices.scan_total + 1, last_seen = now();
  return 'ok';
end $$;

-- Rend un scan si l'analyse a échoué côté serveur
create or replace function public.refund_scan(p_device text)
returns void
language plpgsql security definer set search_path = public as $$
declare d date := cuisinix_today();
begin
  update cuisinix_scan_usage set scans = greatest(scans - 1, 0)
   where day = d and device_id in (p_device, '__global__');
  update cuisinix_devices set scan_total = greatest(scan_total - 1, 0) where device_id = p_device;
end $$;

-- Droits : l'app (anon) ne peut qu'enregistrer un appareil
revoke all on function public.register_device(text, text)      from public;
revoke all on function public.consume_scan(text, int, int)     from public;
revoke all on function public.refund_scan(text)                from public;
revoke all on function public.cuisinix_today()                 from public;
grant execute on function public.register_device(text, text)   to anon, authenticated;
grant execute on function public.consume_scan(text, int, int)  to service_role;
grant execute on function public.refund_scan(text)             to service_role;
grant execute on function public.cuisinix_today()              to service_role;

-- Pour compter les utilisateurs (à lancer dans l'éditeur SQL de Supabase) :
--   select count(*) as total,
--          count(*) filter (where last_seen > now() - interval '1 day')  as actifs_24h,
--          count(*) filter (where last_seen > now() - interval '7 days') as actifs_7j,
--          count(*) filter (where first_seen > now() - interval '1 day') as nouveaux_24h
--   from cuisinix_devices;
--   select * from cuisinix_scan_usage where day = (now() at time zone 'Africa/Tunis')::date order by scans desc;
