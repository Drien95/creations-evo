# A2 · Le Sable du Fond

Partagé le 26/11/2026. Fait avec l'Atelier EVO. Map : Hueco Mundo.

Un cours de Reiryoku dans le sable. Adler debout sur sa dalle, quatre apprentis assis autour, deux pierres devant
chacun. Adler souffle : une vague de poussière part de la dalle et passe sur les places. Les pierres disent le
résultat de chaque apprenti. Au-dessus d'Adler, un fil blanc pâle, à peine visible, qu'on devine surtout à la
deuxième vague.

## Fichiers

- [Le dupe](dupe.txt) : 76 props. À copier dans `garrysmod/data/advdupe2/`, puis à coller avec Advanced Duplicator 2, figé, sans le tourner.
- [L'addon serveur](a2_sable_du_fond/) : la scène pour **tous les joueurs** du serveur (sable, nuit, brume, vagues, pierres, fil). Elle se voit et s'entend seulement dans la boîte de la scène.
- [Le scénario](scenario.md) : le déroulé d'une séance.

## Poser le dupe

- Sur un sol plat de la zone de build. Le sable, les rides et la cuvette sont dessinés en script autour de la dalle.
- Figé. Il peut être tourné (testé au banc tourné de 37°).
- Pour qu'il reste : PermaProps, par le staff.
- **Ancre** : c'est le **serveur** qui retrouve le build (il voit toutes les entités) et qui envoie sa position et son angle aux joueurs ; les clients ne cherchent rien eux-mêmes. Le serveur le reconnaît par un motif de props du dupe : une plaque 5x5 du sol, les deux disques de la dalle et le bloc invisible de la place 1, à leur place les uns par rapport aux autres. Ni couleur, ni matériau, ni propriétaire, ni classe ne comptent : les plaques des autres builds ne la trompent pas. Tout se cale dessus, où que le build soit posé : aucune coordonnée de map dans l'addon.
- Si le motif n'est pas reconnu (props manquants), le MJ désigne l'ancre avec `a2_ancre` (voir plus bas).
- Le serveur l'écrit en console, et dans le chat de qui a mené la scène : « [A2] build repéré à x y z (angle) », ou « [A2] build introuvable : vise-le et tape a2_ancre ». Sans build repéré, `a2_lancer` et `a2_suivante` refusent et le disent. Si le build est retiré ou déplacé, les joueurs suivent (scène éteinte ou recalée).
- Boîte de la scène : 3 600 × 3 600 u autour de la dalle, de 200 u sous elle à 700 u au-dessus. Dehors, rien ne change : ni nuit, ni brume, ni son.

## Installer l'addon (staff du serveur)

1. Copier le dossier `a2_sable_du_fond` dans `garrysmod/addons/` du serveur.
2. Redémarrer le serveur (ou changer de map). L'addon ne charge rien sur une map dont le nom ne contient pas « hueco » (`CARTES` dans `sh_config.lua`).
   Serveur de test sur une autre map : écrire un mot du nom de la map par ligne dans `garrysmod/data/a2_sable_du_fond_cartes.txt` (côté serveur), par exemple `flatgrass`. Sans ce fichier, la console serveur dit pourquoi l'addon ne charge pas.
3. Rien à installer chez les joueurs : le serveur leur envoie les scripts. Les sons sont ceux du jeu de base.

| Fichier | Où il tourne |
|---|---|
| `lua/autorun/a2_sable_du_fond_init.lua` | chargeur : vérifie la map, envoie les scripts client, include des bons fichiers de chaque côté |
| `lua/a2_sable_du_fond/sh_config.lua` | serveur et clients : qui mène la scène, cartes, repère et boîte, messages réseau |
| `lua/a2_sable_du_fond/sh_ancre.lua` | serveur et clients : l'ancre, reconnue par le motif de props (même règle des deux côtés) |
| `lua/a2_sable_du_fond/sv_scene.lua` | serveur : l'état de la scène, les commandes, l'envoi aux joueurs de la boîte |
| `lua/a2_sable_du_fond/sv_retirer.lua` | serveur : `a2_retirer`, le retrait du build |
| `lua/a2_sable_du_fond/cl_sequence.lua` | clients : vagues, pierres, signatures, socle, fil d'Injerto |
| `lua/a2_sable_du_fond/cl_fermeture.lua` | clients : nuit, faisceau, brume, ciel, dans la boîte seulement |
| `lua/a2_sable_du_fond/cl_sable.lua` | clients : la surface de sable et ses rides |
| `lua/a2_sable_du_fond/cl_dunes.lua` | clients : les dunes lointaines |

**Qui mène la scène** : les admins du serveur (`ADMINS = true`) et les SteamID listés dans `sh_config.lua`. Les droits sont vérifiés par le serveur : un autre joueur qui tape une commande `a2_*` ne déclenche rien.

## Commandes (pour qui mène la scène)

Une cible est `tous`, un numéro de place (1 à 4) ou un nom de joueur (une partie suffit) placé avec `a2_place`.

| Commande | Effet |
|---|---|
| `a2_place <joueur> <1-4>` | met un apprenti à une place (pour le viser par son nom ensuite) |
| `a2_pierres <cible> <on\|off>` | pose ou retire les deux pierres et le pouls de la place |
| `a2_signature <cible> <r> <g> <b>` | couleur du pouls de la place (par défaut : braise, améthyste, jade, grenat) |
| `a2_lancer` | première vague (le compte des vagues repart de 1) |
| `a2_suivante` | vague suivante, plus forte ; à partir de la 2e, le fil d'Injerto se tend et s'éclaire un instant |
| `a2_resultat <cible> <crit\|reussite\|partiel\|echec\|fiasco>` | les pierres jouent le résultat |
| `a2_adler [joueur]` | le fil d'Injerto suit ce joueur (sans nom : au centre de la dalle) |
| `a2_etat` | rappel de l'état en console : vagues, places, résultats, ancre, builds reconnus |
| `a2_ancre` | en visant le build : désigne ce build comme celui de la scène (utile s'il y en a deux). Si le motif n'est pas reconnu, viser la plaque 5x5 du sol au coin du build ; l'ancre passe alors à tous les joueurs |
| `a2_ancre auto` | rend la main à la recherche automatique |
| `a2_effacer` | remet la scène à zéro pour tous (le build reste) |
| `a2_retirer`, deux fois en 10 s | remet la scène à zéro et retire le build : les props aux modèles du dupe, dans la boîte. Avec un prop protect (CPPI), seulement ceux de qui retire, ou n'importe lesquels pour un admin |

Les réponses des commandes s'écrivent dans la console de qui les tape.

## Si rien ne s'affiche (diagnostic, pour chaque joueur)

`a2_diag` dans la console du joueur, dans la zone. Il affiche :

| Ligne | Ce qu'elle dit | Si ça ne va pas |
|---|---|---|
| addon client chargé, map (acceptée) | le script client est arrivé et la map est bonne | rien ne s'affiche du tout : addon pas installé, ou map refusée (`CARTES`) |
| ancre reçue du serveur | position, angle et prop de l'ancre envoyés par le serveur (motif ou désignée par le MJ) | « aucune ancre reçue » : regarder la console serveur (« build repéré » ou « introuvable »), le MJ tape `a2_ancre` en visant le build |
| dans la boîte | le joueur est bien dans la zone de la scène | |
| dernier état reçu | ce que le serveur a envoyé (vagues, places) | « aucun état reçu » : le MJ n'a encore rien lancé, ou le serveur ne reconnaît pas le build (`a2_etat` côté MJ) |

Le client écrit aussi en console quand il trouve ou perd l'ancre et à chaque état reçu (`[A2] ...`).

**Résultats** (on peut les rejouer autant de fois qu'on veut, chaque commande relance l'animation) :

| Résultat | Les pierres |
|---|---|
| `crit` | lévitent d'un doigt et restent en l'air |
| `reussite` | restent immobiles |
| `partiel` | une des deux glisse dans le sable |
| `echec` | les deux glissent et s'enfoncent |
| `fiasco` | éclatent |

Pour mener la scène sans ouvrir la console, chacun lie les touches qu'il veut, par exemple :
`bind KP_PLUS a2_suivante`, `bind KP_ENTER a2_lancer`, `bind KP_DEL a2_effacer`.

Tout le monde voit la même chose : l'état est tenu par le serveur et envoyé aux joueurs dans la boîte. Un joueur
qui arrive ou qui entre dans la boîte en cours de séance reçoit l'état en cours (pierres posées, résultats,
signatures) ; il n'entend pas le souffle des vagues déjà passées.

## Limites connues

- Testé en solo seulement, sur gm_flatgrass (banc de l'Atelier) : pas encore avec plusieurs joueurs, ni sur Hueco. Testé au banc : build tourné de 37°, plaques 5x5 teintes et 8x8 parasites ailleurs, faux motif (plaque + disque seul) refusé.
- Les droits MJ n'ont été essayés qu'avec un admin (le joueur solo) ; le refus d'un joueur non listé n'a pas été vu en jeu.
- La place des props dans le sable de Hueco n'a pas été vérifiée sur la map.
- Le build ne reste qu'avec PermaProps, posé par le staff.
- Pas de musique : elle reste aux MJ.
