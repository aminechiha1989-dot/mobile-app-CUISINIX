-- Cuisinix : table des recettes (état actuel de la base Supabase)
-- Ordre d'exécution : 10 -> 20 -> 30 -> 40 -> 50

create table if not exists public.recipes (
  id bigint generated always as identity primary key,
  name text not null,
  cuisine text not null,
  meal text not null check (meal in ('petit_dejeuner','dejeuner','diner')),
  prep_minutes integer not null check (prep_minutes > 0),
  cost_dt numeric(6,2) not null default 0 check (cost_dt >= 0),
  steps text,
  translations jsonb,
  created_at timestamptz not null default now()
);

alter table public.recipes enable row level security;

-- Lecture publique, aucune écriture depuis l'application
create policy "recipes_public_read" on public.recipes
  for select to anon, authenticated using (true);

insert into public.recipes (name, cuisine, meal, prep_minutes, cost_dt)
select v.name, v.cuisine, v.meal, v.prep, v.cost
from (values
  ('Lablabi', 'Tunisienne', 'petit_dejeuner', 30, 3),
  ('Omelette tunisienne', 'Tunisienne', 'petit_dejeuner', 15, 2),
  ('Couscous au poulet', 'Tunisienne', 'dejeuner', 90, 15),
  ('Chakchouka', 'Tunisienne', 'dejeuner', 25, 4),
  ('Ojja merguez', 'Tunisienne', 'diner', 30, 8),
  ('Salade méchouia', 'Tunisienne', 'diner', 40, 3),
  ('Pâtes à la tomate', 'Italienne', 'dejeuner', 20, 3),
  ('Soupe de lentilles', 'Orientale', 'diner', 35, 2),
  ('Pain grillé à l''huile d''olive et harissa', 'Tunisienne', 'petit_dejeuner', 5, 0)
) as v(name, cuisine, meal, prep, cost)
where not exists (select 1 from public.recipes x where x.name = v.name);
