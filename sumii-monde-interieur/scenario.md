# Mener la scène

Tout se tape dans la console. Les durées sont celles des effets : le MJ lance chaque temps quand le jeu de rôle
s'y prête. La dernière image de chaque temps reste.

## Avant

1. Coller le build, puis `sumii_etat`.
2. Désigner la joueuse : la viser puis `sumii_cible`. Désigner l'Arrancar : le viser puis `sumii_arrancar`.
3. Au besoin, `sumii_pov` pour voir ce qu'elle voit.

## Déroulé (`sumii_suite` enchaîne dans cet ordre)

| Temps | Effet | Durée |
|---|---|---|
| Arrivée | la plaine s'éveille | 20 s |
| Détresse | la terre vole autour d'elle | 6 s |
| Révélation | des yeux et des oreilles au fond d'un terrier (7 par défaut) | 12 s |
| Voix (répétable) | les yeux pulsent ; le MJ écrit la réplique | 3 s |
| Le nom | onde rouge, coup sourd | 6 s |
| Souvenirs | le ciel vire au rouge | 30 s |
| Éclats 1, 2, 3 | ombre géante, lame sur le soleil, blanc | 4, 3 et 3 s |
| Dévore | la scène du lapin, avec l'Arrancar | 10 s |
| Regard | silence, cœur lent | 8 s |
| Course | le cœur s'emballe | 11 s |
| Plaquage | la joueuse est gelée 6 s, puis libérée | 6 s |
| Fumée | l'Arrancar disparaît | 4 s |
| Perte de contrôle | rafales, forêt pliée, vertige | 25 s |
| Effondrement | le ciel se fend, boîte blanche | 20 s |

À tout moment : `sumii_fouiller <terrier> <vide, bruit ou rien>`. `sumii_retour` annule le dernier temps.

## Fin

La joueuse reste dans la boîte blanche. Le MJ la téléporte dehors (`sumii_points` donne la sortie).
Ensuite : `sumii_tout_effacer`, deux fois.
