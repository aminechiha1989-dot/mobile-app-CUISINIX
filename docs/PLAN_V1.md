# Plan de la V1

Durée estimée : 6 à 8 semaines, à un rythme raisonnable pour une personne seule assistée de Claude.

## Étape 0 : Préparer l'environnement (1 à 2 jours)
- [ ] Installer Flutter, Android Studio (émulateur) et VS Code
- [ ] Créer le dépôt GitHub `mobile-app-cuisinix`
- [ ] Créer un projet Supabase gratuit
- [ ] Vérifier que `flutter doctor` ne montre aucune erreur

## Étape 1 : Figer le périmètre de la V1 (1 jour)
- [ ] Valider la liste des fonctionnalités de [CAHIER_DES_CHARGES.md](CAHIER_DES_CHARGES.md)

## Étape 2 : Dessiner les écrans (2 à 3 jours)
- [ ] Croquis ou maquettes Figma des 5 écrans décrits dans [ECRANS.md](ECRANS.md)

## Étape 3 : Concevoir la base de données (1 à 2 jours)
- [ ] Exécuter le schéma de [BASE_DE_DONNEES.md](BASE_DE_DONNEES.md) dans Supabase
- [ ] Saisir 50 ingrédients courants
- [ ] Saisir 30 à 50 recettes tunisiennes et maghrébines vérifiées

## Étape 4 : Créer l'app Flutter (3 à 4 jours)
- [ ] Créer le projet dans `app/`
- [ ] Navigation entre les 5 écrans
- [ ] Connexion à Supabase
- [ ] Affichage de données de test

## Étape 5 : Parcours sans photo (1 à 2 semaines)
- [ ] Saisie manuelle avec recherche d'ingrédients
- [ ] Algorithme de correspondance (présents, manquants, coût manquant)
- [ ] Filtres : budget (le budget 0 ne garde que les recettes sans manquants), repas, cuisine
- [ ] Tri par meilleur taux de correspondance

## Étape 6 : Ajouter la photo (1 à 2 semaines)
- [ ] Capture avec la caméra
- [ ] Supabase Edge Function appelant l'API de vision (clé jamais dans l'app)
- [ ] Correspondance avec la table `ingredients`
- [ ] Écran de confirmation avec puces à supprimer ou ajouter
- [ ] Limite de photos gratuites par jour

## Étape 7 : Comptes et favoris (2 à 3 jours)
- [ ] Utilisation sans compte
- [ ] Inscription (Supabase Auth) seulement pour les favoris

## Étape 8 : Tests (1 semaine)
- [ ] Test sur un vrai téléphone Android
- [ ] 5 à 10 personnes observées sans guidage
- [ ] Liste des blocages (ingrédients mal reconnus, recettes absentes, prix irréalistes)
- [ ] Corrections et second tour

## Étape 9 : Diffusion limitée
- [ ] APK ou tests internes Google Play (compte développeur : 25 $, une seule fois)
- [ ] Partage à 20 personnes, mesure des retours après deux utilisations

## Méthode de travail

- Une étape à la fois ; tester avant de passer à la suivante.
- Donner à Claude le message d'erreur complet en cas de plantage.
- Commit sur GitHub après chaque étape qui fonctionne.
