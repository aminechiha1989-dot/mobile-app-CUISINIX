-- Cuisinix : photos des plats
-- image_query : mot-clé anglais pour trouver la photo sur Wikipédia (gratuit)
-- image_url   : adresse d'une photo précise ; si elle est remplie, elle remplace la recherche
-- À exécuter dans le SQL Editor de Supabase (peut être relancé sans risque).

alter table public.recipes
  add column if not exists image_query text,
  add column if not exists image_url text;

update public.recipes r set image_query = v.q
from (values
  (1, 'Lablabi'),
  (2, 'Omelette'),
  (3, 'Couscous'),
  (4, 'Shakshouka'),
  (5, 'Ojja'),
  (6, 'Mechouia'),
  (7, 'Spaghetti al pomodoro'),
  (8, 'Lentil soup'),
  (9, 'Bruschetta'),
  (10, 'Grilled fish'),
  (11, 'Tunisian tajine'),
  (12, 'Rice and tuna'),
  (13, 'Chorba'),
  (14, 'Msemen'),
  (15, 'Tortilla de patatas'),
  (16, 'Vegetable soup'),
  (17, 'Fried egg'),
  (18, 'Fried eggplant'),
  (19, 'Gratin'),
  (20, 'Marqa'),
  (21, 'Mujaddara'),
  (22, 'Stuffed peppers'),
  (23, 'Ful medames'),
  (24, 'Kofta'),
  (25, 'Tuna salad'),
  (26, 'Brik'),
  (27, 'Spaghetti'),
  (28, 'Frittata'),
  (29, 'Open sandwich'),
  (30, 'Gratin dauphinois'),
  (31, 'Chicken and rice'),
  (32, 'Pizza'),
  (33, 'Tunisian salad'),
  (34, 'Fricassé')
) as v(id, q)
where r.id = v.id and r.image_query is null;

select count(*) as recettes_avec_photo_prevue from public.recipes where image_query is not null;  -- doit renvoyer 34
