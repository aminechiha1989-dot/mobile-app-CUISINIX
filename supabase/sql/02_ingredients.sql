-- Cuisinix : 50 ingrédients courants avec prix moyens ESTIMÉS en DT
-- ATTENTION : ces prix sont des estimations de départ, à vérifier et corriger
-- avec les prix réels de ton marché. Les prix sont donnés pour :
--   1000 g, 1000 ml, ou 1 unité (colonne price_unit_qty).
-- À exécuter après 01_schema.sql, UNE SEULE FOIS.

insert into ingredients (name, category, unit, avg_price_dt, price_unit_qty) values
-- Légumes, herbes et fruits (DT / kg)
('Tomate', 'légume', 'g', 2.2, 1000),
('Pomme de terre', 'légume', 'g', 2.5, 1000),
('Oignon', 'légume', 'g', 2.0, 1000),
('Ail', 'légume', 'g', 12.0, 1000),
('Carotte', 'légume', 'g', 2.0, 1000),
('Courgette', 'légume', 'g', 3.0, 1000),
('Poivron', 'légume', 'g', 3.5, 1000),
('Piment piquant', 'légume', 'g', 5.0, 1000),
('Aubergine', 'légume', 'g', 3.0, 1000),
('Navet', 'légume', 'g', 2.0, 1000),
('Potiron', 'légume', 'g', 2.0, 1000),
('Persil', 'herbe', 'g', 8.0, 1000),
('Coriandre fraîche', 'herbe', 'g', 8.0, 1000),
('Citron', 'fruit', 'g', 4.0, 1000),
('Olives', 'conserve', 'g', 8.0, 1000),
('Menthe', 'herbe', 'g', 10.0, 1000),
('Céleri', 'légume', 'g', 3.0, 1000),
('Chou', 'légume', 'g', 1.5, 1000),
('Épinards', 'légume', 'g', 3.5, 1000),
-- Céréales et pain
('Semoule (couscous)', 'céréale', 'g', 2.0, 1000),
('Riz', 'céréale', 'g', 3.0, 1000),
('Pâtes', 'céréale', 'g', 2.0, 1000),
('Farine', 'céréale', 'g', 1.2, 1000),
('Baguette', 'pain', 'unité', 0.25, 1),
-- Légumineuses
('Pois chiches secs', 'légumineuse', 'g', 5.5, 1000),
('Lentilles', 'légumineuse', 'g', 5.0, 1000),
('Haricots blancs', 'légumineuse', 'g', 6.0, 1000),
-- Viandes et poissons
('Poulet', 'viande', 'g', 12.0, 1000),
('Bœuf haché', 'viande', 'g', 35.0, 1000),
('Agneau', 'viande', 'g', 42.0, 1000),
('Thon en conserve', 'poisson', 'unité', 3.5, 1),
('Sardines', 'poisson', 'g', 6.0, 1000),
-- Produits laitiers et œufs
('Œufs', 'œuf', 'unité', 0.45, 1),
('Lait', 'laitier', 'ml', 1.4, 1000),
('Beurre', 'laitier', 'g', 20.0, 1000),
('Fromage râpé', 'laitier', 'g', 25.0, 1000),
-- Matières grasses
('Huile d''olive', 'matière grasse', 'ml', 18.0, 1000),
('Huile de tournesol', 'matière grasse', 'ml', 3.5, 1000),
-- Épices et condiments (DT / kg)
('Sel', 'épice', 'g', 0.6, 1000),
('Poivre noir', 'épice', 'g', 40.0, 1000),
('Cumin', 'épice', 'g', 30.0, 1000),
('Carvi', 'épice', 'g', 35.0, 1000),
('Coriandre en poudre', 'épice', 'g', 30.0, 1000),
('Paprika', 'épice', 'g', 25.0, 1000),
('Harissa', 'condiment', 'g', 9.0, 1000),
('Concentré de tomate', 'condiment', 'g', 6.0, 1000),
('Curcuma', 'épice', 'g', 30.0, 1000),
('Cannelle', 'épice', 'g', 45.0, 1000),
('Thym séché', 'épice', 'g', 40.0, 1000),
('Sucre', 'épicerie', 'g', 1.7, 1000);
