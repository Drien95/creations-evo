# Segunda d'Azeno

Version 27, partagée le 22/11/2026. Fait avec l’Atelier EVO.

Piliers : El Que Queda (Badeni), 1 Azeno, 2 Azrael, 3 Dazan (joué par Adler), 5 Lazlo et 9 Zeno debout ; 4, 6 (Leonne), 7 et 8 brisés.
Le film (film.mp4) date de la version 25 : les piliers 6 et 9 y ont encore leur ancien état.

## Fichiers

- [Le dupe](dupe.txt) : à copier dans `garrysmod/data/advdupe2/`, puis à coller avec Advanced Duplicator 2, sans le tourner.
- [L'addon serveur](atelier_segunda_azeno/) : la scène pour **tous les joueurs** du serveur (lumières, effets, nuit de la salle, sons). Elle se voit et s'entend seulement dans la salle.
- [Le scénario](scenario.md) : toutes les séquences.

## Installer l'addon (staff du serveur)

1. Copier le dossier `atelier_segunda_azeno` dans `garrysmod/addons/` du serveur.
2. Redémarrer le serveur (ou changer de map). La console serveur affiche « scène « atelier_segunda_azeno » chargée côté serveur ».
3. Rien à installer chez les joueurs : le serveur leur envoie le fichier client tout seul.

| Fichier | Où il tourne |
|---|---|
| `lua/autorun/atelier_segunda_azeno.lua` | chargeur : AddCSLuaFile de `sh_config` et `cl_scene`, include des bons fichiers de chaque côté |
| `lua/atelier_segunda_azeno/sh_config.lua` | serveur et clients : qui peut mener la scène |
| `lua/atelier_segunda_azeno/cl_scene.lua` | clients : le rendu de la scène et ses sons |
| `lua/atelier_segunda_azeno/sv_scene.lua` | serveur : l'étape en cours, partagée par tous, et le wipe |

**Qui peut mener la scène** : les admins du serveur (`admins = true`) et les SteamID listés dans `sh_config.lua`. Les autres joueurs voient et entendent seulement.

## Commandes (console, pour qui mène la scène)

| Commande | Effet |
|---|---|
| + du pavé numérique, `atelier_suivant` | étape suivante, chez tout le monde |
| - du pavé numérique, `atelier_precedent` | étape précédente |
| `atelier_etape k` | aller à l'étape k (0 à 6) |
| `atelier_seq_stop` | tout arrêter pour tout le monde, props gardés |
| `atelier_wipe`, deux fois en 10 s | le build aspiré vers son centre chez tous, puis retiré par le serveur |
| `atelier_wipe_sec`, deux fois en 10 s | le build retiré d'un coup |
| `atelier_tuer` | arrêter la scène chez soi seulement, jusqu'à l'étape suivante |
| `atelier_diag` | ce qui est actif, en cas de souci |

Le wipe ne retire que les props aux modèles du build, dans la salle. Avec un prop protect (CPPI), seulement ceux du joueur qui lance le wipe, ou n'importe lesquels pour un admin. Un joueur qui arrive en cours de scène la rejoint où elle en est.
