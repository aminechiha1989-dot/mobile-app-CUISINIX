# Cuisinix – Assistant cuisine intelligent

> **Photographier → Cuisiner → Économiser**

Application mobile (Android/iOS) qui aide à décider quoi cuisiner à partir des aliments déjà disponibles. L'utilisateur photographie ses ingrédients ; l'application les identifie et propose des recettes adaptées à son **budget**, au **type de repas** et à la **cuisine** souhaitée (tunisienne, italienne, marocaine, etc.). Avec un budget de **0 DT**, elle ne propose que des plats réalisables avec ce que l'on possède déjà.

## Statut

MVP en cours : l'application Flutter (`app/`) et le backend Supabase (`supabase/`) sont en place. Fonctionnalités actuelles : liste de recettes avec filtres (repas, cuisine, budget), scan d'ingrédients par photo, recettes classées selon les ingrédients possédés, interface en français, anglais, arabe et derja tunisienne.

## Documentation

| Document | Contenu |
| --- | --- |
| [docs/CAHIER_DES_CHARGES.md](docs/CAHIER_DES_CHARGES.md) | Concept, fonctionnement, périmètre du MVP, évolutions |
| [docs/PLAN_V1.md](docs/PLAN_V1.md) | Plan en 10 étapes pour atteindre une première version testable |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Stack technique, flux de données, décisions d'architecture |
| [docs/BASE_DE_DONNEES.md](docs/BASE_DE_DONNEES.md) | Schéma Supabase et script SQL initial |
| [docs/ECRANS.md](docs/ECRANS.md) | Description des 5 écrans du MVP |
| [docs/RISQUES.md](docs/RISQUES.md) | Risques identifiés et mesures retenues |

## Stack prévue

Flutter · Supabase (auth, base de données, stockage, Edge Functions) · API de vision pour la reconnaissance des ingrédients · Open Food Facts / USDA FoodData Central · Git/GitHub · Figma (optionnel).

Objectif : un coût proche de 0 € pendant la création et les tests.

## Structure du dépôt

```
mobile-app-CUISINIX/
├── README.md
├── LICENSE
├── app/                        Application Flutter (lib/main.dart, android/, pubspec.yaml)
├── supabase/
│   ├── README.md
│   ├── sql/                    10 à 50 (base actuelle), 01 à 03 (ancien schéma)
│   └── functions/
│       └── quick-responder/    Edge Function de détection d'ingrédients (Gemini)
└── docs/
    ├── CAHIER_DES_CHARGES.md
    ├── PLAN_V1.md
    ├── ARCHITECTURE.md
    ├── BASE_DE_DONNEES.md
    ├── ECRANS.md
    └── RISQUES.md
```

## Scripts SQL (`supabase/sql/`)

- **Base actuelle** : les scripts `10_recettes_table.sql`, `20_ingredients.sql`, `30_recettes_supplementaires.sql`, `40_etapes_recettes.sql` et `50_traductions.sql` décrivent la base utilisée par l'application. À exécuter dans cet ordre dans le SQL Editor de Supabase.
- **Ancien schéma** : `01_schema.sql`, `02_ingredients.sql` et `03_recipes.sql` sont le premier schéma de conception. Il ne correspond plus à la base utilisée ; ils sont conservés à titre d'historique.

## Démarrage rapide

1. Backend : exécuter les scripts `10` à `50` de `supabase/sql/` dans l'ordre, puis déployer `supabase/functions/quick-responder` et y définir le secret `GEMINI_API_KEY` (voir [supabase/README.md](supabase/README.md)).
2. Application : `cd app && flutter pub get && flutter run`.
