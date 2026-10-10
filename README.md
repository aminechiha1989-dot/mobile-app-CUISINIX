# Cuisinix – Assistant cuisine intelligent

> **Photographier → Cuisiner → Économiser**

Application mobile (Android/iOS) qui aide à décider quoi cuisiner à partir des aliments déjà disponibles. L'utilisateur photographie ses ingrédients ; l'application les identifie et propose des recettes adaptées à son **budget**, au **type de repas** et à la **cuisine** souhaitée (tunisienne, italienne, marocaine, etc.). Avec un budget de **0 DT**, elle ne propose que des plats réalisables avec ce que l'on possède déjà.

## Statut

Phase de conception : documentation et définition du MVP. Aucun code applicatif pour l'instant.

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
mobile-app-cuisinix/
├── README.md
└── docs/
    ├── CAHIER_DES_CHARGES.md
    ├── PLAN_V1.md
    ├── ARCHITECTURE.md
    ├── BASE_DE_DONNEES.md
    ├── ECRANS.md
    └── RISQUES.md
```

Le dossier de l'application Flutter (`app/`) sera ajouté à l'étape 4 du plan.
