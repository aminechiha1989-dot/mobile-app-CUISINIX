-- Cuisinix : ingrédients qu'on ne peut acheter qu'en emballage entier
-- sold_loose = true  : vendu à la portion (légumes, œufs...) -> on paie seulement la quantité utilisée
-- sold_loose = false : vendu en emballage (thon, harissa, beurre, fromage, lait) -> on paie l'emballage entier
-- À exécuter dans le SQL Editor de Supabase (peut être relancé sans risque).

alter table public.ingredients
  add column if not exists sold_loose boolean not null default true;

-- 25 thon, 12 harissa, 22 beurre, 24 fromage, 29 lait
update public.ingredients set sold_loose = false where id in (25, 12, 22, 24, 29);

select name, sold_loose from public.ingredients where sold_loose = false order by id;  -- doit renvoyer 5 lignes
