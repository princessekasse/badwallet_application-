# BadWallet Consumer Application

Application mobile Flutter développée dans le cadre de l'examen L3 S2 2026.

##  Fonctionnalités implémentées
- **Authentification** sécurisée par numéro de téléphone avec stockage persistant (`flutter_secure_storage`).
- **Tableau de bord** complet affichant le solde masquable (icône œil) et les 5 dernières transactions.
- **Gestion des transferts** d'argent vers d'autres portefeuilles.
- **Paiement de factures groupé** (SENELEC, WOYAFAL, RAPIDO, ISM) via un système de sélection multiple (Checkboxes).
- **Historique complet** des transactions avec code couleur strict (Vert pour les crédits, Rouge pour les débits).

##  Architecture & Technologies
- Structure **Feature-First** pour une meilleure modularité.
- Gestion d'état robuste avec **Provider** (États gérés : `loading`, `loaded`, `error`).
- Design moderne basé sur la police **Poppins** via `google_fonts`.

##  Installation
1. Exécuter `flutter pub get` pour installer les dépendances.
2. S'assurer que le backend BadWallet est actif.
3. Lancer l'application sur un émulateur Android (Base URL configurée sur `10.0.2.2:8080`).