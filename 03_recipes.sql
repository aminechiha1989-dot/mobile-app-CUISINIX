-- Cuisinix : 10 recettes de départ (quantités pour 4 personnes)
-- À relire et ajuster avant publication. À exécuter après 02_ingredients.sql, UNE SEULE FOIS.
-- Les quantités sont exprimées dans l'unité de l'ingrédient (g, ml ou unité).

-- 1. Chakchouka (tunisienne, déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Chakchouka', 'tunisienne', 'dejeuner', 30,
    array[
      'Couper l''oignon, le poivron et les tomates en morceaux.',
      'Faire revenir l''oignon et l''ail dans l''huile d''olive.',
      'Ajouter le poivron, puis les tomates, la harissa, le sel et le cumin. Laisser mijoter 15 minutes.',
      'Creuser quatre petits puits dans la sauce et y casser les œufs.',
      'Couvrir et cuire 5 minutes jusqu''à ce que les blancs soient pris. Servir chaud avec du pain.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Tomate', 600), ('Poivron', 200), ('Oignon', 150), ('Ail', 10), ('Œufs', 4),
                   ('Harissa', 15), ('Huile d''olive', 40), ('Sel', 5), ('Cumin', 3)) as v(n, q)
join ingredients i on i.name = v.n;

-- 2. Lablabi (tunisienne, petit-déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Lablabi', 'tunisienne', 'petit_dejeuner', 90,
    array[
      'La veille, faire tremper les pois chiches dans de l''eau.',
      'Cuire les pois chiches 1 heure environ dans de l''eau avec l''ail écrasé jusqu''à ce qu''ils soient tendres.',
      'Assaisonner le bouillon avec le sel, le cumin et la harissa.',
      'Rompre le pain en morceaux au fond des bols et verser le bouillon avec les pois chiches.',
      'Ajouter un œuf cru ou poché, un filet d''huile d''olive et du jus de citron.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Pois chiches secs', 250), ('Ail', 15), ('Œufs', 4), ('Baguette', 2),
                   ('Harissa', 20), ('Cumin', 5), ('Huile d''olive', 40), ('Citron', 80), ('Sel', 5)) as v(n, q)
join ingredients i on i.name = v.n;

-- 3. Ojja aux œufs (tunisienne, dîner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Ojja aux œufs', 'tunisienne', 'diner', 25,
    array[
      'Faire chauffer l''huile d''olive et y faire revenir l''ail et le poivron coupé en lanières.',
      'Ajouter les tomates coupées, le concentré de tomate, la harissa, le carvi et le sel.',
      'Laisser réduire 10 minutes jusqu''à obtenir une sauce épaisse.',
      'Casser les œufs dans la sauce et les cuire à feu doux en remuant légèrement. Servir aussitôt.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Œufs', 4), ('Tomate', 500), ('Poivron', 150), ('Ail', 10), ('Harissa', 15),
                   ('Concentré de tomate', 30), ('Huile d''olive', 40), ('Sel', 5), ('Carvi', 3)) as v(n, q)
join ingredients i on i.name = v.n;

-- 4. Salade méchouia (tunisienne, dîner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Salade méchouia', 'tunisienne', 'diner', 35,
    array[
      'Griller les tomates, les poivrons et les piments, puis les laisser refroidir.',
      'Les peler et retirer les graines, puis les hacher finement.',
      'Mélanger avec l''ail écrasé, l''huile d''olive, le jus de citron, le sel et le carvi.',
      'Servir frais, avec du thon émietté.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Tomate', 400), ('Poivron', 300), ('Piment piquant', 50), ('Ail', 10),
                   ('Huile d''olive', 40), ('Citron', 40), ('Sel', 5), ('Carvi', 3), ('Thon en conserve', 1)) as v(n, q)
join ingredients i on i.name = v.n;

-- 5. Couscous au poulet et légumes (tunisienne, déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Couscous au poulet et légumes', 'tunisienne', 'dejeuner', 90,
    array[
      'La veille, faire tremper les pois chiches.',
      'Faire revenir le poulet et l''oignon émincé dans l''huile d''olive avec le curcuma, le poivre et le sel.',
      'Ajouter le concentré de tomate, la harissa et de l''eau, puis les pois chiches. Cuire 30 minutes.',
      'Ajouter les carottes et les courgettes coupées, et cuire encore 25 minutes.',
      'Pendant ce temps, préparer la semoule à la vapeur ou la réhydrater selon le paquet.',
      'Servir la semoule avec la viande, les légumes et la sauce.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Semoule (couscous)', 500), ('Poulet', 800), ('Oignon', 200), ('Carotte', 300),
                   ('Courgette', 300), ('Pois chiches secs', 100), ('Concentré de tomate', 30), ('Harissa', 15),
                   ('Huile d''olive', 60), ('Sel', 8), ('Poivre noir', 3), ('Curcuma', 3)) as v(n, q)
join ingredients i on i.name = v.n;

-- 6. Pâtes sauce tomate (italienne, dîner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Pâtes sauce tomate', 'italienne', 'diner', 25,
    array[
      'Faire revenir l''oignon haché et l''ail dans l''huile d''olive.',
      'Ajouter les tomates coupées, le sel et le thym. Laisser mijoter 15 minutes.',
      'Cuire les pâtes dans une grande casserole d''eau salée, puis les égoutter.',
      'Mélanger les pâtes à la sauce et saupoudrer de fromage râpé.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Pâtes', 400), ('Tomate', 600), ('Oignon', 100), ('Ail', 10),
                   ('Huile d''olive', 40), ('Sel', 5), ('Fromage râpé', 40), ('Thym séché', 2)) as v(n, q)
join ingredients i on i.name = v.n;

-- 7. Omelette aux pommes de terre (française, déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Omelette aux pommes de terre', 'française', 'dejeuner', 30,
    array[
      'Éplucher et couper les pommes de terre en fines tranches, émincer l''oignon.',
      'Les cuire doucement dans l''huile 15 minutes jusqu''à ce qu''elles soient tendres.',
      'Battre les œufs avec le sel et le poivre, puis y mélanger les pommes de terre.',
      'Verser dans la poêle et cuire 5 minutes de chaque côté.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Pomme de terre', 500), ('Œufs', 6), ('Oignon', 100),
                   ('Huile de tournesol', 60), ('Sel', 5), ('Poivre noir', 2)) as v(n, q)
join ingredients i on i.name = v.n;

-- 8. Tajine de poulet aux olives (marocaine, déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Tajine de poulet aux olives', 'marocaine', 'dejeuner', 75,
    array[
      'Mélanger le poulet avec l''ail, le curcuma, le cumin, le sel et le poivre.',
      'Faire revenir l''oignon émincé dans l''huile d''olive, ajouter le poulet et le dorer.',
      'Ajouter un verre d''eau, couvrir et cuire à feu doux 45 minutes.',
      'Ajouter les olives, le citron en tranches et la coriandre hachée, et cuire encore 10 minutes.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Poulet', 900), ('Oignon', 300), ('Olives', 150), ('Citron', 100), ('Ail', 15),
                   ('Curcuma', 3), ('Cumin', 3), ('Coriandre fraîche', 30), ('Huile d''olive', 40),
                   ('Sel', 6), ('Poivre noir', 2)) as v(n, q)
join ingredients i on i.name = v.n;

-- 9. Soupe de lentilles (turque, dîner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Soupe de lentilles', 'turque', 'diner', 40,
    array[
      'Faire fondre le beurre et y faire revenir l''oignon haché.',
      'Ajouter les carottes et la pomme de terre en dés, le concentré de tomate, les lentilles rincées et 1,5 litre d''eau.',
      'Cuire 25 minutes jusqu''à ce que les lentilles soient très tendres, puis mixer.',
      'Assaisonner avec le sel, le cumin et le paprika. Servir avec un filet de citron.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Lentilles', 250), ('Oignon', 150), ('Carotte', 150), ('Pomme de terre', 150),
                   ('Concentré de tomate', 20), ('Beurre', 30), ('Paprika', 3), ('Sel', 6),
                   ('Citron', 40), ('Cumin', 2)) as v(n, q)
join ingredients i on i.name = v.n;

-- 10. Crêpes (française, petit-déjeuner)
with r as (
  insert into recipes (name, cuisine, meal, prep_minutes, steps) values (
    'Crêpes', 'française', 'petit_dejeuner', 30,
    array[
      'Mélanger la farine, le sucre et le sel dans un saladier.',
      'Ajouter les œufs, puis le lait petit à petit en fouettant pour éviter les grumeaux.',
      'Laisser reposer la pâte 15 minutes.',
      'Cuire une louche de pâte dans une poêle beurrée, 1 minute de chaque côté.'
    ]) returning id)
insert into recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.q from r
cross join (values ('Farine', 250), ('Œufs', 2), ('Lait', 500), ('Sucre', 30),
                   ('Beurre', 30), ('Sel', 1)) as v(n, q)
join ingredients i on i.name = v.n;
