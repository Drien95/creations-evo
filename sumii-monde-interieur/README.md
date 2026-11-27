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
2. Coller `dupe.txt` avec AdvDupe2. Le build peut être posé n'importe où et tourné.
3. Dans la console : `sumii_etat` doit répondre « build reconnu à sa disposition ».

**Modèles :** ceux du dupe (addons EVO) et le lapin `models/compagnons/rabbit.mdl`. **Sons :** ceux du jeu de base.
**Place :** une boîte ronde de 4 800 u de large et 1 600 u de haut autour de la plaque centrale.
**Droits :** admins et SteamID listés dans `lua/sumii_mi/sh_config.lua` (`MJ`).

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
