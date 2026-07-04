# 🧪 Checklist de test on-device — ArifQuiz

Vérification manuelle de tout ce qui a été livré pendant l'audit (lots a/b/c).
Tout a été validé statiquement (`dart analyze` / `php -l`), par tests unitaires (14 verts)
et par exécution backend — mais **aucune vérification runtime sur appareil** n'a été faite.
Cette liste couvre ce qui reste à confirmer sur un vrai device/émulateur.

Format : **comment tester** → **résultat attendu**. Coche `[x]` au fur et à mesure.

---

## 0. Prérequis / setup
- [ ] Backend lancé (local ou prod). Pour pointer en local :
      `flutter run --dart-define=USE_LOCAL_API=true --dart-define=LOCAL_API_URL=http://<ip-hôte>:8000/api/v1`
- [ ] Jeu de données : **1 quiz publié avec ≥ 20 questions** (pour tester le count), quelques
      quiz, **1 défi du jour** (`daily_challenges`), **2 comptes** de test (amis/défis)
- [ ] Tester chaque écran en **thème clair ET sombre** (Profil → Apparence)

## Lot (a) — Correctifs
- [ ] **Révélation réponse** (Classique/Speed/Survie) : répondre **faux** → la bonne option
      passe **verte** + ton choix **rouge**. Laisser le **timer expirer** → la bonne réponse est
      aussi révélée. *(comportement nouveau au timeout)*
- [ ] **Cohérence casse** : le verdict en jeu = le verdict de l'écran résultat
- [ ] **Confirmation quitter** : bouton ✕ **et** geste retour en Classique/Speed/Survie → dialog
      « Quitter la partie ? ». En **Game Over** (survie), le retour quitte **sans** dialog
- [ ] **Texte Game Over survie** : mourir Q1 → « survécu à **0** question » (singulier) ;
      mourir Q3 → « **3** questions » (pluriel)
- [ ] **Throttle auth** : > 10 tentatives de login/min → **429**
- [ ] **play_count** : terminer un quiz → `play_count` +1 ; charger puis abandonner → pas d'incrément

## Lot (b) — Robustesse
- [ ] **Playthrough complet des 4 modes** (Classique, Speed, Survie, **Défi quotidien**) : timer,
      auto-avance, **Skip** (classique, avance sans double-saut), Game Over (survie), soumission →
      écran résultat. *(cœur du refactor `GamePlayController` — surveiller tout décalage de timing)*
- [ ] **401 global** : invalider le token (révoquer/supprimer en DB) puis déclencher une action
      connectée → **redirection auto vers Login**. Un **mauvais mot de passe au login** ne doit
      **pas** effacer le formulaire (pas de redirection parasite)
- [ ] **Flavors** : avec `USE_LOCAL_API=true` → backend local ; sans → prod
- [ ] **Sessions (anti-triche)** : une partie Classique/Speed normale se soumet et **score
      correctement** (le `session_id` circule questions→submit)
- [ ] **Mode invité** : scoring **local** correct, pas d'appel serveur

## Lot (c) — Fonctionnalités
- [ ] **Partage riche** : écran résultat → **« Partager mon score »** → sélecteur système avec une
      **image PNG** nette (grade/score/quiz, branding). Vérifier en clair ET sombre (la carte a une
      palette fixe ivoire — normal)
- [ ] **Revanche 1-tap** : terminer un défi → détail → **« Revanche »** → nouveau défi + navigation ;
      l'**adversaire reçoit une invitation** (notif in-app)
- [ ] **Succès/Badges** : Profil → **Succès** → grille verrouillés/débloqués + progression. Jouer
      1 quiz → **first_steps** débloqué. Faire 100 % → **flawless**
- [ ] **Mode entraînement** : quiz → Choisir le mode → **« Mode entraînement »** → choisir **15** →
      jouer **15 questions** → bannière entraînement sur le résultat. **Noter XP/points/quiz joués
      AVANT/APRÈS** dans le Profil → **inchangés** (0 impact)
- [ ] **Classement amis (Home)** : avec ≥ 1 ami → section top 5, **ta ligne surlignée**, tri par
      points. Avec **0 ami** → section **absente**
- [ ] **Rappel défi du jour** : défi du jour existant, puis `php artisan quiz:daily-reminder` → les
      joueurs actifs n'ayant pas joué reçoivent une **notif in-app** (écran Notifications)

## Points transverses
- [ ] **Clair/sombre** OK sur : Succès, sheet entraînement, classement amis, dialogs
- [ ] **Pas de débordement** (overflow) sur la grille de badges et les lignes du classement
- [ ] **États vides** : profil sans amis (classement caché), badges tous verrouillés (nouveau compte)

## ⛔ Hors périmètre (nécessite infra Firebase)
Push **système** réel du défi du jour. Requiert :
1. Projet Firebase + `service-account.json` → env `FCM_PROJECT_ID` / `FCM_CREDENTIALS`
2. Intégrer `firebase_messaging` côté Flutter (permissions, token → `updateFcmToken`, handler)
