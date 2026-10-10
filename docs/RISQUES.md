# Risques et mesures

| Risque | Impact | Mesure retenue |
| --- | --- | --- |
| Reconnaissance photo imparfaite (produits empilés, emballages, légumes similaires) | L'utilisateur abandonne | Photo = aide à la saisie ; écran de confirmation rapide avec puces |
| Coût de l'API de vision à grande échelle | Dépassement du budget | Limite de photos gratuites par jour |
| Pas de prix fiables pour la Tunisie dans Open Food Facts ou USDA | Coûts estimés faux | Table de prix moyens maintenue à la main, affichée comme « estimation » |
| Qualité variable des recettes générées par IA | Perte de confiance | Base de recettes vérifiées d'abord |
| Applications « recettes avec ce que j'ai » déjà existantes | Peu de différenciation | Angle budget + cuisines du monde + marché local, focus Tunisie et Maghreb |
| Vouloir tout faire avant de valider | Retard, abandon | Périmètre V1 strict ; tests avec 5 à 10 personnes avant d'élargir |
| Clé API exposée dans l'application | Fuite et facturation | Clé uniquement dans une Edge Function |

## Critère de décision

Si les testeurs trouvent le parcours sans photo utile, on ajoute la photo. Si la détection photo reste trop faible, on conserve la saisie manuelle comme parcours principal.
