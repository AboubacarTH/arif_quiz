import 'package:flutter/material.dart';

/// Icône d'un succès, choisie d'après sa **clé** et non d'après l'emoji renvoyé
/// par l'API.
///
/// Le catalogue des succès est figé dans le code du serveur : personne ne le
/// saisit, ce sont des choix de design expédiés depuis le back. Ils n'entrent
/// donc pas dans l'exception « les emoji venus de la base restent » — ils
/// suivent la même règle que le reste de l'app.
///
/// Passer par la clé évite d'avoir à toucher au serveur : elle est stable et
/// déjà transmise. Le champ `emoji` reste dans la réponse, simplement ignoré
/// par ce client.
IconData badgeIcon(String key) => switch (key) {
      'first_steps' => Icons.my_location_rounded,
      'getting_started' => Icons.menu_book_rounded,
      'quiz_master' => Icons.emoji_events_rounded,
      'flawless' => Icons.verified_rounded,
      'streak_7' => Icons.local_fire_department_rounded,
      'streak_30' => Icons.bolt_rounded,
      'veteran' => Icons.military_tech_rounded,
      'point_hunter' => Icons.savings_rounded,
      'challenger' => Icons.sports_kabaddi_rounded,
      'social' => Icons.handshake_rounded,
      // Un succès ajouté côté serveur sans entrée ici reste affichable.
      _ => Icons.workspace_premium_rounded,
    };
