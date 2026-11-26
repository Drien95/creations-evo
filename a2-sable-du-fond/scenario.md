# A2 · Le Sable du Fond : déroulé d'une séance

Tout est mené à la main par le MJ. Chaque étape tient jusqu'à la suivante. Le pas en avant d'Adler est joué par
le joueur lui-même : aucun script.

| N | Moment | Commandes | Ce qu'on voit |
|---|---|---|---|
| 1 | Installation | `a2_place <joueur> <1-4>` pour chaque apprenti, `a2_adler <joueur>` | Nuit dans la boîte, Adler dans son faisceau sur la dalle, les quatre assises dans le sable. Le fil d'Injerto ne se voit presque pas. |
| 2 | Les pierres | `a2_pierres tous on` (ou place par place) | Deux pierres pâles devant chaque apprenti, un pouls de sa couleur autour de la place. |
| 3 | Première vague | `a2_lancer` | Souffle d'Adler. Un anneau de poussière part de la dalle, couche la brume et passe sur les places. Rides dans le sable. |
| 4 | Résultats | `a2_resultat <cible> <résultat>` pour chacun | Les pierres jouent le résultat de chaque apprenti (voir le README). |
| 5 | Deuxième vague | `a2_suivante` | Souffle plus fort, vague plus haute. Le fil au-dessus d'Adler se tend et s'éclaire un instant, une perle de lumière y remonte, puis il retourne au noir. |
| 6 | Résultats | `a2_resultat ...` | Nouveaux résultats, sur les mêmes pierres. |
| 7 | Fin | `a2_effacer` | Tout redevient calme. `a2_retirer` (deux fois) retire aussi le build. |

On peut enchaîner d'autres vagues (`a2_suivante`) : elles forcissent jusqu'à la 4e.
