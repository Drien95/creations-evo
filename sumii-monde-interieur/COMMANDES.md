# Monde intérieur de Sumii : commandes du MJ

Tout se tape dans la console. Rien ne s'affiche à l'écran des joueurs. Les commandes sont réservées aux admins
et à la liste MJ (`sumii_mi/sh_config.lua`).

## Avant la scène (une fois)

| Commande | Effet |
|---|---|
| `sumii_etat` | vérifie que le build est reconnu ; affiche le temps en cours, la cible et les terriers fouillés |
| `sumii_ancre` | secours seulement : si le build n'est pas reconnu, vise le sol de la plaque centrale puis tape-la (le rayon traverse les rochers posés dessus) ; sans rien viser, elle revient à la détection automatique |
| `sumii_cible` | désigne Sumii : vise-la puis tape la commande (aussi : un bout de son nom, ou son SteamID) |
| `sumii_arrancar` | désigne le joueur de l'Arrancar, de la même façon |
| `sumii_pov` | ouvre ou ferme la petite vue de Sumii dans un coin de ton écran |
| `sumii_points` | donne les `setpos` d'arrivée et de sortie |

Sans cible désignée, le script prend le seul joueur de la boîte qui n'est ni MJ, ni admin, ni l'Arrancar.
S'il y en a plusieurs, il ne lance rien et le dit. Si Sumii se reconnecte, il faut la redésigner.

**Comment le build est reconnu :** à la disposition de ses props, jamais à leur couleur. Il faut la plaque du
centre, au moins 3 de ses 4 voisines et au moins 2 des 3 cerisiers à leur place. Le build peut être collé
n'importe où et tourné. Un autre build avec les mêmes plaques n'est pas pris.

## Les temps, dans l'ordre

`sumii_suite` lance le temps suivant. `sumii_retour` annule le temps en cours. Chaque temps a aussi sa commande.

| Temps | Commande | Ce qui se passe |
|---|---|---|
| 1 Arrivée | `sumii_lancer` | l'herbe s'éveille, le soleil sort d'un nuage, papillons, vent et oiseaux |
| 2 Fouille (à tout moment) | `sumii_fouiller <n°> <vide, bruit ou rien>` | terre qui gicle ; « bruit » : une touffe frémit près d'un autre terrier |
| 3 Détresse | `sumii_detresse` | nuage et tas de terre autour d'elle, vent à moitié |
| 4 Révélation | `sumii_reveler <n°>` (7 par défaut) | silence, lumière en baisse, yeux et oreilles au fond du trou |
| 4 bis Voix (répétable) | `sumii_voix` | les yeux pulsent, grondement ; tu écris la réplique |
| 5 Le nom | `sumii_nom` | une fine onde rouge, un coup sourd |
| 6 Souvenirs | `sumii_souvenirs` puis `sumii_flash 1`, `2`, `3` | ciel rouge ; ombre géante, couteau sur le soleil, blanc |
| 6 bis Dévore | `sumii_devore` | le lapin, les poils, la tache ; l'Arrancar est un joueur |
| 6 ter Regard | `sumii_regard` | silence, cœur lent chez Sumii |
| 6 quater Course | `sumii_course` | le cœur s'emballe, l'herbe vole sous ses pas |
| Plaquage | `sumii_plaquer` | Sumii gelée 6 s : vue au sol, ombre, lame, entailles, noir |
| Fumée | `sumii_fumee` | l'Arrancar disparaît dans la fumée noire |
| 7 Perte de contrôle | `sumii_perte` | rafales, forêt pliée, terriers en chaîne, vertige chez Sumii |
| 8 Effondrement | `sumii_effondrement` | le ciel se fend, tout s'enfonce, boîte blanche |

**Fin de scène :** Sumii reste dans la boîte blanche. Le MJ la téléporte hors de la boîte. C'est fini.

## Outils

| Commande | Effet |
|---|---|
| `sumii_apercu <clé>` | joue chez toi seul un effet prévu pour Sumii : `detresse`, `souvenirs`, `flash3`, `regard`, `course`, `plaquage`, `perte` |
| `sumii_numeros` | numéros des terriers, visibles de toi seul |
| `sumii_ici` | dit le numéro du terrier visé (`sumii_fouiller` et `sumii_reveler` sans numéro prennent aussi le terrier visé) |
| `sumii_diag` | dit si le build est trouvé et si les effets sont actifs |
| `sumii_mesure` | coût du script en millisecondes par image depuis le dernier appel |

## Après la scène

| Commande | Effet |
|---|---|
| `sumii_reconstruire` | remet la scène au début (décor intact) sans rien retirer ; ne fait pas partie de la scène |
| `sumii_tout_effacer` (à taper deux fois en moins de 10 s) | retire les 76 props du build et éteint tous les effets, sons et scripts de la scène chez tout le monde |

Touches : aucune n'est imposée. Pour en choisir une : `bind <touche> sumii_suite`.
