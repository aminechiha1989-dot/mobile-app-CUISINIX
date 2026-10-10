# Cahier des charges

## 1. Concept

Une application mobile qui aide l'utilisateur à décider quoi cuisiner à partir des aliments qu'il possède déjà. Il photographie ses ingrédients ; l'application les détecte et propose des recettes selon son **budget**, le **type de repas** et la **cuisine du pays** souhaité.

Positionnement : *« Je photographie ce que j'ai chez moi et l'application me dit quoi cuisiner selon mon budget et mes goûts. »*

Angle différenciant : budget (dont l'option « budget 0 ») + cuisines du monde + marché local, en commençant par la Tunisie et le Maghreb.

## 2. Parcours utilisateur principal

1. L'utilisateur photographie les aliments disponibles.
2. L'application détecte les ingrédients présents.
3. L'utilisateur confirme, supprime ou ajoute des ingrédients.
4. Il choisit le repas : petit-déjeuner, déjeuner ou dîner.
5. Il indique son budget (possibilité de choisir **0 DT**).
6. Il choisit une cuisine : tunisienne, italienne, française, marocaine, turque, indienne, mexicaine, etc.
7. L'application propose plusieurs plats.
8. Pour chaque plat : ingrédients disponibles, ingrédients manquants, coût estimé, temps de préparation, étapes.

## 3. Périmètre du MVP (V1)

Inclus :

- Saisie d'ingrédients (manuelle, puis par photo)
- Correction manuelle des ingrédients détectés
- Choix du repas, du budget (avec option « budget 0 ») et de la cuisine
- Suggestions de recettes avec ingrédients manquants et coût estimé
- Instructions de préparation étape par étape
- Favoris
- Compte utilisateur, demandé uniquement pour enregistrer des favoris
- Un seul pays (Tunisie) et une seule devise (DT) au lancement

Exclus de la V1 : nutrition, comparaison de magasins, régimes alimentaires, historique, multi-pays.

## 4. Évolutions prévues

**V2** : calories et informations nutritionnelles, protéines/glucides/lipides, allergies, régimes alimentaires, recettes végétariennes, historique des repas.

**V3** : prix actualisés des ingrédients, comparaison entre magasins et marchés locaux, calcul du panier le moins cher, recommandations selon la ville et le pays.

La comparaison de prix vient après le MVP car les prix doivent provenir de sources fiables et être mis à jour régulièrement.

## 5. Contraintes

- Coût proche de 0 € pendant la création et les tests.
- Développement par une personne, assistée de Claude.
- Estimation de coût basée sur une table de prix moyens maintenue manuellement (environ 50 ingrédients courants), présentée comme « estimation ».
- Recettes issues d'une base vérifiée (tunisiennes et maghrébines), complétée plus tard par de la génération.

## 6. Critère de succès de la V1

20 personnes utilisent l'application et au moins une partie d'entre elles reviennent après deux utilisations.
