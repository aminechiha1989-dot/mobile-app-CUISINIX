-- Cuisinix : schéma initial (V1)
-- À exécuter UNE SEULE FOIS dans Supabase > SQL Editor.

create table ingredients (
  id bigint generated always as identity primary key,
  name text not null unique,
  category text,
  unit text not null default 'g',          -- g, ml ou unité
  avg_price_dt numeric(8,3),               -- prix moyen en DT pour price_unit_qty
  price_unit_qty numeric not null default 1000,  -- quantité correspondant au prix (1000 g, 1000 ml ou 1 unité)
  updated_at timestamptz default now()
);

create type meal_type as enum ('petit_dejeuner', 'dejeuner', 'diner');

create table recipes (
  id bigint generated always as identity primary key,
  name text not null,
  cuisine text not null,                   -- tunisienne, italienne, marocaine...
  meal meal_type not null,
  prep_minutes int,
  steps text[] not null,
  created_at timestamptz default now()
);

create table recipe_ingredients (
  recipe_id bigint references recipes(id) on delete cascade,
  ingredient_id bigint references ingredients(id),
  quantity numeric not null,               -- dans l'unité de l'ingrédient (g, ml ou unité)
  primary key (recipe_id, ingredient_id)
);

create table favorites (
  user_id uuid references auth.users(id) on delete cascade,
  recipe_id bigint references recipes(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, recipe_id)
);

-- Sécurité (Row Level Security)
alter table ingredients enable row level security;
alter table recipes enable row level security;
alter table recipe_ingredients enable row level security;
alter table favorites enable row level security;

create policy "lecture publique ingredients" on ingredients for select using (true);
create policy "lecture publique recettes" on recipes for select using (true);
create policy "lecture publique recette_ingredients" on recipe_ingredients for select using (true);

create policy "favoris: lecture perso" on favorites for select using (auth.uid() = user_id);
create policy "favoris: ajout perso" on favorites for insert with check (auth.uid() = user_id);
create policy "favoris: suppression perso" on favorites for delete using (auth.uid() = user_id);
