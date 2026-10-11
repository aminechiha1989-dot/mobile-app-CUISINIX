-- Cuisinix : étapes de préparation (colonne steps, une étape par ligne)
alter table public.recipes add column if not exists steps text;

update public.recipes r set steps = v.steps
from (values
  ('Lablabi', 'Faire tremper les pois chiches la veille, puis les cuire dans l''eau jusqu''à ce qu''ils soient tendres.
Écraser l''ail avec le sel, le citron et la harissa.
Couper le pain en morceaux dans des bols et verser les pois chiches avec leur bouillon chaud.
Ajouter l''ail et la harissa, un filet d''huile d''olive, et un oeuf si vous aimez.'),
  ('Omelette tunisienne', 'Faire revenir l''oignon émincé et la pomme de terre en dés.
Battre les oeufs avec le persil haché, le sel et le poivre.
Verser sur les légumes et cuire à feu moyen des deux côtés.'),
  ('Couscous au poulet', 'Faire revenir l''oignon et le poulet, ajouter la tomate, le sel et les épices, puis couvrir d''eau.
Ajouter les pois chiches et les carottes, cuire 30 minutes, puis la courgette 15 minutes.
Humecter la semoule, la cuire à la vapeur au-dessus de la sauce en l''égrainant à la main.
Servir la semoule avec la sauce, le poulet et les légumes.'),
  ('Chakchouka', 'Faire revenir l''oignon, l''ail et le poivron en lanières dans l''huile.
Ajouter la tomate, la harissa, le sel, et cuire 15 minutes.
Casser les oeufs sur la sauce, couvrir et cuire jusqu''à ce que le blanc soit pris.'),
  ('Ojja merguez', 'Faire revenir l''ail et le poivron dans l''huile, ajouter la tomate et la harissa.
Ajouter les merguez coupées et cuire 10 minutes.
Casser les oeufs sur la sauce et cuire à couvert 3 à 5 minutes.'),
  ('Salade méchouia', 'Griller les poivrons, les tomates et les piments jusqu''à ce que la peau noircisse.
Les éplucher, retirer les graines et hacher finement.
Mélanger avec l''ail écrasé, le jus de citron, l''huile d''olive et le sel.'),
  ('Pâtes à la tomate', 'Cuire les pâtes dans l''eau salée.
Faire revenir l''ail dans l''huile d''olive, ajouter la tomate et cuire 10 minutes.
Mélanger les pâtes égouttées avec la sauce.'),
  ('Soupe de lentilles', 'Faire revenir l''oignon, l''ail et la carotte en petits dés.
Ajouter les lentilles rincées et couvrir d''eau, cuire 25 minutes.
Mixer si vous aimez une soupe lisse, assaisonner et servir avec du citron.'),
  ('Pain grillé à l''huile d''olive et harissa', 'Griller les tranches de pain.
Arroser d''huile d''olive et tartiner de harissa.
Servir tout de suite.'),
  ('Msemen au miel', 'Pétrir la farine avec de l''eau tiède et du sel, puis laisser reposer 15 minutes.
Former des boules, les étaler très finement et les beurrer.
Plier chaque pâte en carré et cuire dans une poêle chaude des deux côtés.
Servir tiède avec du miel.'),
  ('Oeufs au plat à la harissa', 'Chauffer l''huile d''olive dans une poêle.
Casser les oeufs et les cuire à feu doux.
Ajouter une cuillère de harissa à côté des oeufs et servir.'),
  ('Tartine thon et fromage', 'Égoutter le thon et l''émietter.
Tartiner le pain de fromage et ajouter le thon.
Passer au four quelques minutes si vous aimez le fromage fondu.'),
  ('Fricassé tunisien', 'Pétrir une pâte souple (farine, eau, levure) ou utiliser du pain de fricassé, puis frire de petites miches dans l''huile chaude.
Cuire les pommes de terre et les oeufs durs, couper en morceaux.
Ouvrir les pains, garnir de thon, pommes de terre, oeuf, olives et harissa.'),
  ('Brik à l''oeuf et au thon', 'Mélanger le thon égoutté avec le persil haché.
Déposer la garniture sur une feuille de brick et casser un oeuf au centre.
Plier en triangle et frire quelques minutes de chaque côté.'),
  ('Riz au poulet', 'Faire revenir le poulet avec l''oignon et la carotte râpée.
Ajouter le riz lavé et deux fois son volume d''eau, saler et épicer.
Couvrir et cuire à feu doux jusqu''à absorption de l''eau.'),
  ('Gratin de pommes de terre', 'Éplucher et couper les pommes de terre en fines rondelles.
Les disposer dans un plat, verser le lait salé et poivré, couvrir de fromage.
Cuire au four à 180 °C pendant 35 à 40 minutes.'),
  ('Salade tunisienne', 'Couper la tomate, le concombre et l''oignon en petits dés, et le piment en rondelles.
Assaisonner avec l''huile d''olive, le jus de citron et le sel.
Servir frais.'),
  ('Salade de thon', 'Couper la tomate et l''oeuf dur en morceaux.
Ajouter le thon égoutté et les olives.
Assaisonner d''huile, de citron et de sel.'),
  ('Spaghetti au thon et à la tomate', 'Cuire les pâtes dans l''eau salée.
Faire revenir l''ail, ajouter la tomate et cuire 10 minutes, puis le thon égoutté.
Mélanger avec les pâtes.'),
  ('Kefta de boeuf', 'Mélanger la viande hachée avec l''oignon, l''ail et le persil hachés, le sel et les épices.
Former des boulettes allongées.
Les cuire à la poêle ou au grill 10 à 12 minutes en les retournant.'),
  ('Tajine tunisien au poulet', 'Cuire le poulet effiloché avec un peu d''oignon.
Mélanger avec les oeufs battus, le fromage râpé, le persil et le sel.
Verser dans un plat huilé et cuire au four à 180 °C pendant 30 minutes.'),
  ('Marqa de poulet aux pois chiches', 'Faire revenir l''oignon et l''ail, ajouter le poulet et dorer.
Ajouter la tomate, les pois chiches, les épices et de l''eau.
Laisser mijoter 35 à 40 minutes à feu doux.'),
  ('Lentilles au riz', 'Cuire les lentilles à l''eau 15 minutes.
Ajouter le riz et un peu d''eau, cuire jusqu''à ce qu''il soit tendre.
Faire dorer l''oignon émincé dans l''huile et le déposer dessus.'),
  ('Poivrons farcis', 'Mélanger la viande hachée, le riz cru, l''oignon haché, la tomate et les épices.
Couper le haut des poivrons, les vider et les remplir.
Les cuire dans une sauce tomate à feu doux, ou au four, pendant 45 minutes.'),
  ('Aubergines frites à la tomate', 'Couper les aubergines en tranches, les saler et les laisser dégorger.
Les frire à l''huile, puis les égoutter.
Préparer une sauce avec l''ail, la tomate et l''huile d''olive, et napper les aubergines.'),
  ('Chorba à l''agneau', 'Faire revenir l''oignon et l''agneau en morceaux, ajouter la tomate et les épices.
Ajouter les pois chiches et couvrir d''eau, cuire 45 minutes.
Servir avec de la menthe séchée.'),
  ('Poisson grillé au citron', 'Mariner le poisson avec l''ail écrasé, l''huile d''olive, le sel et le jus de citron pendant 15 minutes.
Griller 5 à 7 minutes de chaque côté selon la taille.
Servir avec des quartiers de citron.'),
  ('Soupe de légumes', 'Couper la carotte, la pomme de terre, la courgette et l''oignon en morceaux.
Les faire revenir quelques minutes, couvrir d''eau et cuire 25 minutes.
Mixer ou laisser en morceaux, assaisonner.'),
  ('Omelette aux épinards', 'Faire revenir l''ail et les épinards lavés jusqu''à ce qu''ils réduisent.
Verser les oeufs battus et assaisonner.
Cuire à feu doux des deux côtés.'),
  ('Doubara aux fèves', 'Cuire les fèves dans l''eau jusqu''à ce qu''elles soient très tendres.
Les écraser légèrement avec l''ail, la harissa et l''huile d''olive.
Servir chaud avec du pain.'),
  ('Pizza maison', 'Pétrir la farine avec de l''eau, de la levure, du sel et un peu d''huile, laisser lever 1 heure.
Étaler la pâte, couvrir de sauce tomate, de fromage et d''olives.
Cuire au four à 220 °C pendant 15 minutes.'),
  ('Riz au thon', 'Faire revenir l''oignon et la tomate.
Ajouter le riz lavé et l''eau, saler et cuire à couvert.
Incorporer le thon égoutté en fin de cuisson.'),
  ('Pommes de terre sautées aux oeufs', 'Couper les pommes de terre en dés et les faire dorer avec l''oignon.
Ajouter les oeufs battus et mélanger doucement.
Cuire jusqu''à ce que les oeufs soient pris.'),
  ('Gratin de courgettes', 'Couper les courgettes en rondelles et les faire revenir légèrement.
Mélanger les oeufs, le lait et la moitié du fromage, saler.
Verser sur les courgettes, couvrir du reste de fromage et cuire à 180 °C pendant 30 minutes.')
) as v(name, steps)
where r.name = v.name;
