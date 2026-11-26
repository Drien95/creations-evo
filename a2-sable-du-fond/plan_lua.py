"""Écrit sv_plan.lua : les props du dupe (scene.json) relatifs à la tête, pour retirer SEULEMENT ce build."""
import json, sys
scene, sortie = sys.argv[1], sys.argv[2]
ents = [e for e in json.load(open(scene, encoding='utf-8'))['ents'] if e['kind'] == 'prop']
tete = next(e for e in ents if e['model'].endswith('plate5x5.mdl') and e['note'] == 'sol')
assert tete['ang'] == [0, 0, 0], 'tête tournée : positions relatives à recalculer'
tx, ty, tz = tete['pos']
l = ['-- Généré par dalle/plan_lua.py depuis la scène du dupe : ne pas éditer à la main.',
     f'-- Les {len(ents)} props du dupe A2 v15, positions relatives à la tête (plate5x5 du sol, angle nul dans le build).',
     'return {']
for e in ents:
    x, y, z = e['pos']
    l.append(f'  {{ modele = "{e["model"].lower()}", pos = Vector({round(x - tx, 3)}, {round(y - ty, 3)}, {round(z - tz, 3)}) }},')
l.append('}')
open(sortie, 'w', encoding='utf-8', newline='\n').write('\n'.join(l) + '\n')
print(len(ents), 'props ->', sortie)
