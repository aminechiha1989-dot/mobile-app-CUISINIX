# Architecture

## Vue d'ensemble

```
Application Flutter (Android / iOS)
   │
   ├── Supabase Auth ............ comptes (requis seulement pour les favoris)
   ├── Supabase Postgres ........ ingrédients, recettes, favoris
   ├── Supabase Storage ......... photos envoyées (optionnel, durée limitée)
   └── Supabase Edge Function ... appelle l'API de vision (clé secrète côté serveur)
                                   │
                                   └── API de vision → liste d'ingrédients détectés
```

## Décisions

| Sujet | Décision | Raison |
| --- | --- | --- |
| Mobile | Flutter | Un seul code pour Android et iOS |
| Backend | Supabase | Auth, base, stockage et fonctions gratuits au démarrage |
| Reconnaissance photo | API de vision appelée via Edge Function | La clé API ne doit jamais être dans l'application |
| Photo | Aide à la saisie, pas source de vérité | La détection est imparfaite ; l'écran de confirmation est central |
| Prix | Table de prix moyens maintenue à la main | Open Food Facts et USDA ne fournissent presque pas de prix locaux |
| Recettes | Base vérifiée tunisienne et maghrébine | Qualité et authenticité ; génération IA plus tard |
| Compte | Facultatif au départ | Réduire la friction du premier usage |
| Pays | Tunisie, devise DT | Limiter la complexité de la V1 |

## Algorithme de correspondance

Pour chaque recette :

1. `présents` = ingrédients de la recette que l'utilisateur possède.
2. `manquants` = ingrédients de la recette qu'il ne possède pas.
3. `coût_manquant` = somme des prix moyens des manquants, selon la quantité requise.
4. `taux` = présents / total des ingrédients de la recette.

Filtres : repas, cuisine, `coût_manquant ≤ budget` (avec budget 0, uniquement les recettes sans manquants). Tri par `taux` décroissant.

## Sécurité

- Clés API uniquement dans les secrets des Edge Functions.
- Row Level Security (RLS) activée sur `favorites` : chaque utilisateur ne voit que ses favoris.
- Limite quotidienne de photos pour maîtriser le coût de l'API de vision.

## Sources de données

- Open Food Facts et USDA FoodData Central : informations produits et nutrition (V2).
- Prix : table interne, signalée comme estimation.
