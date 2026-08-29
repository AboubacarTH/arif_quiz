# Connexion Google — mise en service

Le code est en place des deux côtés. Il reste trois choses que seul un accès
aux consoles permet de faire : déclarer l'application auprès de Google,
récupérer l'identifiant client Web, et le donner au serveur.

Tant que ces étapes ne sont pas faites, le bouton s'affiche mais échoue avec
« La connexion Google n'est pas encore configurée pour cette application ».

## 1. Activer Google dans Firebase

Console Firebase → projet **arif-quiz** → *Authentication* → *Sign-in method* →
activer **Google**.

Cette activation crée automatiquement les clients OAuth du projet, dont le
client **Web** dont tout le reste dépend.

## 2. Déclarer les empreintes de signature

Google refuse un jeton demandé par une application qu'il ne reconnaît pas. Il
faut donc lui donner l'empreinte SHA-1 de **chaque** clé qui signe l'APK.

Console Firebase → *Paramètres du projet* → application Android
`com.a2digit.arif_quiz` → *Ajouter une empreinte*.

| Signature | SHA-1 |
| --- | --- |
| Débogage (`~/.android/debug.keystore`) | `DE:6B:F6:61:3B:4C:98:FB:2E:7E:BB:9E:0B:25:7C:DF:5C:C6:19:32` |
| Release (`arif_quiz/arif_quiz.jks`) | `BA:19:7D:30:1B:26:DB:F9:D8:6C:31:FA:86:53:87:99:D0:45:7B:63` |

⚠️ **Deux fichiers `arif_quiz.jks` coexistent, avec le même alias mais des clés
différentes :**

- `C:/FlutterProjects/arif_quiz/arif_quiz.jks` — celui que le build utilise
  (`storeFile=../../arif_quiz.jks` se résout depuis `android/app/`), empreinte
  `BA:19:7D:30:…` ;
- `C:/FlutterProjects/arif_quiz.jks` — inutilisé, empreinte `69:2D:8A:DA:…`.

Lire l'empreinte sur un keystore, c'est parier sur celui que Gradle a choisi.
La seule source qui ne mente pas est **l'APK réellement produit** :

```bash
flutter build apk --release
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

⚠️ **Si l'app passe par la signature d'application Play** (Play App Signing),
Google resigne l'APK avec une clé qui lui appartient : l'empreinte release
ci-dessus ne suffit pas. Ajouter aussi celle affichée dans
Play Console → *Configuration* → *Intégrité de l'application* → *Signature
d'application*. C'est l'oubli qui fait que « ça marche en debug et pas sur le
Play Store ».

La même commande sur `app-debug.apk` donne l'empreinte de débogage, et sur une
APK récupérée d'un téléphone (`adb pull $(adb shell pm path <package>)`) elle
dit avec quelle clé l'application installée a été signée — utile quand une
installation est refusée pour cause de signature.

## 3. Retélécharger `google-services.json`

Toujours dans les paramètres du projet, retélécharger le fichier et remplacer
`android/app/google-services.json`.

Vérifier qu'il contient bien le client Web — c'est **ce** bloc que le plugin
Android va chercher, et son absence est la cause de l'erreur
« serverClientId must be provided on Android » :

```json
"oauth_client": [
  { "client_id": "…apps.googleusercontent.com", "client_type": 3 }
]
```

L'app lit cette valeur toute seule ; il n'y a rien à recopier dans le code Dart.
(Le `--dart-define=GOOGLE_SERVER_CLIENT_ID=…` n'existe que pour le cas où ce
fichier ne la contiendrait pas.)

## 4. Donner le même identifiant au serveur

C'est ce qui permet au backend de rejeter un jeton valide mais émis pour une
autre application. Dans le `.env` du backend, reprendre le `client_id` du bloc
`client_type: 3` ci-dessus :

```env
GOOGLE_CLIENT_ID=123456789-xxxxxxxx.apps.googleusercontent.com
```

Puis `php artisan config:clear`.

Tant que cette variable est vide, `/auth/google` refuse **toutes** les
connexions — c'est délibéré : accepter n'importe quelle audience reviendrait à
laisser n'importe quelle application Google ouvrir des sessions chez nous.

## 5. Migrer la base

```bash
php artisan migrate
```

Ajoute `users.google_id` (unique) et rend `users.password` nullable — un compte
Google n'a pas de mot de passe.

## Vérifier

1. Se connecter avec un compte Google jamais utilisé → compte créé, on entre
   directement dans l'app (pas d'écran de code de vérification : Google a déjà
   validé l'adresse).
2. Se déconnecter, se reconnecter avec le même compte → même compte, mêmes
   points.
3. Créer un compte par mot de passe, puis se connecter avec Google sur la même
   adresse → les deux méthodes ouvrent le même compte.
4. Sur un compte créé via Google, tenter le formulaire mot de passe → message
   « Ce compte a été créé avec Google ».
5. Profil → supprimer le compte : aucun mot de passe n'est demandé sur un
   compte Google.

## Comment ça marche

L'app obtient un **ID token** de Google (un JWT signé) et l'envoie à
`POST /api/v1/auth/google`. Le serveur le vérifie lui-même contre les clés
publiques de Google (`GoogleIdTokenVerifier`, JWKS mis en cache 6 h) : signature,
émetteur, destinataire, expiration, adresse vérifiée. Il ouvre ensuite une
session Sanctum ordinaire.

Google sert à prouver l'identité, pas à la remplacer : le reste de l'API ne
change pas, et un compte Google est un compte comme un autre — avec ses points,
son niveau et ses amis.
