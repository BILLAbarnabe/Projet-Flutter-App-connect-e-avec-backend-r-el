# Carnet Connecté

Application Flutter mobile en français, connectée à une API REST Supabase.
Elle réunit une authentification e-mail/mot de passe, trois espaces de contenu
(articles, livres et tâches) et un cache SQLite consultable hors ligne.

## Fonctionnalités

- Inscription, connexion et déconnexion via Supabase Auth.
- Trois écrans REST alimentés par les tables `articles`, `books` et `tasks`.
- Injection de la clé publique Supabase et du JWT par un intercepteur Dio.
- Renouvellement de session et nouvelle tentative unique lorsqu'une réponse REST
  renvoie `401`.
- Cache SQLite local, séparé par écran ; les dernières données enregistrées
  restent visibles hors connexion.
- Messages d'erreur compréhensibles et bouton de nouvelle tentative.
- Quatre tests unitaires du repository de contenu.

## Architecture

Le code suit une architecture en couches :

```text
lib/
  core/                 Configuration et erreurs partagées
  data/
    auth/               Adaptateur Supabase Auth
    local/              Contrat du cache et implémentation SQLite
    remote/             Client REST Dio, intercepteur JWT et API Supabase
    repositories/       Coordination distant/cache
  domain/
    entities/           Modèle et sections de contenu
    repositories/       Contrats des repositories
  presentation/
    login/              Connexion et création de compte
    home/               Navigation entre les trois écrans
    content/            États de chargement, erreur, hors ligne et résultats
```

Le repository tente d'abord l'API REST. En cas d'erreur réseau Dio, il restitue
le cache de la section concernée ; sans cache, il transmet une erreur destinée à
l'utilisateur. Le cache utilise une base SQLite locale avec transactions.

## Backend Supabase

1. Créez un projet sur [Supabase](https://supabase.com/).
2. Dans **SQL Editor**, exécutez [`supabase/schema.sql`](supabase/schema.sql).
   Le script crée les trois tables, leurs politiques de lecture RLS et quelques
   lignes de démonstration.
3. Dans les paramètres du projet, copiez **Project URL** et la clé publique
   **anon** (ou **publishable** si votre projet fournit ce format compatible).
   Ne mettez jamais une clé `service_role` dans l'application.
4. Activez le fournisseur **Email** dans les paramètres Authentication.
   Pour tester immédiatement l'inscription, désactivez la confirmation d'e-mail
   dans un environnement de développement ; sinon, l'utilisateur doit confirmer
   son adresse avant de pouvoir se connecter.

Les tables de démonstration sont partagées entre les utilisateurs authentifiés
et accessibles en lecture seule. Les politiques RLS interdisent l'accès anonyme.
Pour des données personnelles, remplacez ces politiques par des politiques
basées sur `auth.uid()` avant la mise en production.

## Prérequis et lancement

- Flutter stable (Dart inclus)
- Un projet Supabase configuré comme ci-dessus
- Android Studio/SDK pour Android ou Xcode pour iOS

Récupérez les dépendances et lancez depuis la racine :

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://VOTRE-PROJET.supabase.co --dart-define=SUPABASE_ANON_KEY=VOTRE-CLE-PUBLIQUE
```

Les mêmes variables peuvent être fournies dans la configuration de lancement de
l'IDE. Sans configuration, l'application affiche un écran indiquant comment
connecter Supabase. Les identifiants ne sont pas enregistrés dans le dépôt.

## Tests et analyse

```powershell
flutter test
flutter analyze
```

Les tests du repository couvrent le chargement distant et l'écriture en cache,
le repli hors ligne, l'erreur réseau sans données en cache et la remontée d'une
erreur SQLite.
