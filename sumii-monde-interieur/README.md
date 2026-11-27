# Monde intérieur de Sumii

Une plaine aux terriers au coucher du soleil, jouée temps par temps par le MJ, qui finit dans une boîte blanche.

| Fichier | Contenu |
|---|---|
| `dupe.txt` | le décor, à coller avec AdvDupe2 (76 props) |
| `sumii_monde_interieur/` | l'addon du script (aucun prop de plus) |
| `COMMANDES.md` | toutes les commandes du MJ |
| `scenario.md` | le déroulé pour mener la scène |
| `film.mp4` | aperçu de 30 s, vu par la joueuse ciblée, au banc d'essai |

## Installation

1. Copier `sumii_monde_interieur/` dans `garrysmod/addons/` du serveur, puis changer de carte.
2. Coller le décor (voir ci-dessous).
3. Dans la console : `sumii_etat` doit répondre « build reconnu à sa disposition ».

## Coller le décor

| Quoi | Consigne |
|---|---|
| Fichier | copier `dupe.txt` dans `garrysmod/data/advdupe2/`, puis le coller avec Advanced Duplicator 2, figé |
| Orientation | **sans le tourner** : un collage tourné n'a pas encore été essayé en jeu |
| Endroit | libre (aucune coordonnée de carte dans le script), sur un sol plat |
| Place | une boîte ronde de 4 800 u de large et 1 600 u de haut autour de la plaque centrale |
| Nombre | un seul exemplaire du décor sur la carte |

**Modèles :** ceux du dupe (addons EVO) et le lapin `models/compagnons/rabbit.mdl`. **Sons :** ceux du jeu de base.
**Droits :** admins et SteamID listés dans `lua/sumii_mi/sh_config.lua` (`MJ`).

## Commandes

Tout se tape dans la console. « MJ » : les admins et la liste `MJ`. Rien ne s'affiche à l'écran des joueurs.
`COMMANDES.md` les range par moment de la scène.

| Commande | Arguments | Qui | Effet | Exemple |
|---|---|---|---|---|
| `sumii_etat` | aucun | MJ | vérifie que le build est reconnu ; temps en cours, cible, terriers fouillés | `sumii_etat` |
| `sumii_ancre` | aucun | MJ | secours : désigne la plaque centrale visée (à travers les rochers) ; sans la viser, retour à la détection | `sumii_ancre` |
| `sumii_cible` | nom ou SteamID (facultatif) | MJ | désigne Sumii ; sans argument, le joueur visé | `sumii_cible STEAM_0:0:1` |
| `sumii_arrancar` | nom ou SteamID (facultatif) | MJ | désigne le joueur de l'Arrancar | `sumii_arrancar Nom` |
| `sumii_pov` | aucun | MJ | ouvre ou ferme la petite vue de Sumii dans un coin | `sumii_pov` |
| `sumii_points` | aucun | MJ | donne les `setpos` d'arrivée et de sortie | `sumii_points` |
| `sumii_suite` | aucun | MJ | lance le temps suivant | `sumii_suite` |
| `sumii_retour` | aucun | MJ | annule le temps en cours | `sumii_retour` |
| `sumii_lancer` | aucun | MJ | temps : l'arrivée | `sumii_lancer` |
| `sumii_fouiller` | terrier 1 à 12 ; vide, bruit ou rien | MJ | fouille un terrier ; sans numéro, le terrier visé | `sumii_fouiller 3 bruit` |
| `sumii_detresse` | aucun | MJ | temps : la détresse | `sumii_detresse` |
| `sumii_reveler` | terrier 1 à 12 (facultatif) | MJ | temps : yeux et oreilles dans un terrier (visé, sinon 7) | `sumii_reveler 7` |
| `sumii_voix` | aucun | MJ | temps répétable : les yeux pulsent | `sumii_voix` |
| `sumii_nom` | aucun | MJ | temps : le nom | `sumii_nom` |
| `sumii_souvenirs` | aucun | MJ | temps : le ciel vire au rouge | `sumii_souvenirs` |
| `sumii_flash` | 1, 2 ou 3 | MJ | temps : les trois éclats | `sumii_flash 1` |
| `sumii_devore` | aucun | MJ | temps : la scène du lapin | `sumii_devore` |
| `sumii_regard` | aucun | MJ | temps : le regard | `sumii_regard` |
| `sumii_course` | aucun | MJ | temps : la course | `sumii_course` |
| `sumii_plaquer` | aucun | MJ | temps : le plaquage, Sumii gelée 6 s | `sumii_plaquer` |
| `sumii_fumee` | aucun | MJ | temps : l'Arrancar disparaît | `sumii_fumee` |
| `sumii_perte` | aucun | MJ | temps : la perte de contrôle | `sumii_perte` |
| `sumii_effondrement` | aucun | MJ | temps : l'effondrement et la boîte blanche | `sumii_effondrement` |
| `sumii_apercu` | detresse, souvenirs, flash3, regard, course, plaquage ou perte | MJ | joue chez soi seul un effet prévu pour Sumii | `sumii_apercu plaquage` |
| `sumii_numeros` | aucun | MJ | affiche ou masque les numéros des terriers, chez soi seul | `sumii_numeros` |
| `sumii_ici` | aucun | MJ | donne le numéro du terrier visé | `sumii_ici` |
| `sumii_reconstruire` | aucun | MJ | remet la scène au début, sans rien retirer | `sumii_reconstruire` |
| `sumii_tout_effacer` | (à taper deux fois en 10 s) | MJ | retire les 76 props du build et éteint la scène chez tous | `sumii_tout_effacer` |
| `sumii_diag` | aucun | tous | dit si le build est trouvé et si les effets sont actifs | `sumii_diag` |
| `sumii_mesure` | aucun | tous | coût du script chez soi, en ms par image, depuis le dernier appel | `sumii_mesure` |

## Si quelque chose ne va pas

| Ce que dit la console, ou ce que tu vois | Que faire |
|---|---|
| « aucun build reconnu (voir sumii_ancre) » | vérifier que le décor est entier et collé sans rotation ; en secours, viser le sol de la plaque centrale et taper `sumii_ancre` |
| « réservé au MJ » | être admin ou dans la liste `MJ` ; pour `sumii_pov`, `sumii_apercu` et `sumii_numeros`, taper d'abord `sumii_etat` |
| « rien n'est lancé : … » | la suite de la ligne dit pourquoi ; désigner Sumii avec `sumii_cible` |
| Aucun effet chez un joueur | il doit être dans la boîte ; `sumii_diag` dans sa console doit dire « repère trouvé » |
| Modèles remplacés par « ERROR » | il manque un addon EVO du décor, ou le modèle du lapin |
| Ralentissements | taper `sumii_mesure`, attendre quelques secondes, la retaper : la seconde réponse donne le coût |

## Code

`lua/autorun/sumii_mi_init.lua` charge `lua/sumii_mi/` :

| Préfixe | Rôle |
|---|---|
| `sv_` | serveur : état de la scène, commandes, retrait du build (`sv_plan.lua`) |
| `sh_` | partagé : réglages, reconnaissance du build, calculs de chaque temps |
| `cl_` | client : décor et effets |

## Retirer

`sumii_reconstruire` remet la scène au début. `sumii_tout_effacer`, tapé deux fois en moins de 10 s, retire les
76 props du build et éteint tout chez tous les joueurs.

## Bind suggéré

Aucune touche n'est imposée. Exemple : `bind <touche> sumii_suite`.

## Essais

Au banc (serveur local à 2 places, le second joueur étant un bot) : les 16 temps enchaînés avec `sumii_suite`,
la vue de Sumii chez le MJ, la désignation des joueurs, le retrait du build puis un nouveau collage.

**Pas encore prouvé :** deux vrais joueurs, les accessoires EVO sur les joueurs, un autre addon qui prend la
caméra (`CalcView`). **Fluidité :** le script coûte en moyenne 2 à 3 ms par image au banc (environ 6 ms pendant
l'effondrement, 1,6 ms de plus chez le MJ avec `sumii_pov`), avec des à-coups à la construction du décor.
