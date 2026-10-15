-- Cuisinix : produits emballés de marques tunisiennes (conserves, fromage, beurre, lait, œufs)
-- pack_qty est dans l'unité de base de l'ingrédient : g, ml, pièces ou boîtes.
-- price_source indique d'où vient le prix ; « estimation » = prix non trouvé en ligne, à vérifier.
-- À exécuter dans le SQL Editor de Supabase (peut être relancé sans risque).

create table if not exists public.products (
  id bigint generated always as identity primary key,
  brand text not null,
  name text not null,
  ingredient_id bigint not null references public.ingredients(id),
  pack_qty numeric(8,2) not null check (pack_qty > 0),
  price_dt numeric(8,2) not null check (price_dt >= 0),
  price_updated date,
  price_source text,
  unique (brand, name)
);

alter table public.products enable row level security;

drop policy if exists products_public_read on public.products;
create policy products_public_read on public.products for select to anon, authenticated using (true);

insert into public.products (brand, name, ingredient_id, pack_qty, price_dt, price_updated, price_source) values
  ('La Goulette', 'Thon à l''huile végétale 160 g', 25, 1, 6.0, date '2026-10-11', 'benyaghlane.tn'),
  ('La Goulette', 'Thon à l''huile d''olive 160 g', 25, 1, 6.63, date '2026-10-11', 'benyaghlane.tn (lot de 3 à 19,90)'),
  ('Ben Yaghlane', 'Thon à l''huile d''olive 160 g', 25, 1, 6.5, date '2026-10-11', 'benyaghlane.tn'),
  ('Ben Yaghlane', 'Thon à l''huile végétale 160 g', 25, 1, 5.1, date '2026-10-11', 'benyaghlane.tn'),
  ('Neptune', 'Thon à l''huile d''olive 160 g', 25, 1, 6.5, date '2026-10-11', 'benyaghlane.tn'),
  ('Neptune', 'Thon en morceaux à l''huile végétale 130 g', 25, 1, 4.3, date '2026-10-11', 'benyaghlane.tn'),
  ('El Manar', 'Thon à l''huile végétale 160 g', 25, 1, 6.0, date '2026-10-11', 'benyaghlane.tn (lot de 3 à 18)'),
  ('MG J''aime', 'Thon entier à l''huile végétale 160 g', 25, 1, 4.72, date '2026-10-11', 'mg.tn (MG J''aime)'),
  ('Sidi Daoud', 'Thon entier à l''huile d''olive 160 g', 25, 1, 7.5, date '2026-10-11', 'estimation'),
  ('Sidi Jabeur', 'Thon à l''huile végétale 170 g', 25, 1, 5.5, date '2026-10-11', 'estimation'),
  ('El Badr', 'Thon entier à l''huile végétale 162 g', 25, 1, 5.5, date '2026-10-11', 'estimation'),
  ('Sicam', 'Harissa 135 g', 12, 135, 1.65, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('Sicam', 'Harissa 380 g', 12, 380, 4.2, date '2026-10-11', 'estimation'),
  ('Neblia', 'Harissa 135 g', 12, 135, 1.5, date '2026-10-11', 'estimation'),
  ('Zgolli', 'Harissa 135 g', 12, 135, 1.5, date '2026-10-11', 'estimation'),
  ('Sicam', 'Tomates pelées cubées 400 g', 1, 400, 2.35, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('Président', 'Fraidoux fromage frais 240 g', 24, 240, 5.58, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('Président', 'Fromage râpé Emmental 150 g', 24, 150, 4.5, date '2026-10-11', 'estimation'),
  ('Président', 'Fromage triangle 8 portions', 24, 140, 3.0, date '2026-10-11', 'estimation'),
  ('Land''or', 'Fromage tartine cuisine 240 g', 24, 240, 4.0, date '2026-10-11', 'estimation'),
  ('Délice', 'Beurre 100 g', 22, 100, 3.85, date '2026-10-11', 'Géant (via tunisie-prix.com)'),
  ('Délice', 'Beurre 200 g', 22, 200, 7.4, date '2026-10-11', 'estimation (d''après le beurre Délice 100 g)'),
  ('Vitalait', 'Beurre 200 g', 22, 200, 7.2, date '2026-10-11', 'estimation'),
  ('Délice', 'Lait demi-écrémé 1 L', 29, 1000, 1.35, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('Vitalait', 'Lait demi-écrémé 1 L', 29, 1000, 1.35, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('Candia', 'Lait demi-écrémé 1 L', 29, 1000, 1.4, date '2026-10-11', 'estimation'),
  ('El Mazraa', '15 œufs blancs', 4, 15, 7.19, date '2026-10-11', 'Carrefour (via tunisie-prix.com)'),
  ('El Mazraa', '30 œufs blancs', 4, 30, 13.49, date '2026-10-11', 'Géant (via tunisie-prix.com)')
on conflict (brand, name) do nothing;

select count(*) as produits from public.products;  -- doit renvoyer 28
