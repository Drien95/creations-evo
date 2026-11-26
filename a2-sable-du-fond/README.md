# A2 · Le Sable du Fond

Partagé le 26/11/2026. Fait avec l'Atelier EVO. Map : Hueco Mundo.

Un cours de Reiryoku dans le sable. Adler debout sur sa dalle, quatre apprentis assis autour, deux pierres devant
chacun. Adler souffle : une vague de poussière part de la dalle et passe sur les places. Les pierres disent le
résultat de chaque apprenti. Au-dessus d'Adler, un fil blanc pâle, à peine visible, qu'on devine surtout à la
deuxième vague.

## Fichiers

- [Le dupe](dupe.txt) : 79 props (v15 : 76 + 3 marques de gravure). À copier dans `garrysmod/data/advdupe2/`, puis à coller avec Advanced Duplicator 2, figé, sans le tourner.
- [L'addon serveur](a2_sable_du_fond/) : la scène pour **tous les joueurs** du serveur (sable, nuit, brume, vagues, pierres, fil). Elle se voit et s'entend seulement dans la boîte de la scène.
- [Toutes les commandes](COMMANDES.md) : nom, arguments, qui peut la taper, effet, exemple.
- [Le scénario](scenario.md) : le déroulé d'une séance.

## Poser le dupe

- Sur un sol plat de la zone de build. Le sable, les rides et la cuvette sont dessinés en script autour de la dalle.
- Figé. Il peut être tourné (testé au banc tourné de 37°).
- Pour qu'il reste : PermaProps, par le staff.
- **Ancre** : c'est le **serveur** qui retrouve le build (il voit toutes les entités) et qui envoie sa position et son angle aux joueurs ; les clients ne cherchent rien eux-mêmes. Tout se cale dessus, où que le build soit posé : aucune coordonnée de map dans l'addon.
- **Gravure d'usine** (v15) : 3 petites plaques 0,25 × 0,25 dédiées, posées sur la plaque 5x5 de tête, sous le sable, invisibles, traversables et figées. Leurs écarts et leurs angles sont tirés de l'identifiant « A2 v15 » (jamais un angle rond) et chacune a une couleur improbable. Le serveur reconnaît le build quand il retrouve au moins 2 des 3 marques à leur place par rapport à une plaque 5x5 : aucun build de joueur ne porte ça par hasard, même au milieu de milliers de props.
- **Motif en secours** : si la gravure manque (ancien dupe v14, marques supprimées), le serveur reconnaît encore le build par un motif de props du dupe : la plaque 5x5, les deux disques de la dalle et le bloc invisible de la place 1, à leur place les uns par rapport aux autres. Ni couleur, ni matériau, ni propriétaire, ni classe ne comptent.
- Si ni la gravure ni le motif ne sont reconnus, le MJ désigne l'ancre avec `a2_ancre` (voir plus bas).
- Le serveur l'écrit en console seulement (aucun message à l'écran, ni chat ni notification) : console du serveur et console de qui a mené la scène : « [A2] build repéré à x y z (angle), gravure 3/3 », « [A2] gravure incomplète (2/3) » si une marque manque (le build reste reconnu, il vaut mieux le recoller), « par le motif (gravure absente) », ou « [A2] build introuvable : vise-le et tape a2_ancre ». Sans build repéré, `a2_lancer` et `a2_suivante` refusent et le disent. Si le build est retiré ou déplacé, les joueurs suivent (scène éteinte ou recalée).
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
| `lua/a2_sable_du_fond/sh_gravure.lua` | serveur et clients : lecture de la gravure d'usine (module commun, sans état) |
| `lua/a2_sable_du_fond/sh_ancre.lua` | serveur et clients : l'ancre, reconnue par la gravure, sinon par le motif de props |
| `lua/a2_sable_du_fond/sv_scene.lua` | serveur : l'état de la scène, les commandes, l'envoi aux joueurs de la boîte |
| `lua/a2_sable_du_fond/sv_retirer.lua` | serveur : `a2_tout_effacer` (et son ancien nom `a2_retirer`), l'effacement total |
| `lua/a2_sable_du_fond/sv_plan.lua` | serveur : les 79 props du dupe et leur place, pour ne retirer que ce build (généré par [`plan_lua.py`](plan_lua.py) depuis la scène du dupe) |
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
| `a2_etat` | rappel de l'état en console : vagues, places, résultats, ancre (gravure n/3), builds reconnus |
| `a2_ancre` | en visant le build : désigne ce build comme celui de la scène (utile s'il y en a deux). Si ni la gravure ni le motif ne sont reconnus, viser la plaque 5x5 du sol au coin du build ; l'ancre passe alors à tous les joueurs |
| `a2_ancre auto` | rend la main à la recherche automatique |
| `a2_effacer` | remet la **séquence** à zéro pour tous (vagues, pierres, résultats) ; le build et le décor restent |
| `a2_tout_effacer`, deux fois en 10 s | **efface tout** : les 79 props du build repéré (gravure comprise), seulement ceux à leur place dans le dupe (jamais un autre build) ; l'état, le relais et le hook du serveur ; chez tous les joueurs les effets, modèles, sable, dunes, brume, nuit et hooks de dessin. Avec un prop protect (CPPI) : les props de qui efface, ou tous pour un admin. Ensuite l'addon dort : recoller le build et taper `a2_etat` le rallume |
| `a2_retirer`, deux fois en 10 s | ancien nom de `a2_tout_effacer`, même effet |

Les réponses des commandes s'écrivent dans la console de qui les tape, jamais à l'écran (ni chat, ni notification). Détail de chaque commande : [COMMANDES.md](COMMANDES.md).

## Si rien ne s'affiche (diagnostic, pour chaque joueur)

`a2_diag` dans la console du joueur, dans la zone. Il affiche :

| Ligne | Ce qu'elle dit | Si ça ne va pas |
|---|---|---|
| addon client chargé, map (acceptée) | le script client est arrivé et la map est bonne | rien ne s'affiche du tout : addon pas installé, ou map refusée (`CARTES`) |
| scène allumée, hooks A2 actifs n/28 | la scène tourne chez ce joueur | « aucun build, rien d'actif (0/28) » : `a2_tout_effacer` est passé ; recoller le build, le MJ tape `a2_etat` |
| ancre reçue du serveur | position, angle et prop de l'ancre envoyés par le serveur (auto ou désignée par le MJ), puis « gravure vue par ce client n/3 » | « aucune ancre reçue » : regarder la console serveur (« build repéré » ou « introuvable »), le MJ tape `a2_ancre` en visant le build |
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

- Testé en solo seulement, sur gm_flatgrass (banc de l'Atelier) : pas encore avec plusieurs joueurs, ni sur Hueco. Testé au banc : build tourné de 37°, plaques 5x5 teintes et 8x8 parasites ailleurs, faux motif (plaque + disque seul) refusé ; v15 tourné reconnu par la gravure 3/3, une marque retirée : reconnu 2/3 avec le message « gravure incomplète ».
- Les droits MJ n'ont été essayés qu'avec un admin (le joueur solo) ; le refus d'un joueur non listé n'a pas été vu en jeu.
- La place des props dans le sable de Hueco n'a pas été vérifiée sur la map.
- Le build ne reste qu'avec PermaProps, posé par le staff. Vérifier après la pose que `a2_etat` dit « gravure 3/3 » (un outil qui arrondit les positions casserait la gravure ; le motif prendrait le relais).
- Pas de musique : elle reste aux MJ.
