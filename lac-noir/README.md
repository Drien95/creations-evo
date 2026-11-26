# Lac noir de Nobleza

Partagé le 26/11/2026. Fait avec l’Atelier EVO. Map : Hueco Mundo, zone de build.

Un lac noir endormi autour d'une île, une épée plantée devant un trône, une cathédrale brisée au fond. Quatre cloches,
une éclipse totale, puis le boum : l'onde part du pied de l'épée et allume tout sur son passage.

## Fichiers

- [Le dupe](dupe.txt) : 226 props. À copier dans `garrysmod/data/advdupe2/`, puis à coller avec Advanced Duplicator 2, figé, sans le tourner.
- [L'addon serveur](lac_noir_hueco/) : la scène pour **tous les joueurs** du serveur (effets, nuit, brume, sons). Elle se voit et s'entend seulement dans la zone de la scène.
- [Le scénario](scenario.md) : les 9 séquences.

## Où coller le dupe

| Quoi | Valeur |
|---|---|
| Repère de l'île (ancre de collage) | x -11 240, y -12 938, z 14 043 |
| Sol | le sable de la zone de build (z 13 952) |

Aucun prop ne traverse le sable (vérifié sur la géométrie de la map).

## Installer l'addon (staff du serveur)

1. Copier le dossier `lac_noir_hueco` dans `garrysmod/addons/` du serveur.
2. Redémarrer le serveur (ou changer de map). L'addon ne charge rien sur une map dont le nom ne contient pas « hueco ».
3. Rien à installer chez les joueurs : le serveur leur envoie le script client et les deux sons de cloche tout seul.

| Fichier | Où il tourne |
|---|---|
| `lua/autorun/lac_noir_init.lua` | chargeur : vérifie la map, AddCSLuaFile de `sh_config` et `cl_scene`, include des bons fichiers de chaque côté |
| `lua/lac_noir/sh_config.lua` | serveur et clients : qui peut mener la scène, nom du message réseau, liste des séquences |
| `lua/lac_noir/cl_scene.lua` | clients : le rendu de la scène et ses sons |
| `lua/lac_noir/sv_lancement.lua` | serveur : la séquence en cours, partagée par tous, et les joueurs qui arrivent en cours |
| `lua/lac_noir/sv_sons.lua` | serveur : envoi des sons de cloche (`sound/lac_noir/`) |

**Qui peut mener la scène** : les admins du serveur (`ADMINS = true`) et les SteamID listés dans `sh_config.lua`. Les autres joueurs voient et entendent seulement.

## Commandes (pour qui mène la scène)

| Commande | Effet |
|---|---|
| `lac_noir_suite` | séquence suivante, chez tout le monde (la 1 au départ) |
| `lac_noir_precedente` | séquence précédente (elle repart de son début) |
| `lac_noir_sequence N` | aller à la séquence N (1 à 9) |
| `lac_noir_arreter` | tout arrêter pour tout le monde |
| `lac_eau_stop` | (chaque joueur) couper la scène chez soi seulement |

Pour mener la scène sans ouvrir la console, chacun lie les touches qu'il veut, par exemple :
`bind KP_PLUS lac_noir_suite` et `bind KP_MINUS lac_noir_precedente`.

Chaque séquence joue puis tient sa dernière image jusqu'à la suivante. Un joueur qui arrive ou qui entre dans la zone
reprend la séquence en cours.

## Performance

Mesuré sur toute la scène (9 séquences d'affilée) : 17,8 ms par image en moyenne, 1 % des pires images à 38 ms.
