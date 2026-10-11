-- Cuisinix : ingrédients + lien avec les recettes
create table if not exists public.ingredients (
  id bigint generated always as identity primary key,
  name text not null unique
);

create table if not exists public.recipe_ingredients (
  recipe_id bigint not null references public.recipes(id) on delete cascade,
  ingredient_id bigint not null references public.ingredients(id) on delete cascade,
  primary key (recipe_id, ingredient_id)
);

alter table public.ingredients enable row level security;
alter table public.recipe_ingredients enable row level security;

create policy "ingredients_public_read" on public.ingredients
  for select to anon, authenticated using (true);
create policy "recipe_ingredients_public_read" on public.recipe_ingredients
  for select to anon, authenticated using (true);

insert into public.ingredients (name) values
  ('tomate'),('oignon'),('ail'),('oeuf'),('poulet'),('pois chiche'),('semoule'),
  ('pâtes'),('lentilles'),('pain'),('huile d''olive'),('harissa'),('poivron'),
  ('piment'),('merguez'),('pomme de terre'),('carotte'),('courgette'),('citron'),('persil')
on conflict (name) do nothing;

insert into public.recipe_ingredients (recipe_id, ingredient_id)
select r.id, i.id
from (values
  ('Lablabi','pois chiche'),('Lablabi','pain'),('Lablabi','ail'),('Lablabi','harissa'),
  ('Lablabi','huile d''olive'),('Lablabi','citron'),('Lablabi','oeuf'),
  ('Omelette tunisienne','oeuf'),('Omelette tunisienne','oignon'),
  ('Omelette tunisienne','persil'),('Omelette tunisienne','pomme de terre'),
  ('Couscous au poulet','semoule'),('Couscous au poulet','poulet'),
  ('Couscous au poulet','carotte'),('Couscous au poulet','courgette'),
  ('Couscous au poulet','pois chiche'),('Couscous au poulet','oignon'),
  ('Couscous au poulet','tomate'),
  ('Chakchouka','oeuf'),('Chakchouka','tomate'),('Chakchouka','poivron'),
  ('Chakchouka','oignon'),('Chakchouka','ail'),('Chakchouka','harissa'),
  ('Ojja merguez','merguez'),('Ojja merguez','oeuf'),('Ojja merguez','tomate'),
  ('Ojja merguez','poivron'),('Ojja merguez','ail'),('Ojja merguez','harissa'),
  ('Salade méchouia','poivron'),('Salade méchouia','tomate'),('Salade méchouia','ail'),
  ('Salade méchouia','huile d''olive'),('Salade méchouia','citron'),('Salade méchouia','piment'),
  ('Pâtes à la tomate','pâtes'),('Pâtes à la tomate','tomate'),('Pâtes à la tomate','ail'),
  ('Pâtes à la tomate','huile d''olive'),
  ('Soupe de lentilles','lentilles'),('Soupe de lentilles','oignon'),
  ('Soupe de lentilles','carotte'),('Soupe de lentilles','ail'),('Soupe de lentilles','citron'),
  ('Pain grillé à l''huile d''olive et harissa','pain'),
  ('Pain grillé à l''huile d''olive et harissa','huile d''olive'),
  ('Pain grillé à l''huile d''olive et harissa','harissa')
) as v(recipe_name, ingredient_name)
join public.recipes r on r.name = v.recipe_name
join public.ingredients i on i.name = v.ingredient_name
on conflict do nothing;
