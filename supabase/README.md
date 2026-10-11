# Backend Supabase

| Dossier | Contenu |
| --- | --- |
| `sql/` | Scripts SQL initiaux : `01_schema.sql` (tables), `02_ingredients.sql` (ingrédients), `03_recipes.sql` (recettes). À exécuter dans l'ordre, dans Supabase > SQL Editor. |
| `functions/quick-responder/` | Edge Function de détection d'ingrédients par photo (Gemini, offre gratuite). Appelée par l'app Flutter. |

## Notes

- Le secret `GEMINI_API_KEY` se configure dans Supabase (Edge Functions > Secrets). Il ne doit jamais être commité.
- Déploiement de la fonction : `supabase functions deploy quick-responder`.
- L'app lit aussi les colonnes `cost_dt` (recettes) et `translations` (jsonb, recettes et ingrédients). Elles ne figurent pas encore dans `sql/01_schema.sql` : le schéma versionné ici est la V1 initiale, à compléter avec une migration.
