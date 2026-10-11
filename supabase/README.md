# Backend Supabase

| Dossier | Contenu |
| --- | --- |
| `sql/` | Scripts SQL (voir ci-dessous). |
| `functions/quick-responder/` | Edge Function de détection d'ingrédients par photo (Gemini, offre gratuite). Appelée par l'app Flutter. |

## Scripts SQL

**Base actuelle** : les scripts `10` à `50` décrivent la base utilisée par l'application. À exécuter dans cet ordre dans le SQL Editor de Supabase :

1. `10_recettes_table.sql`
2. `20_ingredients.sql`
3. `30_recettes_supplementaires.sql`
4. `40_etapes_recettes.sql`
5. `50_traductions.sql`

**Ancien schéma** : `01_schema.sql`, `02_ingredients.sql` et `03_recipes.sql` sont le premier schéma de conception. Il ne correspond plus à la base utilisée ; ils sont conservés à titre d'historique et ne doivent pas être exécutés.

## Fonction Edge

- Le secret `GEMINI_API_KEY` se configure dans Supabase (Edge Functions > Secrets). Il ne doit jamais être commité.
- Déploiement : `supabase functions deploy quick-responder`.
