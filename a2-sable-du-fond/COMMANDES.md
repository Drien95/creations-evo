# A2 · Le Sable du Fond · toutes les commandes

À taper dans la console (touche `²` ou `~`), ou à lier à une touche : `bind KP_PLUS a2_suivante`.

**Qui peut les taper**
- **MJ** : les admins du serveur et les SteamID listés dans `sh_config.lua`. C'est le serveur qui vérifie : chez un autre joueur, la commande ne fait rien.
- **Joueur** : n'importe qui, et seulement chez lui. Ces commandes ne changent rien pour les autres.

Une **cible** est `tous`, un numéro de place (`1` à `4`) ou le nom d'un joueur placé avec `a2_place` (une partie du nom suffit).
Tout s'écrit en console seulement (celle de qui tape la commande, et celle du serveur) : aucun message à l'écran, ni chat, ni notification.

## Mener la scène (MJ)

| Commande | Arguments | Ce qu'elle fait | Exemple |
|---|---|---|---|
| `a2_place` | `<joueur> <1-4>` | Met un apprenti à une place, pour le viser ensuite par son nom. | `a2_place Ethan 2` |
| `a2_pierres` | `<cible> <on\|off>` | Pose ou retire les deux pierres blanches et le pouls de la place. | `a2_pierres tous on` |
| `a2_signature` | `<cible> <r> <g> <b>` | Couleur du pouls de la place. Par défaut : braise, améthyste, jade, grenat. | `a2_signature 2 120 60 200` |
| `a2_lancer` | aucun | Première vague : le compte des vagues repart de 1. Refusée si aucun build n'est repéré. | `a2_lancer` |
| `a2_suivante` | aucun | Vague suivante, plus forte. À partir de la 2e, le fil d'Injerto se tend et s'éclaire un instant. | `a2_suivante` |
| `a2_resultat` | `<cible> <crit\|reussite\|partiel\|echec\|fiasco>` | Les pierres jouent le résultat. Peut être rejouée autant de fois qu'on veut. | `a2_resultat Ethan partiel` |
| `a2_adler` | `[joueur]` | Le fil d'Injerto suit ce joueur. Sans nom : au centre de la dalle. | `a2_adler Adrien` |
| `a2_effacer` | aucun | Remet la **séquence** à zéro pour tous : vagues, pierres, résultats, signatures, fil. Le build et le décor restent. | `a2_effacer` |

**Résultats** : `crit`, les pierres lévitent d'un doigt et restent en l'air ; `reussite`, elles restent immobiles ; `partiel`, l'une glisse dans le sable ; `echec`, les deux glissent et s'enfoncent ; `fiasco`, elles éclatent.

## Le build (MJ)

| Commande | Arguments | Ce qu'elle fait | Exemple |
|---|---|---|---|
| `a2_etat` | aucun | Affiche l'état : vagues, fil, places, résultats, ancre (gravure n/3), builds reconnus. Après `a2_tout_effacer`, elle réveille aussi l'addon. | `a2_etat` |
| `a2_ancre` | aucun, en visant le build | Désigne ce build comme celui de la scène (utile s'il y en a deux, ou si ni la gravure ni le motif ne sont reconnus : viser la plaque 5x5 du sol au coin du build). | `a2_ancre` |
| `a2_ancre auto` | `auto` | Rend la main à la recherche automatique (gravure, puis motif). | `a2_ancre auto` |
| `a2_tout_effacer` | aucun, **deux fois en 10 s** | **Efface tout** : les 79 props du build repéré (les 3 marques de gravure comprises), l'état et le relais du serveur, et chez tous les joueurs les effets, les modèles, le sable, les dunes, la brume, la nuit et les hooks de dessin. Les autres builds, même dans la zone, ne sont pas touchés. | `a2_tout_effacer` puis `a2_tout_effacer` |
| `a2_retirer` | aucun, deux fois en 10 s | Ancien nom de `a2_tout_effacer`, même effet. | `a2_retirer` |

Après `a2_tout_effacer`, l'addon dort : aucun hook ni timer A2 ne tourne, ni sur le serveur ni chez les joueurs. Pour rejouer, il faut recoller le build et taper une commande MJ (`a2_etat` suffit) : le serveur retrouve le build et la scène se rallume chez tous.

Avec un prop protect (CPPI), `a2_tout_effacer` retire les props de qui la tape, ou tous pour un admin ; le message dit combien ont été gardés.

## Diagnostic (joueur, chez soi)

| Commande | Ce qu'elle affiche |
|---|---|
| `a2_diag` | Addon chargé et map acceptée ; scène allumée (hooks A2 actifs n/28) ou « aucun build, rien d'actif » ; ancre reçue du serveur ; gravure vue autour de l'ancre (n/3) ; plaques 5x5 vues ; dans la boîte ou non ; dernier état reçu. |

## Réglages d'affichage (joueur, chez soi, pour tester)

Ils ne changent que l'affichage de qui les tape et reviennent par défaut au changement de map.

| Commande | Arguments | Ce qu'elle fait |
|---|---|---|
| `a2_fermeture` | `<0\|1>` | Éteint ou rallume la fermeture : nuit, faisceau, brume, ciel. |
| `a2_fermeture_brouillard` | `<debut> <opaque>` | Distances du brouillard (u). |
| `a2_fermeture_masquer` | `<0\|1>` | Masque les props de collision du sol. |
| `a2_fermeture_mesure` | aucun | Temps de dessin de la fermeture. |
| `a2_sable` | `<0..n>` | Matière du sable (0 : sable en script éteint). |
| `a2_sable_rides` | `<0\|1>` | Rides du sable. |
| `a2_sable_nuit` | `<0\|1>` | Sable de nuit (1, par défaut) ou de jour. |
| `a2_sable_copies` | `<décalages…>` | Copies décalées du sable, pour comparer (essais). |
| `a2_sable_mesure` | aucun | Temps de dessin du sable. |
| `a2_dunes` | `<0\|1>` | Éteint ou rallume les dunes lointaines. |

## Trois commandes d'effacement, trois effets

| Commande | Séquence (vagues, pierres, résultats) | Build (props) | Décor en script (sable, dunes, nuit, brume) | Hooks et timers A2 |
|---|---|---|---|---|
| `a2_effacer` | remise à zéro | reste | reste allumé | restent |
| `a2_tout_effacer` | remise à zéro | **retiré** (seulement ce build, gravure comprise) | **éteint et vidé chez tous** | **retirés** (serveur et clients) jusqu'au prochain build |
| `a2_retirer` | identique à `a2_tout_effacer` (ancien nom) | | | |
